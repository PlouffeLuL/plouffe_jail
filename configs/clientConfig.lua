Jail = {}
JailFnc = {} 
TriggerServerEvent("plouffe_jail:sendConfig")

RegisterNetEvent("plouffe_jail:getConfig",function(list)
	if list == nil then
		CreateThread(function()
			while true do
				Wait(0)
				Jail = nil
				JailFnc = nil
			end
		end)
	else
		Jail = list
		JailFnc:Start()
	end
end)