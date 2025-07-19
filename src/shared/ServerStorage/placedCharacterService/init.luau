local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getPlayerBase = require(ReplicatedStorage.Shared.Gameplay.Utility.getPlayerBase)
local InstanceCreator = require(ReplicatedStorage.Shared.Utility.InstanceCreator)
local JSONHandler = require(ReplicatedStorage.Shared.Utility.JSONHandler)
local stringToVector3 = require(ReplicatedStorage.Shared.Utility.stringToVector3)
local vector3ToString = require(ReplicatedStorage.Shared.Utility.vector3ToString)

local ToolFolder = ReplicatedStorage.Tools

local Module = {}

function Module.replaceCharacterWithTool(player: Player, characterModel: Model)
	if not player or not characterModel then
		return
	end

	Module.remove(player, characterModel.Name, characterModel)

	local tool = ToolFolder:FindFirstChild(characterModel.Name)
	if not tool then
		return
	end

	local playerInventory = player:FindFirstChild("Inventory")
	playerInventory.Value = JSONHandler.Insert(playerInventory.Value, nil, tool.Name)

	local clonedTool = tool:Clone() :: Tool
	clonedTool.Parent = player.Backpack :: Backpack
end

function Module.setupCharacter(player: Player, characterModel: Model)
	local primaryPart = characterModel.PrimaryPart
	local newProximityPrompt = InstanceCreator("ProximityPrompt", "ProximityPrompt", primaryPart) :: ProximityPrompt

	newProximityPrompt.RequiresLineOfSight = false
	newProximityPrompt.ActionText = "Pick Up"

	local _Connection = nil
	_Connection = newProximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		if playerWhoTriggered == player then
			_Connection:Disconnect()
			_Connection = nil
			Module.replaceCharacterWithTool(player, characterModel)
		end
	end)
end

function Module.placeCharacter(placedCharacterName: string, position: Vector3, baseCharacters: Folder | Model)
	local character = ReplicatedStorage.Characters:FindFirstChild(placedCharacterName) :: Model | nil
	if not character then
		return
	end
	local clonedCharacter = character:Clone() :: Model
	clonedCharacter:PivotTo(CFrame.new(position))
	clonedCharacter.Parent = baseCharacters

	local base = baseCharacters.Parent

	local baseOwner = base.Owner.Value

	Module.setupCharacter(baseOwner, clonedCharacter)
end

function Module.load(player: Player)
	local placedCharacters = player:FindFirstChild("placedCharacters") or player:WaitForChild("placedCharacters", 3)
	if not placedCharacters then
		return
	end

	local playerBase = getPlayerBase(player)
	local baseCharacters = playerBase:FindFirstChild("placedCharacters")

	local decoded = HttpService:JSONDecode(placedCharacters.Value)

	for position: string, placedCharacterName: string in pairs(decoded) do
		Module.placeCharacter(placedCharacterName, stringToVector3(position), baseCharacters)
	end
end

function Module.add(player: Player, characterName: string, position: Vector3)
	local placedCharacters = player:FindFirstChild("placedCharacters") or player:WaitForChild("placedCharacters", 3)
	if not placedCharacters then
		return
	end

	placedCharacters.Value = JSONHandler.Insert(placedCharacters.Value, vector3ToString(position), characterName)

	local playerBase = getPlayerBase(player)
	local baseCharacters = playerBase:FindFirstChild("placedCharacters")

	Module.placeCharacter(characterName, position, baseCharacters)
end

function Module.remove(player: Player, characterName: string, characterModel: Model)
	local placedCharacters = player:FindFirstChild("placedCharacters") or player:WaitForChild("placedCharacters", 3)
	if not placedCharacters then
		return
	end

	placedCharacters.Value =
		JSONHandler.Remove(placedCharacters.Value, vector3ToString(characterModel:GetPivot().Position), characterName)
	characterModel:Destroy()
end

return Module
