local Auth <const> = exports.plouffe_lib:Get("Auth")
local Callback <const> = exports.plouffe_lib:Get("Callback")
local Groups <const> = exports.plouffe_lib:Get("Groups")
local Utils <const> = exports.plouffe_lib:Get("Utils")
local Inventory <const> = exports.plouffe_lib:Get("Inventory")
local Uniques <const> = exports.plouffe_lib:Get("Uniques")

local active_comserv_players = {}
local active_jailed_players = {}

local jobs_done = setmetatable({}, {
    __newindex = function(self,key,val)
        for k,v in pairs(active_jailed_players) do
            TriggerClientEvent("plouffe_jail:removeWorkZone", k, key)
        end
        Jail.jobs_zones[key].active = false
        rawset(self,key,val)
    end,

    __call = function(self, key)
        for k,v in pairs(active_jailed_players) do
            TriggerClientEvent("plouffe_jail:addWorkZone", k, key)
        end
        Jail.jobs_zones[key].active = true
        self[key] = nil
    end
})

local comserv_done = setmetatable({}, {
    __newindex = function(self,key,val)
        for k,v in pairs(active_comserv_players) do
            TriggerClientEvent("plouffe_jail:removeComServZone", k, key)
        end
        Jail.comServ.jobs_zones[key].active = false
        rawset(self,key,val)
    end,

    __call = function(self, key)
        for k,v in pairs(active_comserv_players) do
            TriggerClientEvent("plouffe_jail:addComServZone", k, key)
        end
        Jail.comServ.jobs_zones[key].active = true
        self[key] = nil
    end
})

local comserv_characters
local jailed_characters
local jailers_reputation

function Jail.Wake()
    Jail.ValidateConfig()
    Jail:CreateWorkZones()

    comserv_characters = json.decode(GetResourceKvpString("comserv_characters") or "[]")
    jailed_characters = json.decode(GetResourceKvpString("jailed_characters") or "[]")
    jailers_reputation = json.decode(GetResourceKvpString("jailers_reputation") or "[]")

    setmetatable(comserv_characters, {
        __call = function(self)
            SetResourceKvp(tostring(self), json.encode(self))
        end,

        __tostring = function()
            return "comserv_characters"
        end
    })

    setmetatable(jailed_characters, {
        __call = function(self)
            SetResourceKvp(tostring(self), json.encode(self))
        end,

        __tostring = function()
            return "jailed_characters"
        end
    })

    setmetatable(jailers_reputation, {
        __newindex = function(self,key,val)
            rawset(self,key,val)
        end,

        __index = function()
            return 0
        end,

        __call = function(self)
            SetResourceKvp(tostring(self), json.encode(self))
        end,

        __tostring = function()
            return "jailers_reputation"
        end
    })

    Server.ready = true
end

function Jail:CreateWorkZones()
    for job_type,job_data in pairs(self.jobs) do
        for k,v in pairs(job_data.coords) do
            local name = ("%s_%s"):format(job_type,k)
            self.jobs_zones[name] = {
                name = name,
                distance = job_data.distance,
                isZone = job_data.isZone,
                label = job_data.label,
                keyMap = job_data.keyMap,
                params = {job_type = job_type, job_index = name},
                coords = v,
                active = true
            }
        end
    end

    for job_type,job_data in pairs(self.comServ.jobs) do
        for k,v in pairs(job_data.coords) do
            local name = ("%s_%s"):format(job_type,k)
            self.comServ.jobs_zones[name] = {
                name = name,
                distance = job_data.distance,
                isZone = job_data.isZone,
                label = job_data.label,
                keyMap = job_data.keyMap,
                params = {job_type = job_type, job_index = name},
                coords = v,
                active = true
            }
        end
    end
end

function Jail:GetData(key, playerId)
    local retval = {auth = key}
    local unique = Uniques.Get(playerId)
    if jailed_characters[unique] and jailed_characters[unique].out_time > os.time() then
        retval.isInJail = true
        active_jailed_players[playerId] = true
    end

    if comserv_characters[unique] and comserv_characters[unique].amount > 0 then
        retval.isInComServ = true
        active_comserv_players[playerId] = true
    end

    for k,v in pairs(self) do
        if type(v) ~= "function" then
            retval[k] = v
        end
    end

    return retval
end

function Jail.ValidateConfig()
    Jail.maxComServ = tonumber(GetConvar("plouffe_jail:max_com_serv", ""))
    Jail.maxSentencedComServ = tonumber(GetConvar("plouffe_jail:max_com_serv_sentence", ""))
    Jail.comServPunition = tonumber(GetConvar("plouffe_jail:com_serv_punition", ""))
    Jail.maxJail = tonumber(GetConvar("plouffe_jail:max_jail_time", ""))

    local data = json.decode(GetConvar("plouffe_jail:police_groups", ""))
    if data then
        Jail.PoliceGroups = {}
        for k,v in pairs(data) do
            Jail.PoliceGroups[v] = true
        end

        data = nil
    end

    data = json.decode(GetConvar("plouffe_jail:buyable_items", ""))

    if data then
        Jail.buyable_items = {}
        for k,v in pairs(data) do
            local one, two = v:find(":")
            local item, value = v:sub(0,one - 1), tonumber(v:sub(one + 1,v:len()))
            local item_data = exports.plouffe_lib:GetItem(item) or exports.plouffe_lib:GetItem(item:upper())

            Jail.buyable_items[item] = {
                name = item,
                label = item_data.label,
                price = value
            }
        end
    end
end

function Jail:IsPlayerAllowed(playerId)
    local playerGroups = Groups.GetPlayerGroups(playerId)
    for gType,gData in pairs(playerGroups) do
        if Jail.PoliceGroups[gData.group] then
            return true
        end
    end

    return false
end

function Jail:CooldownThread(index)
    jobs_done[index] = os.time()

    if self.coolDownThread then
        return
    end

    self.coolDownThread = true

    CreateThread(function ()
        while Utils.TableLen(jobs_done) > 0 do
            Wait(1000 * 10)
            local time = os.time()
            for k,v in pairs(jobs_done) do
                if time - v > (60 * 5) then
                    jobs_done(k)
                end
            end
        end

        self.coolDownThread = false
    end)
end

function Jail:ComservCooldownThread(index)
    comserv_done[index] = os.time()

    if self.coolDownThread then
        return
    end

    self.coolDownThread = true

    CreateThread(function ()
        while Utils.TableLen(comserv_done) > 0 do
            Wait(1000 * 10)
            local time = os.time()
            for k,v in pairs(comserv_done) do
                if time - v > (60 * 1) then
                    comserv_done(k)
                end
            end
        end

        self.coolDownThread = false
    end)
end

function Jail.SendPlayerToJail(time,targetId,auth)
    local playerId = source
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:sendToJail") then
        return
    end

    if not Jail:IsPlayerAllowed(playerId) or time > Jail.maxJail then
        return
    end

    local ped_coords = GetEntityCoords(GetPlayerPed(playerId))
    local tped_coords = GetEntityCoords(GetPlayerPed(targetId))

    if #(ped_coords - tped_coords) > 5 then
        return
    end

    Jail.Set(targetId, time)
end
RegisterNetEvent("plouffe_jail:sendToJail", Jail.SendPlayerToJail)

function Jail.UnJailPlayer(idType, id, auth)
    local playerId = source
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:unjail") then
        return
    end

    if not Jail:IsPlayerAllowed(playerId) then
        return
    end

    Jail.Remove(idType, id)
end
RegisterNetEvent("plouffe_jail:unjail", Jail.UnJailPlayer)

function Jail.BoostSentence(amount, auth)
    local playerId = source
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:boost_sentence") then
        return
    end

    if not Jail:IsPlayerAllowed(playerId) then
        return
    end

    Jail.UpSentence(playerId, amount)
end
RegisterNetEvent("plouffe_jail:boost_sentence", Jail.BoostSentence)

function Jail.FinishedJob(data, auth)
    local playerId = source
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:finished_job") then
        return
    end

    local zone = Jail.jobs_zones[data.job_index]
    if not zone.active then
        return Utils.Notify(playerId, {
            style = "info",
            header = "Jail",
            message = "Already completed"
        })
    end

    local unique = Uniques.Get(playerId)
    local rVal = Jail.jobs[data.job_type].reduceValue

    Jail:CooldownThread(data.job_index)
    Jail.ReduceSentence(playerId, math.ceil(math.random(rVal.min, rVal.max)))

    jailers_reputation[unique] += (data.repValue or 1)
end
RegisterNetEvent("plouffe_jail:finished_job", Jail.FinishedJob)

function Jail.RequestRelease(auth)
    local playerId = source
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:request_release") then
        return
    end

    local unique = Uniques.Get(playerId)
    local data = jailed_characters[unique]
    if not data or (data and os.time() > data.out_time) then
        Jail.Remove("playerId", playerId)
    end
end
RegisterNetEvent("plouffe_jail:request_release", Jail.RequestRelease)

function Jail.TradeItem(item, auth)
    local playerId = source
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:trade_item") then
        return
    end

    local unique = Uniques.Get(playerId)
    if not Jail.buyable_items[item] or (Jail.buyable_items[item] and Jail.buyable_items[item].price > jailers_reputation[unique]) then
        return
    end

    jailers_reputation[unique] -= Jail.buyable_items[item].price

    Inventory.AddItem(playerId, item, 1)
end
RegisterNetEvent("plouffe_jail:trade_item", Jail.TradeItem)

function Jail.FinishedComservJob(data, auth)
    local playerId = source
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:finished_comserv_job") then
        return
    end

    local zone = Jail.comServ.jobs_zones[data.job_index]

    if not zone.active then
        return Utils.Notify(playerId, {
            style = "info",
            header = "Community services",
            message = "Already completed"
        })
    end

    Jail:ComservCooldownThread(data.job_index)
    Jail.ReduceComserv("playerId", playerId, 1)
end
RegisterNetEvent("plouffe_jail:finished_comserv_job", Jail.FinishedComservJob)

function Jail.SendPlayerToComserv(amount,targetId,auth)
    local playerId = source
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:sendToComserv") then
        return
    end

    if not Jail:IsPlayerAllowed(playerId) or amount > Jail.maxSentencedComServ then
        return
    end

    local ped_coords = GetEntityCoords(GetPlayerPed(playerId))
    local tped_coords = GetEntityCoords(GetPlayerPed(targetId))

    if #(ped_coords - tped_coords) > 5 then
        return
    end

    Jail.AddComServ(targetId, amount)
end
RegisterNetEvent("plouffe_jail:sendToComserv", Jail.SendPlayerToComserv)

function Jail.ReduceSentence(playerId, amount)
    local unique = Uniques.Get(playerId)
    if not jailed_characters[unique] then
        return
    end

    jailed_characters[unique].out_time -= (amount * 60)
end
exports("ReduceSentence", Jail.ReduceSentence)

function Jail.UpSentence(playerId, amount)
    local unique = Uniques.Get(playerId)
    if not jailed_characters[unique] then
        return
    end

    jailed_characters[unique].out_time += (amount * 60)
end
exports("UpSentence", Jail.UpSentence)

function Jail.Set(playerId, time)
    local unique = Uniques.Get(playerId)
    local retval = {}

    active_jailed_players[playerId] = true

    jailed_characters[unique] = {sent_time = os.time(), out_time = os.time() + (time * 60)}
    jailed_characters()
    pcall(function() exports.ox_inventory:ConfiscateInventory(playerId) end)

    for k,v in pairs(Jail.jobs_zones) do
        if v.active then
            retval[k] = v.active
        end
    end

    local currentBucket = GetPlayerRoutingBucket(playerId)
    SetPlayerRoutingBucket(playerId, math.random(1,99))
    Callback.Sync(playerId, "plouffe_jail:setInJail", false, retval)
    SetPlayerRoutingBucket(playerId, currentBucket)
end
exports("Set", Jail.Set)

function Jail.Remove(idType, id)
    local unique = (idType == "playerId" and Uniques.Get(id)) or (idType == "unique" and id)
    if not jailed_characters[unique] then
        return
    end

    jailed_characters[unique] = nil
    jailed_characters()
    if idType ~= "playerId" then
        return
    end

    active_jailed_players[id] = nil

    local _ = Callback.Sync(id, "plouffe_jail:unJail")

    pcall(function() exports.ox_inventory:ReturnInventory(id) end)
end
exports("Remove", Jail.Remove)

function Jail.AddComServ(playerId, amount)
    local unique = Uniques.Get(playerId)
    local coords = Jail.comServ.coords
    local ped = GetPlayerPed(playerId)

    active_comserv_players[playerId] = true

    comserv_characters[unique] = comserv_characters[unique] or {amount = 0}
    comserv_characters[unique].amount += amount
    comserv_characters()

    if comserv_characters[unique].amount > Jail.maxComServ then
        return Jail.Set(playerId, Jail.comServPunition)
    end

    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    TriggerClientEvent("plouffe_jail:isInComServ", playerId)
end
exports("AddComServ", Jail.AddComServ)

function Jail.RemoveComServ(idType, id)
    local unique = (idType == "playerId" and Uniques.Get(id)) or (idType == "unique" and id)
    if not comserv_characters[unique] then
        return
    end

    comserv_characters[unique] = nil
    comserv_characters()
    if idType ~= "playerId" then
        return
    end

    active_comserv_players[id] = nil

    local _ = Callback.Sync(id, "plouffe_jail:clearComserv")
end
exports("RemoveComServ", Jail.RemoveComServ)

function Jail.ReduceComserv(idType, id, amount)
    local unique = (idType == "playerId" and Uniques.Get(id)) or (idType == "unique" and id)
    if not comserv_characters[unique] then
        return
    end

    comserv_characters[unique].amount -= amount

    if comserv_characters[unique].amount < 1 then
        return Jail.RemoveComServ(idType, id)
    end

    if idType ~= "playerId" then
        return
    end

    Utils.Notify(id, {
        style = "info",
        header = "Community services",
        message = ("%s left to do"):format(comserv_characters[unique].amount)
    })
end
exports("ReduceComserv", Jail.ReduceComserv)

Callback.Register("plouffe_jail:loadPlayer", function(playerId)
    local registred, key = Auth.Register(playerId)

    if not registred then
        return DropPlayer(" ")
    end

    while not Server.ready do
        Wait(1000)
    end

    return Jail:GetData(key, playerId)
end)

Callback.Register("plouffe_jail:getTimeLeft", function(playerId, auth)
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:getTimeLeft") then
        return
    end

    local unique = Uniques.Get(playerId)
    local jail_data = jailed_characters[unique]
    if not jail_data then
        return
    end

    local data = {}
    local date = os.date("!*t", os.difftime(os.time(), jail_data.sent_time))
    local date2 = os.time() < jail_data.out_time and os.date("!*t", os.difftime(jail_data.out_time, os.time())) or {day = 1, hour = 0, min = 0, sec = 0}

    date.day -= 1
    date2.day -= 1
    data.time_passed = ("%s : %s, %s : %s, %s : %s, %s : %s"):format(date.day, Lang.days, date.hour, Lang.hours, date.min, Lang.minutes, date.sec, Lang.seconds)
    data.time_left = ("%s : %s, %s : %s, %s : %s, %s : %s"):format(date2.day, Lang.days, date2.hour, Lang.hours, date2.min, Lang.minutes, date2.sec, Lang.seconds)

    data.canLeave = os.time() > jail_data.out_time

    return data
end)

Callback.Register("plouffe_jail:getShopData", function(playerId, auth)
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:getShopData") then
        return
    end

    local unique = Uniques.Get(playerId)

    return Jail.buyable_items, jailers_reputation[unique]
end)

Callback.Register("plouffe_jail:refresh_zone", function(playerId, zoneType, auth)
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:getShopData") then
        return
    end

    local data = zoneType == "jail" and Jail.jobs_zones or zoneType == "comserv" and Jail.comServ.jobs_zones
    local retval = {}
    for k,v in pairs(data) do
        if v.active then
            retval[k] = v.active
        end
    end

    return retval
end)

Callback.Register("plouffe_jail:getComServLeft", function(playerId, auth)
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:getComServLeft") then
        return
    end

    local unique = Uniques.Get(playerId)

    return comserv_characters[unique] and comserv_characters[unique].amount or 0
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
	if eventData.secondsRemaining == 60 then
		SetTimeout(50000, function()
            jailed_characters()
            jailers_reputation()
            comserv_characters()
		end)
	end
end)

AddEventHandler("playerDropped", function()
    local playerId = source
    if not active_jailed_players[playerId] and not active_comserv_players[playerId] then
        return
    end

    active_comserv_players[playerId] = nil
    active_jailed_players[playerId] = nil
end)

CreateThread(Jail.Wake)