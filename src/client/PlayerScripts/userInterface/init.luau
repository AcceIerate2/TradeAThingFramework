local Players = game:GetService("Players")
local setup = require(script.setup)
return function()
	local player = Players.LocalPlayer
	local playerGui = player.PlayerGui
	setup(player, playerGui)
end
