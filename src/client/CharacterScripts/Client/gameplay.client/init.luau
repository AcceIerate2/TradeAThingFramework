local Players = game:GetService("Players")
local player = Players.LocalPlayer

return function()
	require(script["toolService.client"])(player)
end
