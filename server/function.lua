local Auth <const> = exports.plouffe_lib:Get("Auth")
local Callback <const> = exports.plouffe_lib:Get("Callback")
local Utils <const> = exports.plouffe_lib:Get("Utils")
local Inventory <const> = exports.plouffe_lib:Get("Inventory")
local Uniques <const> = exports.plouffe_lib:Get("Uniques")

function Jail:GetData(key)
    local retval = {auth = key}

    for k,v in pairs(self) do
        if type(v) ~= "function" then
            retval[k] = v
        end
    end

    return retval
end

Callback.Register("plouffe_jail:loadPlayer", function(playerId)
    local registred, key = Auth.Register(playerId)

    if not registred then
        return DropPlayer(" ")
    end

    while not ready do
        Wait(1000)
    end

    return Weap:GetData(key)
end)