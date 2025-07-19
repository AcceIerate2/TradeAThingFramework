local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JSONHandler = require(ReplicatedStorage.Shared.Utility.JSONHandler)
local InventoryService = require(script.Parent.InventoryService)
local placedCharacterService = require(script.Parent.placedCharacterService)
local TypeCheck = require(ReplicatedStorage.Shared.Utility.TypeCheck)
local eventListener = require(ReplicatedStorage.Shared.Utility.eventListener)

local Module = {}

function Module.listenToClients()
	eventListener.listenToRemoteEvent("placeCharacter", function(player: Player, toolName: string, position: Vector3)
		local validString = TypeCheck.string(toolName)
		if not validString then
			return
		end

		local validPosition = TypeCheck.Vector3(position)
		if not validPosition then
			return
		end

		local ownsTool = InventoryService.ownsTool(player, toolName)
		if not ownsTool then
			error(`{player.Name} does not own tool: {toolName}.`)
		end

		placedCharacterService.add(player, toolName, position)

		local playerCharacter = player.Character
		if not playerCharacter then
			return
		end

		local tool = playerCharacter:FindFirstChild(toolName) :: Tool
		if tool then
			local Inventory = player:FindFirstChild("Inventory")
			if Inventory then
				Inventory.Value = JSONHandler.Remove(Inventory.Value, nil, tool.Name)
			end
			tool:Destroy()
		end
	end)
end

function Module.loadPlayerTools(player: Player)
	local Inventory = player:FindFirstChild("Inventory") or player:WaitForChild("Inventory", 3)
	local decoded = HttpService:JSONDecode(Inventory.Value)
	for _index: number, toolName: string in pairs(decoded) do
		local tool = ReplicatedStorage.Tools:FindFirstChild(toolName) :: Tool
		if not tool then
			continue
		end
		local clonedTool = tool:Clone() :: Tool
		clonedTool.Parent = player.Backpack
	end
end

return Module
