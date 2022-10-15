local Callback = exports.plouffe_lib:Get("Callback")
local Utils = exports.plouffe_lib:Get("Utils")

local function wake()
    local list = Callback.Sync("plouffe_jail:loadPlayer")
    for k,v in pairs(list) do
        Jail[k] = v
    end

    -- exports.plouffe_lib:OnFrameworkLoaded(Jail.Start)
end

CreateThread(wake)