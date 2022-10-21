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

local function null() end

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

        Jail.SetInJail(true)
    end

    if Jail.isInComServ then
        for k,v in pairs(Jail.comServ.jobs_zones) do
            if v.active then
                local registered, reason = exports.plouffe_lib:Register(v)
            end
        end
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

    AddEventHandler("plouffe_jail:onComServ_Work", self.OnComServWork)

    AddEventHandler("plouffe_jail:imStupid", self.stupid)
    AddEventHandler("plouffe_jail:notStupid", self.notStupid)

    AddEventHandler("plouffe_jail:onGuardInteraction", self.GuardInteraction)

    AddEventHandler("plouffe_jail:open_shop", self.OpenShop)

    AddEventHandler("plouffe_jail:inComserv", self.InComserv)
    AddEventHandler("plouffe_jail:outsideComserv", self.OutsideComserv)

    AddEventHandler("plouffe_jail:onComservGuardInteraction", self.onComservGuardInteraction)

    Utils.RegisterNetEvent("plouffe_jail:removeWorkZone", self.RemoveWorkZone)
    Utils.RegisterNetEvent("plouffe_jail:addWorkZone", self.AddWorkZone)

    Utils.RegisterNetEvent("plouffe_jail:isInComServ", self.SetInComserv)

    Utils.RegisterNetEvent("plouffe_jail:removeComServZone", self.RemoveComServZone)
    Utils.RegisterNetEvent("plouffe_jail:addComServZone", self.AddComServZone)

    Callback.Register("plouffe_jail:clearComserv", self.ClearComServ)

    Callback.Register("plouffe_jail:unJail", self.SetOutOfJail)

    Callback.Register("plouffe_jail:setInJail", self.SetInJail)

    self.cache = exports.plouffe_lib:OnCache(function(cache)
        self.cache = cache
    end)

    AddStateBagChangeHandler("dead", "LocalPlayer", function(bagName,key,value,reserved,replicated)
        if value then
            self.notStupid()
        end
    end)
end

function Jail.onComservGuardInteraction()
    local finished = Interface.Progress.Circle({
        duration = 1500,
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {dict = "mp_common", clip = "givetake1_a"}
    })

    local data = Callback.Sync("plouffe_jail:getComServLeft", Jail.auth)

    Interface.Notifications.Show({
        style = "info",
        header = Lang.comserv_label,
        message = Lang.comserv_jobsLeft:format(data)
    })
end

function Jail.RemoveComServZone(index)
    Jail.comServ.jobs_zones[index].active = false
    if not Jail.isInComServ then
        return
    end

    exports.plouffe_lib:DestroyZone(index)
end

function Jail.AddComServZone(index)
    Jail.comServ.jobs_zones[index].active = true
    if not Jail.isInComServ then
        return
    end

    exports.plouffe_lib:Register(Jail.comServ.jobs_zones[index])
end

function Jail.InComserv()
    --- Comserv zone not sent
end

function Jail.OutsideComserv()
    --- Comserv zone not sent
end

function Jail.SetInComserv()
    Jail.isInComServ = true
    local refreshed = Callback.Sync("plouffe_jail:refresh_zone", "comserv", Jail.auth)

    for k,v in pairs(Jail.comServ.jobs_zones) do
        if refreshed[k] then
            v.active = true
        end
        if v.active then
            local registered, reason = exports.plouffe_lib:Register(v)
        end
    end
end

function Jail.ClearComServ()
    Jail.isInComServ = false

    for k,v in pairs(Jail.comServ.jobs_zones) do
        exports.plouffe_lib:DestroyZone(k)
    end

    Interface.Notifications.Show({
        style = "info",
        header = Lang.comserv_label,
        message = Lang.comserv_finished
    })

    return true
end

function Jail.OnComServWork(data)
    if not Jail.isInComServ then
        return
    end

    local finished = Interface.Progress.Circle({
        duration = Jail.comServ.jobs[data.job_type].duration,
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = Jail.comServ.jobs[data.job_type].anim,
        prop =  Jail.comServ.jobs[data.job_type].prop
    })

    if not finished then
        return
    end

    TriggerServerEvent("plouffe_jail:finished_comserv_job", data, Jail.auth)
end

function Jail.RemoveWorkZone(index)
    Jail.jobs_zones[index].active = false
    if not Jail.isInJail then
        return
    end

    exports.plouffe_lib:DestroyZone(index)
end

function Jail.AddWorkZone(index)
    Jail.jobs_zones[index].active = true
    if not Jail.isInJail then
        return
    end

    exports.plouffe_lib:Register(Jail.jobs_zones[index])
end

function Jail.JailCam()
    local cell_coords = Jail.cells[math.random(1,#Jail.cells)]

    Utils.FadeOut(1000, true)

    local active = true
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local dict, anim = "mp_character_creation@customise@male_a", "loop"
    local prop = Utils.CreateProp('prop_police_id_board', Jail.cache.pedCoords)

    Utils.AssureAnim(dict, true)

    CreateThread(function ()
        while active do
            DisableAllControlActions(0)
            DisableAllControlActions(1)
            DisableAllControlActions(2)
            Wait(0)
        end
    end)

    SetCamRot(cam, 0, 0, 270)
	SetCamCoord(cam, 1841.4134521484, 2594.3479003906, 46.714392852783)

	RenderScriptCams(true, false, 0, true, true)

    SetCamActive(cam,true)

    SetEntityCoords(Jail.cache.ped, Jail.pictureCoords.x, Jail.pictureCoords.y, Jail.pictureCoords.z)
    SetEntityHeading(Jail.cache.ped, Jail.pictureCoords.w)

    AttachEntityToEntity(prop, Jail.cache.ped, GetPedBoneIndex(Jail.cache.ped, 58868), 0.12, 0.24, 0.0, 5.0, 0.0, 70.0, true, true, false, true, 1, true)

    Wait(1000)

    Utils.FadeIn(2000)

    TaskPlayAnim(Jail.cache.ped, dict, anim, 2.0, 2.0, 5000, 1, 0, false, false, false)
    Wait(5000)
    TaskTurnPedToFaceCoord(Jail.cache.ped, 1844.1561279297, 2592.7941894531, 46.014404296875, 4800)
    Wait(1000)
    TaskPlayAnim(Jail.cache.ped, dict, anim, 2.0, 2.0, 5000, 1, 0, false, false, false)
    Wait(5000)
    TaskTurnPedToFaceCoord(Jail.cache.ped, 1844.4268798828, 2595.8078613281, 46.01441192627, 4800)
    Wait(1500)
    TaskPlayAnim(Jail.cache.ped, dict, anim, 2.0, 2.0, 5000, 1, 0, false, false, false)
    Wait(5000)

    Utils.FadeOut(1000, true)
    SetCamActive(cam,false)
    RemoveAnimDict(dict)
    DeleteEntity(prop)

    CreateThread(function()
        SetEntityCoords(Jail.cache.ped, cell_coords.x, cell_coords.y, cell_coords.z)
        SetCamCoord(cam, cell_coords.x, cell_coords.y, 1485.477993011475)
        PointCamAtCoord(cam, cell_coords.x, cell_coords.y, cell_coords.z)
        SetCamActive(cam,true)
        Utils.FadeIn(10000)
        Wait(1000)
        RenderScriptCams(false,true,10000,true,true)
        Wait(10000)
        DestroyCam(cam)
        active = false
    end)
end

function Jail.SetInJail(internal, refreshed)
    Jail.isInJail = true

    if not internal then
        Jail.JailCam()
    end

    Jail.CheckForEntityDamage()

    if refreshed then
        for k,v in pairs(Jail.jobs_zones) do
            if refreshed[k] then
                v.active = true
            end
            if v.active then
                local registered, reason = exports.plouffe_lib:Register(v)
            end
        end
    end

    return true
end

function Jail.SetOutOfJail()
    Jail.isInJail = false
    if Jail.cookie_entityDamaged then
        RemoveEventHandler(Jail.cookie_entityDamaged)
        Jail.cookie_entityDamaged = nil
    end

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
        return Interface.Notifications.Show({
            style = "info",
            header = Lang.jail_label,
            message = Lang.jail_noTrades
        })
    end

    local clicked = Interface.Menu.Open(menu)
    if not clicked then
        return
    end

    local finished = Interface.Progress.Circle({
        duration = 1500,
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {dict = "mp_common", clip = "givetake1_a"}
    })

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

    if GetResourceState('plouffe_status') == "started" then
        return exports.plouffe_status:Yoga()
    end

    -- if not IsPedActiveInScenario(Jail.cache.ped) then
    --     TaskStartScenarioInPlace(Jail.cache.ped, "WORLD_HUMAN_YOGA", 0, true)
    -- end
end

function Jail.OnClothing()
    if not Jail.isInJail then
        return
    end

    if Jail.frameWork == "esx" then
        TriggerEvent("esx_skin:openMenu", null, null)
    elseif Jail.frameWork == "qbcore" then
        TriggerEvent("qb-clothing:client:openMenu")
    elseif Jail.frameWork == "ox" then
        TriggerEvent("ox_appearance:wardrobe")
    end
end

function Jail.GuardInteraction()
    local data = Callback.Sync("plouffe_jail:getTimeLeft", Jail.auth)
    local menu = {}

    if data then
        menu[#menu+1] = {
            header = "Sentence ecouler",
            text = data.time_passed,
        }

        menu[#menu+1] = {
            header = "Sentence restante",
            text = data.time_left,
        }
    end

    if not data or data.canLeave then
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
        if not data then
            return Jail.SetOutOfJail()
        end

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

function Jail.SendToJailMenu(data)
    local target_id = data and type(data) == "table" and NetworkGetPlayerIndexFromPed(data.entity) and GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
    if not target_id then
        local target, distance = Utils.GetClosestPlayer()
        target_id = GetPlayerServerId(target)
    end

    if (target and target ~= -1 and distance <= 2.0) or (data and target_id) then
        local data = Interface.Dialog.Open({
            {
                id = "time",
                header = Lang.sentence_time,
                placeholder = Lang.minutes
            }
        })

        if not data.time then
            return
        end

        local time = tonumber(data.time)
        if not time or (time and time > Jail.maxJail) then
            return Interface.Notifications.Show({
                style = "info",
            header = Lang.jail_label,
                message = Lang.invalid_entry
            })
        end

        TriggerServerEvent("plouffe_jail:sendToJail", time, target_id, Jail.auth)
    else
        Interface.Notifications.Show({
            style = "info",
            header = Lang.jail_label,
            message = Lang.no_player_near
        })
    end
end
exports("SendToJailMenu", Jail.SendToJailMenu)

function Jail.UnjailMenu()
    local data = Interface.Dialog.Open({
        {
            id = "playerId",
            header = "Id",
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

function Jail.ComservMenu(data)
    local target_id = data and type(data) == "table" and NetworkGetPlayerIndexFromPed(data.entity) and GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
    if not target_id then
        local target, distance = Utils.GetClosestPlayer()
        target_id = GetPlayerServerId(target)
    end

    if (target and target ~= -1 and distance <= 2.0) or (data and target_id) then
        local data = Interface.Dialog.Open({
            {
                id = "amount",
                header = Lang.amount,
                placeholder = "1,2,3,4,5 ..."
            }
        })

        if not data.amount then
            return
        end

        local amount = tonumber(data.amount)
        if not amount or amount > Jail.maxSentencedComServ then
            return Interface.Notifications.Show({
                style = "info",
                header = Lang.comserv_label,
                message = Lang.invalid_entry
            })
        end

        TriggerServerEvent("plouffe_jail:sendToComserv", amount, target_id, Jail.auth)
    else
        Interface.Notifications.Show({
            style = "info",
            header = Lang.comserv_label,
            message = Lang.no_player_near
        })
    end
end
exports("ComservMenu", Jail.ComservMenu)

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

function Jail.PlantBomb()
    local pedCoords = GetEntityCoords(Jail.cache.ped)
    if #(Jail.breakOutCoords - pedCoords) > 2 then
        return
    end

    local reason = Callback.Sync("plouffe_jail:isBreakoutAvaible", Jail.auth)

    if reason then
        return Interface.Notifications.Show({
            style = "info",
            header = Lang.jail_label,
            message = reason
        })
    end

    local coords = GetOffsetFromEntityInWorldCoords(Jail.cache.ped, 0.0, 1.0, -0.6)

    CreateThread(function()
        Utils.PlayAnim(8000, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer" , 1, 3.0, 2.0, 6000, false, true, true, {model = "hei_prop_heist_thermite", bone = 28422} )
    end)

    local entity = Utils.CreateProp("hei_prop_heist_thermite",coords,0.0,true,false)
    Utils.AssureFxAsset("scr_ornate_heist")

    DetachEntity(entity,false,false)
    FreezeEntityPosition(entity, true)
    SetEntityCoords(entity, coords.x, coords.y, coords.z)

    pcall(function()
        exports.plouffe_alerts:SendAlert("IllegalActivity")
    end)

    local succes = Interface.Lines.New({
        time = 20,
        maxMoves = 7,
        points = 14
    })

    UseParticleFxAssetNextCall('scr_ornate_heist')
    local ptfx = StartNetworkedParticleFxLoopedOnEntity('scr_heist_ornate_thermal_burn', entity, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0, 2.0, false, false, false, 0)

    if succes then
        TriggerServerEvent("plouffe_jail:installed_thermite", Jail.auth)
        Wait(6000)
    else
        TriggerServerEvent("plouffe_jail:removeItem", Jail.breakout_item, Jail.auth)
    end

    Wait(2000)

    StopParticleFxLooped(ptfx, 0)
    DeleteEntity(entity)
end
exports("PlantBomb", Jail.PlantBomb)

exports.plouffe_lib:OnFrameworkLoaded(function() CreateThread(wake) end)

AddEventHandler("onResourceStop", function(resourcename)
    if resourcename == "plouffe_jail" then
        Jail.DeleteGuards()
    end
end)