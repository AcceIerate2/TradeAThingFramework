local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getPlayerBase = require(ReplicatedStorage.Shared.Gameplay.Utility.getPlayerBase)
local CollisionHandler = require(ReplicatedStorage.Shared.Utility.CollisionHandler)
return function(player: Player, character: Model)
	if not character then
		error("Character was not passed")
	end
	CollisionHandler.SetInstanceOrGroup(character, "Characters")

	local playerBase = getPlayerBase(player)
	if playerBase then
		local BaseSpawn: BasePart = playerBase:FindFirstChild("BaseSpawn") or playerBase:WaitForChild("BaseSpawn", 3)
		if BaseSpawn then
			character:PivotTo(BaseSpawn.CFrame)
		end
	end
end
