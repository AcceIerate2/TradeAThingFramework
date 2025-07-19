local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TypeCheck = require(ReplicatedStorage.Shared.Utility.TypeCheck)

return function(player: Player): Model
	if not player or not player:IsA("Player") then
		error("Could not get player!")
	end

	local playerBaseNumber = player:GetAttribute("baseNumber") :: number
	if not TypeCheck.number(playerBaseNumber) then
		error("playerBaseNumber is not a valid number!")
	end

	local playerBase = workspace.Bases:FindFirstChild(`base_{playerBaseNumber}`)
	if not playerBase then
		error("Could not get base model!")
	end

	return playerBase :: Model
end
