local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local countdowns = require(script.countdowns)
local getPlayerBase = require(ReplicatedStorage.Shared.Gameplay.Utility.getPlayerBase)
local AnchorHandler = require(ReplicatedStorage.Shared.Utility.AnchorHandler)
local CollisionHandler = require(ReplicatedStorage.Shared.Utility.CollisionHandler)
local InstanceCreator = require(ReplicatedStorage.Shared.Utility.InstanceCreator)
local JSONHandler = require(ReplicatedStorage.Shared.Utility.JSONHandler)
local TypeCheck = require(ReplicatedStorage.Shared.Utility.TypeCheck)
local stringToVector3 = require(ReplicatedStorage.Shared.Utility.stringToVector3)
local vector3ToString = require(ReplicatedStorage.Shared.Utility.vector3ToString)
local BoosterFolder = ReplicatedStorage:FindFirstChild("Boosters") or ReplicatedStorage:WaitForChild("Boosters", 3)

type boosterData = {
	name: string,
	secondsLeft: number,
	id: string,
}

local Module = {}

function Module.disconnectBoosters(player: Player)
	local placedBoosters = player:FindFirstChild("placedBoosters") or player:WaitForChild("placedBoosters", 3)
	if not placedBoosters then
		error("Could not get placedBoosters under Player: " .. player.Name .. "!")
	end

	local decoded = HttpService:JSONDecode(placedBoosters.Value)

	for _index: number, boosterData: boosterData in pairs(decoded) do
		local RBXScriptConnection = countdowns[`{boosterData.name}_{boosterData.id}`]
		if RBXScriptConnection and TypeCheck.RBXScriptConnection(RBXScriptConnection) then
			RBXScriptConnection:Disconnect()
			RBXScriptConnection = nil
		end
	end
end

function Module.placeBooster(player: Player, boosterName: string, position: Vector3, data: {} | nil)
	local placedBoosters = player:FindFirstChild("placedBoosters") or player:WaitForChild("placedBoosters", 3)
	if not placedBoosters then
		error("Could not get placedBoosters under Player: " .. player.Name .. "!")
	end

	local booster = BoosterFolder:FindFirstChild(boosterName) or BoosterFolder:WaitForChild(boosterName, 3)
	if not booster then
		error(`{boosterName} does not exist under {BoosterFolder.Name}!`)
	end

	local ownsBoosterAlready: boolean = TypeCheck.table(data)

	local newBooster = booster:Clone() :: Model

	local id = data and data["id"] or HttpService:GenerateGUID(false)
	newBooster:SetAttribute("Identifier", id)

	if not ownsBoosterAlready then
		placedBoosters.Value = JSONHandler.Insert(
			placedBoosters.Value,
			vector3ToString(position),
			{ ["name"] = boosterName, ["secondsLeft"] = newBooster:GetAttribute("Duration"), ["id"] = id }
		)
	else
		if data and data["secondsLeft"] then
			newBooster:SetAttribute("Duration", data["secondsLeft"])
		end
	end

	AnchorHandler(newBooster, true)
	newBooster:PivotTo(CFrame.new(position))
	newBooster.Parent = getPlayerBase(player):FindFirstChild("placedBoosters")

	local radiusSize = newBooster:GetAttribute("Radius")

	local boosterHitbox = InstanceCreator("Part", "Hitbox", newBooster) :: Part
	CollisionHandler.SetInstanceOrGroup(boosterHitbox, "Characters")
	CollisionHandler.ToggleCanCollide(boosterHitbox, false)
	boosterHitbox.CanQuery = false
	boosterHitbox.Anchored = true
	boosterHitbox.Size = Vector3.new(radiusSize, 1, radiusSize)
	boosterHitbox.CastShadow = false
	boosterHitbox.Transparency = 0.25
	boosterHitbox.PivotOffset = CFrame.new(0, -(boosterHitbox.Size.Y / 2), 0)
	boosterHitbox:PivotTo(CFrame.new(position))

	local elapsed = 0
	countdowns[`{boosterName}_{id}`] = RunService.Heartbeat:Connect(function(deltaTime)
		elapsed += deltaTime

		-- a second has passed
		if elapsed >= 1 then
			elapsed = 0
			newBooster:SetAttribute("Duration", newBooster:GetAttribute("Duration") - 1)

			placedBoosters.Value = JSONHandler.Insert(
				placedBoosters.Value,
				vector3ToString(position),
				{ ["name"] = boosterName, ["secondsLeft"] = newBooster:GetAttribute("Duration"), ["id"] = id }
			)

			if newBooster:GetAttribute("Duration") < 1 then
				newBooster:Destroy()

				countdowns[`{boosterName}_{id}`]:Disconnect()
				countdowns[`{boosterName}_{id}`] = nil

				placedBoosters.Value = JSONHandler.Remove(placedBoosters.Value, vector3ToString(position), nil)
				return
			end
		end
	end)
end

function Module.load(player: Player)
	local placedBoosters = player:FindFirstChild("placedBoosters") or player:WaitForChild("placedBoosters", 3)
	if not placedBoosters then
		error("Could not get placedBoosters under Player: " .. player.Name .. "!")
	end

	local decoded = HttpService:JSONDecode(placedBoosters.Value)
	for position: string, data: boosterData in pairs(decoded) do
		Module.placeBooster(player, data.name, stringToVector3(position), data)
	end
end

return Module
