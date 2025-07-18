local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JSONHandler = require(ReplicatedStorage.Shared.Utility.JSONHandler)
local Module = {}

function Module.removeFromInventory(player: Player, items: { string })
	local playerBackpack = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack", 3)
	if not playerBackpack then
		error("Player backpack not found.")
	end

	local character = player.Character
	if not character then
		error("Player character not found.")
	end

	local playerInventory = player:FindFirstChild("Inventory") or player:WaitForChild("Inventory", 3)
	if not playerInventory then
		error("Player inventory not found.")
	end

	for _, itemName in ipairs(items) do
		local tool = playerBackpack:FindFirstChild(itemName) or character:FindFirstChild(itemName)
		if tool then
			tool:Destroy()
		else
			error("Tool '" .. itemName .. "' not found in player's backpack or character.")
		end
		playerInventory.Value = JSONHandler.Remove(playerInventory.Value, nil, itemName)
	end
end

function Module.addToInventory(player: Player, items: { string })
	local playerBackpack = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack", 3)
	if not playerBackpack then
		error("Player backpack not found.")
	end

	local character = player.Character
	if not character then
		error("Player character not found.")
	end

	local playerInventory = player:FindFirstChild("Inventory") or player:WaitForChild("Inventory", 3)
	if not playerInventory then
		error("Player inventory not found.")
	end

	for _, itemName in ipairs(items) do
		local tool = ReplicatedStorage.Tools:FindFirstChild(itemName)
		if tool then
			local clonedTool = tool:Clone()
			clonedTool.Parent = playerBackpack
			playerInventory.Value = JSONHandler.Insert(playerInventory.Value, nil, itemName)
		else
			error("Tool '" .. itemName .. "' not found in ReplicatedStorage.Tools.")
		end
	end
end

return Module
