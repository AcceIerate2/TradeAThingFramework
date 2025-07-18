local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryService = require(script.Parent.InventoryService)
local TypeCheck = require(ReplicatedStorage.Shared.Utility.TypeCheck)
local Module = {}

local ToolFolder = ReplicatedStorage:FindFirstChild("Tools")
	or ReplicatedStorage:WaitForChild("Tools", 3) :: Folder & { Tool }

function Module.getAffordableItems(player: Player, budget: number)
	if not player then
		error("Invalid player provided.")
	end

	if not TypeCheck.number(budget) or budget <= 0 then
		error("Invalid budget provided. Must be a positive number.")
	end

	local affordableTools = {}

	local children = ToolFolder:GetChildren()
	for _index: number, tool in pairs(children) do
		local isATool = tool:IsA("Tool") :: boolean
		if not isATool then
			continue
		end

		local toolPrice = tool:GetAttribute("Price")
		if not TypeCheck.number(toolPrice) then
			continue
		end

		if budget < toolPrice then
			continue
		end

		local amountCanAfford = budget / toolPrice
		if amountCanAfford >= 1 then
			affordableTools[tool.Name] = math.floor(amountCanAfford)
		end
	end

	return affordableTools
end

function Module.calculateTotalWorth(tradeData: { string }): number
	local totalWorth = 0
	for _, toolName in ipairs(tradeData) do
		local tool = ToolFolder:FindFirstChild(toolName)
		local toolPrice = tool:GetAttribute("Price")
		if toolPrice and type(toolPrice) == "number" then
			totalWorth += toolPrice
		else
			error("Tool does not have a valid 'Price' attribute.")
		end
	end
	return totalWorth
end

function Module.trade(player: Player, tradeData: { ["toTradeWith"]: { string }, ["toGet"]: { string } })
	if not player or not player:IsA("Player") then
		error("Invalid player provided for trade.")
	end

	local validTradeData = TypeCheck.table(tradeData)
	if not validTradeData then
		error("Invalid trade data provided. Expected a table of Instance objects.")
	end

	local toTradeWith = tradeData.toTradeWith
	if not TypeCheck.table(toTradeWith) then
		error("Invalid 'toTradeWith' data provided. Expected a non-empty table of tool names.")
	end

	local totalWorth = Module.calculateTotalWorth(toTradeWith)
	if totalWorth <= 0 then
		error("Trade cannot proceed. Total worth of items is zero or negative.")
	end

	local affordableItems = Module.getAffordableItems(player, totalWorth)
	if not next(affordableItems) then
		error("No affordable items found for the player with the given budget.")
	end

	local toGet = tradeData.toGet
	if not TypeCheck.table(toGet) then
		error("Invalid 'toGet' data provided. Expected a non-empty table of tool names.")
	end

	local toolsToGive = {} :: { string }

	for _, itemName in ipairs(toGet) do
		if not affordableItems[itemName] then
			continue
		end
		local itemCount = affordableItems[itemName] :: number
		if itemCount <= 0 then
			continue
		end

		table.insert(toolsToGive, itemName)
	end

	if #toolsToGive == 0 then
		error("No valid tools to give in the trade.")
	end

	InventoryService.removeFromInventory(player, toTradeWith)
	InventoryService.addToInventory(player, toolsToGive)

	return true, "Trade successful!", Color3.fromRGB(0, 255, 0), toolsToGive
end

return Module
