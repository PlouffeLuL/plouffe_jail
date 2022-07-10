RegisterNetEvent("plouffe_jail:sendConfig",function()
    local playerId = source
    local registred, key = Auth:Register(playerId)

    if registred then
        local cbArray = Jail
        cbArray.Utils.MyAuthKey = key
        TriggerClientEvent("plouffe_jail:getConfig",playerId,cbArray)
    else
        TriggerClientEvent("plouffe_jail:getConfig",playerId,nil)
    end
end)

RegisterNetEvent("plouffe_jail:SendPlayerToJail",function(target,time,authkey)
    local _source = source
    if Auth:Validate(_source,authkey) == true then
        if Auth:Events(_source,"plouffe_jail:SendPlayerToJail") == true then
            JailFnc:SendToJail(_source, target, time)
        end
    end
end)

RegisterNetEvent("plouffe_jail:UnjailPlayer", function(targetId,authkey)
    local _source = source
    if Auth:Validate(_source,authkey) == true then
        if Auth:Events(_source,"plouffe_jail:UnjailPlayer") == true then
            JailFnc:UnJailPlayer(_source, targetId)
        end
    end
end)

RegisterNetEvent("plouffe_jail:RequestRelease", function(authkey)
    local _source = source
    if Auth:Validate(_source,authkey) == true then
        if Auth:Events(_source,"plouffe_jail:RequestRelease") == true then
            JailFnc:RequestPlayerRelease(_source)
        end
    end
end)

RegisterNetEvent("plouffe_jail:getNewJob", function(authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) == true then
        if Auth:Events(playerId,"plouffe_jail:getNewJob") == true then
            JailFnc:GenerateNewjobForPlayer(playerId)
        end
    end
end)

RegisterNetEvent("plouffe_jail:finishedWork", function(params,authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) == true then
        if Auth:Events(playerId,"plouffe_jail:finishedWork") == true then
            JailFnc:ReduceJobTime(playerId,params)
        end
    end
end)

RegisterNetEvent("ooc_core:playerloaded", function(player)
    local identity = JailFnc:FormatIdentifier(player.state_id)
    local jailData = json.decode(GetResourceKvpString(identity))

    if jailData then
        Wait(10000)
        TriggerClientEvent("plouffe_jail:sentToJail", player.playerId, math.ceil((jailData.releaseTime - os.time()) / 60))
    end
end)

RegisterNetEvent("plouffe_jail:tryToExchangeItem", function(item,authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) == true then
        if Auth:Events(playerId,"plouffe_jail:tryToExchangeItem") == true then
            JailFnc:TryToExchangeItem(playerId,item)
        end
    end
end)

AddEventHandler('playerDropped', function(reason)
    local _source = source
    Server.playerJobs[_source] = nil
end)