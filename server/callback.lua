Callback:RegisterServerCallback("plouffe_jail:getTimeLeft", function(source, cb, authkey)
    local _source = source 
    if Auth:Validate(_source,authkey) == true then
        if Auth:Events(_source,"plouffe_jail:getTimeLeft") == true then
            local xPlayer = exports.ooc_core:getPlayerFromId(_source)
            local identity = JailFnc:FormatIdentifier(xPlayer.state_id)
            local jailData = json.decode(GetResourceKvpString(identity))

            if jailData then
                cb(jailData.releaseTime - os.time())
            else
                cb(0)
            end
        end
    end
end)

Callback:RegisterServerCallback("plouffe_jail:CanEscape", function(source, cb, authkey)
    local _source = source 
    if Auth:Validate(_source,authkey) == true then
        if Auth:Events(_source,"plouffe_jail:CanEscape") == true then
            cb(false)            
        end
    end
end)

Callback:RegisterServerCallback("plouffe_jail:isJobOnCoolDown", function(source, cb, params, authkey)
    local _source = source 
    if Auth:Validate(_source,authkey) == true then
        if Auth:Events(_source,"plouffe_jail:isJobOnCoolDown") == true then
            cb(os.time() - Jail.Work[params.jobIndex].zones[params.zoneIndex].info.doneTime >= Jail.Work[params.jobIndex].coolDown)            
        end
    end
end)

Callback:RegisterServerCallback("plouffe_jail:getExchangeable", function(source, cb, authkey)
    local _source = source 
    if Auth:Validate(_source,authkey) == true then
        if Auth:Events(_source,"plouffe_jail:getExchangeable") == true then
            cb(JailFnc:GetExchangeables(source))            
        end
    end
end)