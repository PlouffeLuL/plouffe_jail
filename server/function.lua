function JailFnc:FormatIdentifier(state_id)
    return ("jail_players_%s"):format(state_id)
end

function JailFnc:IsPolice(xPlayer)
    for k,v in pairs(Jail.PoliceJobs) do
        if v == xPlayer.job.name then
            return true
        end
    end
    return false
end

function JailFnc:SendToJail(playerId, targetId, time, admin)
    local xPlayer = exports.ooc_core:getPlayerFromId(playerId)

    if (xPlayer and self:IsPolice(xPlayer)) or admin then
        local xTarget = exports.ooc_core:getPlayerFromId(targetId)
        local jailer = xPlayer and ("%s %s"):format(xPlayer.identity.firstname, xPlayer.identity.lastname) or "Inconnue"

        if xTarget then
            local releaseTime = os.time() + (time * 60)
            local identity = self:FormatIdentifier(xTarget.state_id)
            local jailData = {state_id = xTarget.state_id, releaseTime = releaseTime, jailer = jailer}
            
            TriggerClientEvent("plouffe_jail:sentToJail", targetId,  math.ceil((releaseTime - os.time()) / 60))

            SetResourceKvp(identity, json.encode(jailData))

            exports.plouffe_reputations:AddReputation(playerId,"police",1)
            exports.plouffe_reputations:RemoveReputation(targetId,"police",5)
        end
    end
end

function JailFnc:UnJailPlayer(playerId, targetId, admin)
    local xPlayer = exports.ooc_core:getPlayerFromId(playerId)

    if (xPlayer and self:IsPolice(xPlayer)) or admin then
        local xTarget = exports.ooc_core:getPlayerFromId(targetId)

        if xTarget then
            local identity = self:FormatIdentifier(xTarget.state_id)
            local jailData = json.decode(GetResourceKvpString(identity))

            if jailData then
                Server.playerJobs[xTarget.playerId] = nil
                TriggerClientEvent("plouffe_jail:unjail",targetId)
                DeleteResourceKvp(identity)
            end
        end
    end
end

function JailFnc:RequestPlayerRelease(playerId)
    local xPlayer = exports.ooc_core:getPlayerFromId(playerId)
    local identity = self:FormatIdentifier(xPlayer.state_id)
    local jailData = json.decode(GetResourceKvpString(identity))

    if jailData and jailData.releaseTime - os.time() <= 0 then
        Server.playerJobs[xPlayer.playerId] = nil
        DeleteResourceKvp(identity)
        TriggerClientEvent("plouffe_jail:unjail",playerId)
    end

end

function JailFnc:GenerateNewjobForPlayer(playerId)
    if Server.playerJobs[playerId] and os.time() - Server.playerJobs[playerId].requestTime <= Server.requestDelay then
        TriggerClientEvent('plouffe_lib:notify', playerId, { type = 'error', text = "Vous avez déja demander un travail dernierement", length = 7000})
        return
    end

    local randi = math.random(1,Utils:GetArrayLength(Jail.Work))
    local num = 0
    local index = nil

    for k,v in pairs(Jail.Work) do
        num = num + 1
        if num == randi then
            index = k
            break
        end
    end

    Server.playerJobs[playerId] = {
        job = index,
        requestTime = os.time()
    }

    TriggerClientEvent("plouffe_jail:activatework", playerId, Server.playerJobs[playerId])
end

function JailFnc:ReduceJobTime(playerId,params)
    if os.time() - Jail.Work[params.jobIndex].zones[params.zoneIndex].info.doneTime >= Jail.Work[params.jobIndex].coolDown then
        Jail.Work[params.jobIndex].zones[params.zoneIndex].info.doneTime = os.time()
        
        local xPlayer = exports.ooc_core:getPlayerFromId(playerId)
        local timeReduction = math.random(Jail.Work[params.jobIndex].timeReduction.min,Jail.Work[params.jobIndex].timeReduction.max)
        local identity = self:FormatIdentifier(xPlayer.state_id)
        local jailData = json.decode(GetResourceKvpString(identity))

        if jailData then
            if jailData.releaseTime - os.time() > 0 then
                jailData.releaseTime = jailData.releaseTime - (timeReduction * 60)

                SetResourceKvp(identity, json.encode(jailData))
                TriggerClientEvent('plouffe_lib:notify', playerId, { type = 'success', text = "Vous avez eu une reduction de temp de: "..tostring(timeReduction).." mois pour votre bon travail", length = 7000})
                exports.plouffe_reputations:AddReputation(playerId,"prisoner",timeReduction)
            else
                TriggerClientEvent('plouffe_lib:notify', playerId, { type = 'success', text = "Vous n'avez plus de temp a faire", length = 7000})
            end
        end
    else
        TriggerClientEvent('plouffe_lib:notify', playerId, { type = 'error', text = "Ce travail a déja été fait dernierement", length = 7000})
    end
end

function JailFnc:GetExchangeables(playerId)
    local data = {}
    local repData = exports.plouffe_reputations:GetReputation(playerId,"prisoner")

    for k,v in pairs(Jail.BuyablesItem) do
        if repData.current >= v.price then
            data[k] = v
        end
    end

    return data
end

function JailFnc:TryToExchangeItem(playerId,item)
    if Jail.BuyablesItem[item] then
        local repData = exports.plouffe_reputations:GetReputation(playerId,"prisoner")
        if repData.current >= Jail.BuyablesItem[item].price then
            exports.plouffe_reputations:RemoveReputation(playerId,"prisoner",Jail.BuyablesItem[item].price)
            exports.ooc_core:addItem(playerId,item,1)
        end
    end
end

function AdminSendToJail(playerId, time)
    JailFnc:SendToJail(nil, playerId, time, true)
end

function AdminRemoveFromJail(playerId)
    JailFnc:UnJailPlayer(nil, playerId, true)
end