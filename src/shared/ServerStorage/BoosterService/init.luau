local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getPlayerBase = require(ReplicatedStorage.Shared.Gameplay.Utility.getPlayerBase)
local AnchorHandler = require(ReplicatedStorage.Shared.Utility.AnchorHandler)
local JSONHandler = require(ReplicatedStorage.Shared.Utility.JSONHandler)
local stringToVector3 = require(ReplicatedStorage.Shared.Utility.stringToVector3)
local vector3ToString = require(ReplicatedStorage.Shared.Utility.vector3ToString)
local BoosterFolder = ReplicatedStorage:FindFirstChild("Boosters") or ReplicatedStorage:WaitForChild("Boosters", 3)

local Module = {}

function Module.placeBooster(player: Player, boosterName: string, position: Vector3)
	local placedBoosters = player:FindFirstChild("placedBoosters") or player:WaitForChild("placedBoosters", 3)
	if not placedBoosters then
		error("Could not get placedBoosters under Player: " .. player.Name .. "!")
	end

	local booster = BoosterFolder:FindFirstChild(boosterName) or BoosterFolder:WaitForChild(boosterName, 3)
	if not booster then
		error(`{boosterName} does not exist under {BoosterFolder.Name}!`)
	end

	placedBoosters.Value = JSONHandler.Insert(placedBoosters.Value, vector3ToString(position), { boosterName })

	local newBooster = booster:Clone() :: Model
	AnchorHandler(newBooster, true)
	newBooster:PivotTo(CFrame.new(position))
	newBooster.Parent = getPlayerBase(player):FindFirstChild("placedBoosters")

	local duration = newBooster:GetAttribute("Duration") :: number
	local boosterType = newBooster:GetAttribute("Type") :: string
end

-- Work in progress
function Module.load(player: Player)
	local placedBoosters = player:FindFirstChild("placedBoosters") or player:WaitForChild("placedBoosters", 3)
	if not placedBoosters then
		error("Could not get placedBoosters under Player: " .. player.Name .. "!")
	end

	local decoded = HttpService:JSONDecode(placedBoosters.Value)
	for position: string, boosterName: string in pairs(decoded) do
		Module.placeBooster(player, boosterName, stringToVector3(position))
	end
end

return Module
