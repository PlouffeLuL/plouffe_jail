local Callback = exports.plouffe_lib:Get("Callback")
local Utils = exports.plouffe_lib:Get("Utils")

function JailFnc:Start()
    TriggerEvent('ooc_core:getCore', function(Core)
        while not Core.Player:IsPlayerLoaded() do
            Wait(500)
        end

        Jail.Player = Core.Player:GetPlayerData()

        self:RegisterallEvents()
        self:ExportsAllZones()
    end)
end

function JailFnc:ExportsAllZones()
    for k,v in pairs(Jail.Coords) do
        exports.plouffe_lib:ValidateZoneData(v)
    end
end

function JailFnc:RegisterallEvents()
    AddStateBagChangeHandler("dead", ("player:%s"):format(GetPlayerServerId(PlayerId())), function(bagName,key,value,reserved,replicated)
        if value and exports.plouffe_lib:IsInZone("prisonZone") then
            self:JailRevive()
        end
    end)

    AddEventHandler('plouffe_lib:setGroup', function(data)
        Jail.Player[data.type] = data
    end)

    RegisterNetEvent("on_jail_event", function(p)
        if p.type == "menu" then
            self:OpenMenu(p.menu)
        elseif p.type == "action" then
            if self[p.fnc] then
                self[p.fnc](self,p)
            end
        end
    end)

    RegisterNetEvent("plouffe_jail:sentToJail", function(time)
        self:SentToJail(time)
    end)

    RegisterNetEvent("plouffe_jail:unjail", function()
        self:RemoveFromJail()
    end)

    RegisterNetEvent("plouffe_jail:outOfPrison", function()
        self:OutOfJailZone()
    end)

    RegisterNetEvent("plouffe_jail:activatework", function(info)
        if Jail.Utils.inJail then
            self:ActivateWork(info)
        end
    end)

    RegisterNetEvent("plouffe_jail:outPrisonZoneBig", function()
        self:DeleteAllGuards()
    end)

    RegisterNetEvent("plouffe_jail:inPrisonZoneBig", function()
        self:SpawnAllGuards()
    end)

    RegisterNetEvent("plouffe_jail:leftStupidSpot", function()
        Jail.Utils.iAmStupid = false
    end)

    RegisterNetEvent("plouffe_jail:enteredStupidSpot", function()
        self:ActivateStupid()
    end)
end

function JailFnc:SpawnAllGuards()
    for k,v in pairs(Jail.Guards) do
        if not DoesEntityExist(v.pedId) then
            local coords = vector3(v.coords.x,v.coords.y,v.coords.z - 1)
            v.pedId = Utils:SpawnPed(v.model,coords,v.heading,false,false)
            Wait(50)
            GiveWeaponToPed(v.pedId, GetHashKey(v.weapon), 999, false, true)
            FreezeEntityPosition(v.pedId, true)
            SetEntityInvincible(v.pedId, true)
        end
    end
end

function JailFnc:DeleteAllGuards()
    for k,v in pairs(Jail.Guards) do
        DeleteEntity(v.pedId)
        v.pedId = 0
    end
end

function JailFnc:IsPolice()
    for k,v in pairs(Jail.PoliceJobs) do
        if v == Jail.Player.job.name then
            return true
        end
    end
    return false
end

function JailFnc:OpenMenu(menu)
    exports.ooc_menu:Open(Jail.Menu[menu], function(params)
        if not params then
            return
        end

        self[params.fnc](self)
    end)
end

function JailFnc:JailClosestPlayer()
    if self:IsPolice() then
        local closestPlayer, distance = Utils:GetClosestPlayer()
        if closestPlayer and distance <= 2.0 then
            local closestPlayerId = GetPlayerServerId(closestPlayer)
            exports.ooc_dialog:Open({
                rows = {
                    {
                        id = 0,
                        txt = "Duré "
                    }
                }
            }, function(data)
                if not data then return end

                if not data[1].input or not tonumber(data[1].input) then
                    return Utils:Notify("error", "Informations invalide", 5000)
                end

                local time = math.ceil(tonumber(data[1].input))
                if time then
                    TriggerServerEvent("plouffe_jail:SendPlayerToJail", closestPlayerId, time,Jail.Utils.MyAuthKey)
                end
            end)
        else
            Utils:Notify("error", "Il n'y a personne près")
        end
    end
end

function JailFnc:UnJailPlayer()
    if self:IsPolice() then
        exports.ooc_dialog:Open({
            rows = {
                {
                    id = 0,
                    txt = "Id du joueur "
                }
            }
        }, function(data)
            if not data then return end

            if not data[1].input or not tonumber(data[1].input) then
                return Utils:Notify("error", "Informations invalide", 5000)
            end

            local id = tonumber(data[1].input)

            if id then
                TriggerServerEvent("plouffe_jail:UnjailPlayer",id,Jail.Utils.MyAuthKey)
            end
        end)
    end
end

function JailFnc:SentToJail(time)
    Jail.Utils.ped = PlayerPedId()
    Jail.Utils.pedCoords = GetEntityCoords(Jail.Utils.ped)
    Jail.Utils.inJail = true
    SetEntityCoords(Jail.Utils.ped, Jail.Entry.coords)
    SetEntityHeading(Jail.Utils.ped, Jail.Entry.heading)
    TriggerEvent("InteractSound_CL:PlayOnOne", "cell", 0.2)
    exports.plouffe_doj:SetHandCuffs(false)
    Utils:Notify("error", "Vous avez été emprisonner pour: "..tostring(time).." mois")
end

function JailFnc:RemoveFromJail()
    Jail.Utils.ped = PlayerPedId()
    Jail.Utils.pedCoords = GetEntityCoords(Jail.Utils.ped)
    Jail.Utils.inJail = false
    SetEntityCoords(Jail.Utils.ped, Jail.Out.coords)
    SetEntityHeading(Jail.Utils.ped, Jail.Out.heading)

    if Jail.Utils.currentWork then
        for k,v in pairs(Jail.Work[Jail.Utils.currentWork].zones) do
            exports.plouffe_lib:DestroyZone(v.name)
        end
    end
end

function JailFnc:GetReleaseTime()
    Callback:Await("plouffe_jail:getTimeLeft", function(timeLeft)
        if timeLeft > 0 then
            exports.ooc_menu:Open({
                {
                    id = 1,
                    header = "Vous etes toujours emprisoner",
                    txt = "Temp restant: ".. tostring(math.ceil(timeLeft / 60)).. " mois",
                    params = {
                        args = {}
                    }
                }
            }, function(params) end)
        else
            exports.ooc_menu:Open({
                {
                    id = 1,
                    header = "Vous n'avez plus de temp a faire",
                    txt = "Cliquer pour sortir",
                    params = {
                        args = {}
                    }
                }
            }, function(params) self:RequestRelease() end)
        end
    end, Jail.Utils.MyAuthKey)
end

function JailFnc:RequestRelease()
    TriggerServerEvent("plouffe_jail:RequestRelease", Jail.Utils.MyAuthKey)
end

function JailFnc:ReJail(time)
    Jail.Utils.ped = PlayerPedId()
    Jail.Utils.inJail = true
    SetEntityCoords(Jail.Utils.ped, Jail.Entry.coords)
    SetEntityHeading(Jail.Utils.ped, Jail.Entry.heading)
end

function JailFnc:OutOfJailZone()
    if Jail.Utils.inJail then
        Callback:Await("plouffe_jail:CanEscape", function(canEscape)
            if not canEscape then
                JailFnc:ReJail()
            -- else
            --     -- Prison Escape to do
            end
        end, Jail.Utils.MyAuthKey)
    end
end

function JailFnc:ActivateWork(data)
    if Jail.Utils.currentWork then
        for k,v in pairs(Jail.Work[Jail.Utils.currentWork].zones) do
            exports.plouffe_lib:DestroyZone(v.name)
        end
    end

    Jail.Utils.currentWork = data.job

    for k,v in pairs(Jail.Work[Jail.Utils.currentWork].zones) do
        exports.plouffe_lib:ValidateZoneData(v)
    end

    Utils:Notify("inform","Votre nouveau travail est: "..Jail.Work[Jail.Utils.currentWork].label, 6500)
end

function JailFnc:JailWork(params)
    if LocalPlayer.state.dead or LocalPlayer.state.cuffed then
        return
    end

    if Jail.Utils.inJail then
        if Jail.Utils.jobCoolDown then
            Utils:Notify("error","Vous avez annuler votre dernier travail vous devez donc attendre avant de pouvoir travailler a nouveau", 6500)
            return
        end

        if Jail.Utils.softCoolDown then
            return
        end

        self:CoolDown(2000)

        Callback:Await("plouffe_jail:isJobOnCoolDown", function(hasAcces)
            if hasAcces then
                ExecuteCommand(Jail.Work[params.jobIndex].command)

                Utils:ProgressCircle({
                    name = "jail_work",
                    duration = math.ceil(math.random(Jail.Work[params.jobIndex].timeToWork.min,Jail.Work[params.jobIndex].timeToWork.max)),
                    label = "Travail en cours..",
                    useWhileDead = false,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }
                }, function(cancelled)
                    ExecuteCommand("e c")
                    if not cancelled then
                        TriggerServerEvent("plouffe_jail:finishedWork",params,Jail.Utils.MyAuthKey)
                    else
                        self:SetJobCoolDown()
                    end
                end)
            else
                Utils:Notify("error","Ce travail na pas besoin d'etre fait présentement", 6500)
            end
        end, params, Jail.Utils.MyAuthKey)
    end
end

function JailFnc:SetJobCoolDown()
    if Jail.Utils.jobCoolDown then
        return
    end

    Jail.Utils.jobCoolDown = true

	CreateThread(function()
        Wait(Jail.Utils.jobCoolDownTime)
        Jail.Utils.jobCoolDown = false
    end)
end

function JailFnc:CoolDown(time)
    if Jail.Utils.softCoolDown then
        return
    end

    Jail.Utils.softCoolDown = true

	CreateThread(function()
        Wait(time)
        Jail.Utils.softCoolDown = false
    end)
end

function JailFnc:GetNewJob()
    TriggerServerEvent("plouffe_jail:getNewJob", Jail.Utils.MyAuthKey)
end

function JailFnc:ExchangeMenu()
    if Jail.Utils.softCoolDown then
        return
    end

    self:CoolDown(1000)

    Callback:Await("plouffe_jail:getExchangeable", function(data)
        if Utils:TableLen(data) > 0 then
            local menuData = {}
            local id = 0

            for k,v in pairs(data) do
                id = id + 1
                table.insert(menuData,
                    {
                        id = id,
                        header = v.label,
                        txt = "Echanger "..tostring(v.price).." points de réputation pour cette item",
                        params = {
                            args = {
                                fnc = "TryToExchangeItem",
                                item = k
                            }
                        }
                    }
                )
            end

            local data = exports.ooc_menu:Open(menuData)

            if not data then
                return
            end

            TriggerServerEvent("plouffe_jail:tryToExchangeItem", data.item, Jail.Utils.MyAuthKey)
        else
            Utils:Notify("error", "Les prisoniers n'ont rien a vous offrir")
        end
    end, Jail.Utils.MyAuthKey)
end

function JailFnc:ActivateStupid()
    if Jail.Utils.iAmStupid then
        return
    end

    Jail.Utils.iAmStupid = true

    CreateThread(function()
        local isShooting = false

        while Jail.Utils.iAmStupid do
            local sleepTimer = 5000

            Jail.Utils.ped = PlayerPedId()

            if LocalPlayer.state.dead and isShooting then
                isShooting = false

                for k,v in pairs(Jail.Guards) do
                    ClearPedTasks(v.pedId)
                end
            end

            if not LocalPlayer.state.dead then
                isShooting = true
                for k,v in pairs(Jail.Guards) do
                    TaskShootAtEntity(v.pedId, Jail.Utils.ped, 5000, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
                end
            end

            Wait(sleepTimer)
        end

        for k,v in pairs(Jail.Guards) do
            ClearPedTasks(v.pedId)
        end
    end)
end

function JailFnc:GetFirstBed()
    Jail.Utils.ped = PlayerPedId()
    Jail.Utils.pedCoords = GetEntityCoords(Jail.Utils.ped)

    for k,v in pairs(Jail.Beds.list) do
        local rayHandle = StartShapeTestCapsule(Jail.Utils.pedCoords, v.coords, 2.0, 12, Jail.Utils.ped, 7)
        local _, _, _, _, ped = GetShapeTestResult(rayHandle)

        if ped == 0 then
            return v
        end
    end

    return Jail.Beds.default
end

function JailFnc:JailRevive()
    local breakTime = GetGameTimer()
    local bed = self:GetFirstBed()

    Jail.Utils.ped = PlayerPedId()

    DoScreenFadeOut(2000)
    while not IsScreenFadedOut() and GetGameTimer() - breakTime < 10000 do
        Wait(100)
    end

    TriggerEvent('plouffe_status:respawn:spawn')

    Wait(1000)

    SetEntityCoords(Jail.Utils.ped, bed.coords)
    SetEntityHeading(Jail.Utils.ped, bed.heading)
    ClearPedTasksImmediately(Jail.Utils.Ped)

    Utils:ProgressCircle({
        name = "PrisonRevive",
        duration = 60000 * 5,
        label = 'Réanimation',
        useWhileDead = true,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "anim@gangops@morgue@table@",
            anim = "ko_front",
            flags = 1,
        }
    }, function(cancelled)
        if cancelled then
            SetEntityHealth(PlayerPedId(),0)
        end
    end)

    DoScreenFadeIn(10000)
end