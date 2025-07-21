local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getPlayerBase = require(ReplicatedStorage.Shared.Gameplay.Utility.getPlayerBase)
return function(landFolder)
	if not landFolder then
		local player = Players.LocalPlayer
		local playerBase = getPlayerBase(player) :: Model
		if not playerBase then
			error("Could not get base from player: " .. player.Name .. "!")
		end
		landFolder = playerBase:FindFirstChild("Land") or playerBase:WaitForChild("Land", 3)
	end

	if not landFolder then
		error("Could not get LandFolder under plot!")
	end

	local hasHighlight = landFolder:FindFirstChild("Highlight", true)
	if hasHighlight then
		hasHighlight:Destroy()
	end
end
