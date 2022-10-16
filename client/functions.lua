local Callback = exports.plouffe_lib:Get("Callback")
local Utils = exports.plouffe_lib:Get("Utils")
local Interface = exports.plouffe_lib:Get("Interface")
local Lang = exports.plouffe_lib:Get("Lang")
local Jail = {}

local guardsCoords = {
    {
		coords = vector3(1827.7591552734, 2618.9887695312, 62.964584350586),
		heading = 229.21482849121097,
		weapon = "weapon_carbinerifle_mk2",
		model = "s_m_m_prisguard_01"
	},

	{
		coords = vector3(1821.7583007812, 2617.0888671875, 62.957973480225),
		heading = 174.04202270507812,
		weapon = "weapon_carbinerifle_mk2",
		model = "s_m_m_prisguard_01"
	},

	{
		coords = vector3(1824.4189453125, 2480.03515625, 62.698795318604),
		heading = 353.9418640136719,
		weapon = "weapon_carbinerifle_mk2",
		model = "s_m_m_prisguard_01"
	},

	{
		coords = vector3(1828.7728271484, 2475.3186035156, 62.69694519043),
		heading = 280.51123046875,
		weapon = "weapon_carbinerifle_mk2",
		model = "s_m_m_prisguard_01"
	}
}

local function wake()
    local list = Callback.Sync("plouffe_jail:loadPlayer")
    for k,v in pairs(list) do
        Jail[k] = v
    end

    for k,v in pairs(Jail.zones) do
        local registered, reason = exports.plouffe_lib:Register(v)
    end

    Jail:RegisterEvents()

    if Jail.isInJail then
        SetTimeout(GetConvar("plouffe_lib:debug", "false") == "true"  and 1 or 10000, function ()
            local cellCoords = Jail.cells[math.random(1,#Jail.cells)]
            SetEntityCoords(Jail.cache.ped, cellCoords.x, cellCoords.y, cellCoords.z - 1)
        end)

        Jail.SetInJail()
    end
end

function Jail:RegisterEvents()
    AddEventHandler("plouffe_jail:inJail", self.InJail)
    AddEventHandler("plouffe_jail:outsideJail", self.OutsideJail)
    AddEventHandler("plouffe_jail:onClothing",self.OnClothing)
    AddEventHandler("plouffe_jail:onYoga", self.OnYoga)
    AddEventHandler("plouffe_jail:in_mid",self.SpawnGuards)
    AddEventHandler("plouffe_jail:outside_mid", self.DeleteGuards)
    AddEventHandler("plouffe_jail:onWork", self.OnWork)

    AddEventHandler("plouffe_jail:imStupid", self.stupid)
    AddEventHandler("plouffe_jail:notStupid", self.notStupid)

    AddEventHandler("plouffe_jail:onGuardInteraction", self.GuardInteraction)

    AddEventHandler("plouffe_jail:open_shop", Jail.OpenShop)

    Utils.RegisterNetEvent("plouffe_jail:isInJail", Jail.SetInJail)

    Utils.RegisterNetEvent("plouffe_jail:removeWorkZone", function(index)
        Jail.jobs_zones[index].active = false

        if not Jail.isInJail then
            return
        end

        exports.plouffe_lib:DestroyZone(index)
    end)

    Utils.RegisterNetEvent("plouffe_jail:addWorkZone", function(index)
        Jail.jobs_zones[index].active = true
        if not Jail.isInJail then
            return
        end

        exports.plouffe_lib:Register(Jail.jobs_zones[index])
    end)

    Callback.Register("plouffe_jail:unJail", Jail.SetOutOfJail)

    self.cache = exports.plouffe_lib:OnCache(function(cache)
        self.cache = cache
    end)

    AddStateBagChangeHandler("dead", "LocalPlayer",function(bagName,key,value,reserved,replicated)
        if value then
            Jail.notStupid()
        end
    end)
end

function Jail.SetInJail()
    Jail.isInJail = true
    Jail.CheckForEntityDamage()
    for k,v in pairs(Jail.jobs_zones) do
        if v.active then
            local registered, reason = exports.plouffe_lib:Register(v)
        end
    end
end

function Jail.SetOutOfJail()
    Jail.isInJail = false
    RemoveEventHandler(Jail.cookie_entityDamaged)
    Jail.cookie_entityDamaged = nil
    for k,v in pairs(Jail.jobs_zones) do
        exports.plouffe_lib:DestroyZone(k)
    end

    SetEntityCoords(Jail.cache.ped, Jail.releasedCoords.x, Jail.releasedCoords.y, Jail.releasedCoords.z - 1)

    return true
end

function Jail.OpenShop()
    local buyable_items, reputation = Callback.Sync("plouffe_jail:getShopData", Jail.auth)
    local menu = {}

    for k,v in pairs(buyable_items) do
        if v.price <= reputation then
            menu[#menu+1] = {
                header = v.label,
                text = ("%s Reputation"):format(v.price),
                item = k
            }
        end
    end

    if #menu < 1 then
        return
    end

    local clicked = Interface.Menu.Open(menu)
    if not clicked then
        return
    end

    --- [To do] Add progress bar with giveOrTake aimation + baggie?

    TriggerServerEvent("plouffe_jail:trade_item", clicked.item, Jail.auth)
end

function Jail.OnWork(data)
    if not Jail.isInJail then
        return
    end

    local finished = Interface.Progress.Circle({
        duration = Jail.jobs[data.job_type].duration,
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = Jail.jobs[data.job_type].anim,
        prop =  Jail.jobs[data.job_type].prop
    })

    if not finished then
        return
    end

    TriggerServerEvent("plouffe_jail:finished_job", data, Jail.auth)
end

function Jail.OnYoga()
    if not Jail.isInJail then
        return
    end

    print("Yoga")
end

function Jail.OnClothing()
    if not Jail.isInJail then
        return
    end

    print("Clothing")
end

function Jail.GuardInteraction()
    local data = Callback.Sync("plouffe_jail:getTimeLeft", Jail.auth)
    if not data then
        return
    end

    local menu = {
        {
            header = "Sentence ecouler",
            text = data.time_passed,
        },
        {
            header = "Sentence restante",
            text = data.time_left,
        }
    }

    if data.canLeave then
        menu[#menu+1] = {
            header = "Votre sentence est terminer",
            text = "cliquer ici pour sortir",
            leave = true
        }
    end

    local clicked = Interface.Menu.Open(menu)
    if not clicked then
        return
    end
    if clicked.leave then
        TriggerServerEvent("plouffe_jail:request_release", Jail.auth)
    end
end

function Jail.InJail()
    --- Jail zone not jail jailed you fuck
end

function Jail.OutsideJail()
    if Jail.isInJail and not Jail.breakOut then
        local cellCoords = Jail.cells[math.random(1,#Jail.cells)]
        SetEntityCoords(Jail.cache.ped, cellCoords.x, cellCoords.y, cellCoords.z - 1)
        TriggerServerEvent("plouffe_jail:boost_sentence", 5, Jail.auth)
    end
end

function Jail.SendToJailMenu()
    local target, distance = Utils.GetClosestPlayer()
    local target_id = GetPlayerServerId(target)

    if target and target ~= -1 and distance <= 2.0 then
        local data = Interface.Dialog.Open({
            {
                id = "time",
                header = Lang.sentence_time,
                placeholder = "minutes"
            }
        })

        if not data.time then
            return
        end

        local time = tonumber(data.time)
        if not time or (time and time > Jail.maxJail) then
            return Interface.Notifications.Show({
                style = "info",
                header = "Jail",
                message = Lang.invalid_entry
            })
        end

        TriggerServerEvent("plouffe_jail:sendToJail", time, target_id, Jail.auth)
    else
        Interface.Notifications.Show({
            style = "info",
            header = "Jail",
            message = Lang.no_player_near
        })
    end
end
exports("SendToJailMenu", Jail.SendToJailMenu)

function Jail.UnjailMenu()
    local data = Interface.Dialog.Open({
        {
            id = "playerId",
            header = "Player Id",
            placeholder = "pid"
        },
        {
            id = "unique",
            header = "Unique ID",
            placeholder = "unique"
        }
    })

    if data.unique and data.unique:len() > 0 then
        TriggerServerEvent("plouffe_jail:unjail", "unique", data.unique, Jail.auth)
    elseif data.playerId and data.playerId:len() > 0 then
        TriggerServerEvent("plouffe_jail:unjail", "playerId", data.playerId, Jail.auth)
    end
end
exports("UnjailMenu", Jail.UnjailMenu)

function Jail.SpawnGuards()
    for k,v in pairs(guardsCoords) do
        if not DoesEntityExist(v.pedId) then
            local coords = vector3(v.coords.x,v.coords.y,v.coords.z - 1)
            v.pedId = Utils.SpawnPed(v.model,coords,v.heading,false,false)
            SetPedAsCop(v.pedId,true)
            GiveWeaponToPed(v.pedId, GetHashKey(v.weapon), 999, false, true)
            FreezeEntityPosition(v.pedId, true)
            SetEntityInvincible(v.pedId, true)
        end
    end
end

function Jail.DeleteGuards()
    for k,v in pairs(guardsCoords) do
        DeleteEntity(v.pedId)
        v.pedId = nil
    end
end

function Jail.stupid()
    for k,v in pairs(guardsCoords) do
        TaskShootAtEntity(v.pedId, Jail.cache.ped, 5000, `FIRING_PATTERN_FULL_AUTO`)
    end
end

function Jail.notStupid()
    for k,v in pairs(guardsCoords) do
       ClearPedTasks(v.pedId)
    end
end

function Jail.entityDamaged(victim, culprit, weapon, baseDamage)
    if not Jail.isInJail then
        RemoveEventHandler(Jail.cookie_entityDamaged)
        Jail.cookie_entityDamaged = nil
        return
    end
    if culprit ~= Jail.cache.ped then
        return
    end

    local entType = GetEntityType(victim)
    local value = (entType == 1 and 5) or (entType == 3 and 2) or 1

    RemoveEventHandler(Jail.cookie_entityDamaged)
    Jail.cookie_entityDamaged = nil
    TriggerServerEvent("plouffe_jail:boost_sentence", value, Jail.Auth)

    SetTimeout(10000, Jail.CheckForEntityDamage)
end

function Jail.CheckForEntityDamage()
    if Jail.cookie_entityDamaged then
       return
    end

    Jail.cookie_entityDamaged = AddEventHandler("entityDamaged", Jail.entityDamaged)
end

exports.plouffe_lib:OnFrameworkLoaded(function() CreateThread(wake) end)

AddEventHandler("onResourceStop", function(resourcename)
    if resourcename == "plouffe_jail" then
        Jail.DeleteGuards()
    end
end)