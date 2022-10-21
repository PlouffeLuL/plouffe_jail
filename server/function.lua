local Auth <const> = exports.plouffe_lib:Get("Auth")
local Callback <const> = exports.plouffe_lib:Get("Callback")
local Groups <const> = exports.plouffe_lib:Get("Groups")
local Utils <const> = exports.plouffe_lib:Get("Utils")
local Inventory <const> = exports.plouffe_lib:Get("Inventory")
local Uniques <const> = exports.plouffe_lib:Get("Uniques")

local doors = {
	bolingbroke_gate_1 = {
		lock = true,
        interactCoords = {
			{coords = vector3(1855.2760009766, 2608.7019042969, 45.672412872314), maxDst = 4.0},
			{coords = vector3(1838.3487548828, 2607.9177246094, 45.58589553833), maxDst = 4.0},
		},
		doors = {
			{model = 741314661, coords = vector3(1844.9984130859, 2604.8125, 44.639778137207), auto = { distance = 5.0, rate = 1.0 }}
		},
        access = {}
    },

	bolingbroke_gate_2 = {
		lock = true,
        interactCoords = {
			{coords = vector3(1825.6451416016, 2608.2758789062, 45.588653564453), maxDst = 4.0},
			{coords = vector3(1812.4141845703, 2607.7119140625, 45.589645385742), maxDst = 4.0},
		},
		doors = {
			{model = 741314661, coords = vector3(1818.5428466797, 2600.0505371094, 44.609661102295), auto = { distance = 5.0, rate = 1.0 }}
		},
        access = {}
    },

	bolingbroke_gate_3 = {
		lock = true,
        interactCoords = {
			{coords = vector3(1795.3614501953, 2617.1364746094, 45.565105438232), maxDst = 10.0}
		},
		doors = {
			{model = 741314661, coords = vector3(1802.9368896484, 2616.9753417969, 44.602104187012), auto = { distance = 5.0, rate = 1.0 }}
		},
        access = {}
    },

	bolingbroke_entrance_fence = {
		lock = true,
        interactCoords = {
			{coords = vector3(1797.7608642578, 2596.5649414062, 46.387306213379), maxDst = 2.0}
		},
		doors = {
			{model = -1156020871, coords = vector3(1797.7608642578, 2596.5649414062, 46.387306213379)}
		},
        access = {
			jobs = {
				police = {rankMin = 0, rankMax = 7},
				policeoff = {rankMin = 0, rankMax = 7}
			}
        }
    },

	bolingbroke_entrance_hallway_scanner = {
		lock = true,
        interactCoords = {
			{coords = vector3(1831.3399658203, 2594.9921875, 46.037910461426), maxDst = 2.0}
		},
		doors = {
			{model = -684929024, coords = vector3(1831.3399658203, 2594.9921875, 46.037910461426)}
		},
        access = {}
    },

	bolingbroke_entrance_hallway_photo = {
		lock = true,
        lockOnly = true,
        interactCoords = {
			{coords = vector3(1838.6169433594, 2593.705078125, 46.036357879639), maxDst = 2.0}
		},
		doors = {
			{model = -684929024, coords = vector3(1838.6169433594, 2593.705078125, 46.036357879639)}
		},
        access = {}
    },

	bolingbroke_information_desk = {
		lock = true,
        interactCoords = {
			{coords = vector3(1844.4038085938, 2576.9970703125, 46.03560256958), maxDst = 2.0}
		},
		doors = {
			{model = 2024969025, coords = vector3(1844.4038085938, 2576.9970703125, 46.03560256958)}
		},
        access = {}
    },

	bolingbroke_staff_entry = {
		lock = true,
        interactCoords = {
			{coords = vector3(1837.6337890625, 2576.9916992188, 46.038597106934), maxDst = 2.0}
		},
		doors = {
			{model = 2024969025, coords = vector3(1837.6337890625, 2576.9916992188, 46.038597106934)}
		},
        access = {}
    },

	bolingbroke_bloc_security_left = {
		lock = true,
        interactCoords = {
			{coords = vector3(1775.4141845703, 2491.025390625, 49.840057373047), maxDst = 2.0}
		},
		doors = {
			{model = 241550507, coords = vector3(1775.4141845703, 2491.025390625, 49.840057373047)}
		},
        access = {}
    },

	bolingbroke_bloc_security_right = {
		lock = true,
        interactCoords = {
			{coords = vector3(1772.9385986328, 2495.3132324219, 49.840057373047), maxDst = 2.0}
		},
		doors = {
			{model = 241550507, coords = vector3(1772.9385986328, 2495.3132324219, 49.840057373047)}
		},
        access = {}
    },

	bolingbroke_medical_lab = {
		lock = true,
        interactCoords = {
			{coords = vector3(1767.3232421875, 2580.83203125, 45.747825622559), maxDst = 2.0}
		},
		doors = {
			{model = -1392981450, coords = vector3(1767.3232421875, 2580.83203125, 45.747825622559)}
		},
        access = {}
    },

	bolingbroke_medical_surgery = {
		lock = true,
        interactCoords = {
			{coords = vector3(1767.169921875, 2583.5065917969, 45.729831695557), maxDst = 2.0}
		},
		doors = {
			{model = -1624297821, coords = vector3(1767.3208007813, 2584.6071777344, 45.753448486328)},
			{model = -1624297821, coords = vector3(1767.3208007813, 2582.3078613281, 45.753448486328)}
		},
        access = {}
    }
}

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

    if Jail.plouffe_doorlock  then
        Utils.CreateDepencie("plouffe_doorlock", Jail.ExportDoors)
    end

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

function Jail.ExportDoors()
    for k,v in pairs(doors) do
        exports.plouffe_doorlock:RegisterDoor(k,v, false)
    end
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
    Jail.maxComServ = tonumber(GetConvar("plouffe_jail:max_com_serv", 25))
    Jail.maxSentencedComServ = tonumber(GetConvar("plouffe_jail:max_com_serv_sentence", 100))
    Jail.comServPunition = tonumber(GetConvar("plouffe_jail:com_serv_punition", 100))
    Jail.maxJail = tonumber(GetConvar("plouffe_jail:max_jail_time", 120))
    Jail.allow_breakout = GetConvar("plouffe_jail:breakout", false)
    Jail.breakout_item = GetConvar("plouffe_jail:breakout_item", "")
    Jail.breakout_cooldown = GetConvar("plouffe_jail:breakout_cooldown", 12)
    Jail.plouffe_doorlock = GetConvar("plouffe_jail:plouffe_doorlock", false)
    Jail.lastBreakOut = tonumber(GetResourceKvpString("lastBreakout")) or 0

    Jail.breakout_cooldown *= (60 * 60)

    local data = json.decode(GetConvar("plouffe_jail:police_groups", ""))
    if data then
        Jail.PoliceGroups = {}
        for k,v in pairs(data) do
            Jail.PoliceGroups[v] = true
        end

        for k,v in pairs(doors) do
            v.access.group = Jail.PoliceGroups
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
            header = Lang.jail_label,
            message = Lang.already_completed
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
            header = Lang.comserv_label,
            message = Lang.already_completed
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

function Jail.ThermalInstalled(auth)
    local playerId = source
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:installed_thermite") then
        return
    end

    local pedCoords = GetEntityCoords(GetPlayerPed(playerId))
    if #(Jail.breakOutCoords - pedCoords) > 2 then
        return
    end

    if Inventory.Search(playerId, "count", Jail.breakout_item) < 1 then
        return
    end

    Inventory.RemoveItem(playerId, Jail.breakout_item, 1)

    Jail.Breakout()
end
RegisterNetEvent("plouffe_jail:installed_thermite", Jail.ThermalInstalled)

function Jail.ReduceSentence(playerId, amount)
    local unique = Uniques.Get(playerId)
    if not jailed_characters[unique] then
        return
    end

    Utils.Notify(playerId, {
        style = "info",
        header = Lang.jail_label,
        message = Lang.jail_sentence_down:format(amount)
    })

    jailed_characters[unique].out_time -= (amount * 60)
end
exports("ReduceSentence", Jail.ReduceSentence)

function Jail.UpSentence(playerId, amount)
    local unique = Uniques.Get(playerId)
    if not jailed_characters[unique] then
        return
    end

    Utils.Notify(playerId, {
        style = "info",
        header = Lang.jail_label,
        message = Lang.jail_sentence_up:format(amount)
    })

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
        header = Lang.comserv_label,
        message = Lang.comserv_jobsLeft:format(comserv_characters[unique].amount)
    })
end
exports("ReduceComserv", Jail.ReduceComserv)

function Jail.Breakout()
    if not Jail.allow_breakout then
        return
    end

    for k,v in pairs(active_jailed_players) do
        local unique = Uniques.Get(k)
        jailed_characters[unique] = nil
    end

    jailed_characters()

    pcall(function ()
        exports.plouffe_dispatch:sendAlert({
            index = 'StreetRace',
            coords = Jail.releasedCoords,
            job = Jail.PoliceGroups,
            blip = {name = "10-30A", sprite = 9, scale = 1.0, color = 1, radius = 400.0},
            code = "10-30A",
            name = "Evasion de prison",
            style = 'red',
            fa = "fa-exclamation-triangle"
        })
    end)

    GlobalState.jail_breakout = true

    if Jail.plouffe_doorlock then
        local list = {'bolingbroke_gate_1', 'bolingbroke_gate_2', 'bolingbroke_gate_3', 'bolingbroke_entrance_fence'}
        exports.plouffe_doorlock:UpdateDoorStateTable(list, false)
    end

    SetTimeout(1000 * 60 * 1, function()
        if Jail.plouffe_doorlock then
            exports.plouffe_doorlock:UpdateDoorStateTable(list, true)
        end

        GlobalState.jail_breakout = false
    end)

    Jail.lastBreakOut = os.time()
    SetResourceKvp("lastBreakout",  Jail.lastBreakOut)
end
exports("Breakout", Jail.Breakout)

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

Callback.Register('plouffe_jail:isBreakoutAvaible', function(playerId, auth)
    if not Auth.Validate(playerId,auth) or not Auth.Events(playerId,"plouffe_jail:isBreakoutAvaible") then
        return
    end

    return os.time() - Jail.lastBreakOut > Jail.breakout_cooldown
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