local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getPlayerBase = require(ReplicatedStorage.Shared.Gameplay.Utility.getPlayerBase)
local CollisionHandler = require(ReplicatedStorage.Shared.Utility.CollisionHandler)
local InstanceCreator = require(ReplicatedStorage.Shared.Utility.InstanceCreator)
local JSONHandler = require(ReplicatedStorage.Shared.Utility.JSONHandler)
local RngWeightSystem = require(ReplicatedStorage.Shared.Utility.RngWeightSystem)
local getDictLength = require(ReplicatedStorage.Shared.Utility.getDictLength)

local Boosters = ReplicatedStorage:FindFirstChild("Boosters") or ReplicatedStorage:WaitForChild("Boosters", 3)
local ToolFolder = ReplicatedStorage:FindFirstChild("Tools") or ReplicatedStorage:WaitForChild("Tools", 3)

local function getEconomyAdjustedItems(owner: Player)
	local MaxCash = owner:FindFirstChild("MaxCash")
	if not MaxCash then
		return
	end

	local playerCash = MaxCash.Value
	if playerCash <= 0 then
		playerCash = 1
	end

	local weights = {}
	local minRatio = 0.1
	local epsilon = 0.01

	for _, booster in ipairs(Boosters:GetChildren()) do
		local price = booster:GetAttribute("Price") or 1
		local ratio = price / playerCash

		if ratio < minRatio then
			continue
		end

		local weight = 1 / math.max(math.abs(ratio - 1), epsilon)
		weights[booster.Name] = math.max(1, math.floor(weight * 100))
	end

	if getDictLength(weights) < 1 then
		-- Work In Progress
	end

	return weights
end

local function getBooster(owner: Player)
	local affordableItems = getEconomyAdjustedItems(owner)
	local boosterName = RngWeightSystem(affordableItems, 1)
	return Boosters:FindFirstChild(boosterName):Clone()
end

local function setupBooster(booster: Model, owner: Player, startPositionPart: BasePart, conveyorBelt: Model)
	CollisionHandler.SetInstanceOrGroup(booster, "Characters")

	booster:PivotTo(startPositionPart.CFrame)
	booster.Parent = conveyorBelt:FindFirstChild("Boosters") or conveyorBelt:WaitForChild("Boosters", 3)

	local primaryPart = booster.PrimaryPart
	local proximityPrompt = InstanceCreator("ProximityPrompt", "ProximityPrompt", primaryPart) :: ProximityPrompt

	proximityPrompt.ActionText = "Buy"
	proximityPrompt.RequiresLineOfSight = false

	local _connection = nil
	_connection = proximityPrompt.Triggered:Connect(function(playerWhoTriggered: Player)
		if playerWhoTriggered ~= owner then
			return
		end

		local Tool = ToolFolder:FindFirstChild(booster.Name) :: Tool
		if not Tool then
			error("Could not find Tool named: " .. booster.Name)
		end

		local price = booster:GetAttribute("Price")

		local leaderstats = playerWhoTriggered:FindFirstChild("leaderstats")
			or playerWhoTriggered:WaitForChild("leaderstats")
		local playerCash = leaderstats:FindFirstChild("Cash") or leaderstats:WaitForChild("Cash")
		if playerCash.Value < price then
			return
		end

		playerCash.Value -= price

		_connection:Disconnect()
		_connection = nil

		local playerInventory = owner:FindFirstChild("Inventory")
		if not playerInventory then
			return
		end

		playerInventory.Value = JSONHandler.Insert(playerInventory.Value, nil, booster.Name)

		local clonedTool = Tool:Clone()
		clonedTool.Parent = owner.Backpack

		booster:Destroy()
	end)
end

local function startConveyor(ConveyorBelt: Model, owner: Player)
	local startPosition = ConveyorBelt:FindFirstChild("startPosition") or ConveyorBelt:WaitForChild("startPosition", 3)
	if not startPosition then
		error("startPosition could not be found under Conveyor Belt!")
	end

	local playerBase = getPlayerBase(owner)
	local baseOwner = playerBase:FindFirstChild("Owner") or playerBase:WaitForChild("Owner")

	task.spawn(function()
		while owner and baseOwner.Value do
			local booster = getBooster(owner)
			setupBooster(booster, owner, startPosition, ConveyorBelt)
			task.wait(3)
		end
	end)
end

local function setupDestroyHitbox(ConveyorBelt: Model)
	local endHitbox = ConveyorBelt:FindFirstChild("endHitbox") or ConveyorBelt:WaitForChild("endHitbox", 3)
	if not endHitbox then
		error("EndHitbox could not be found under Conveyor Belt!")
	end

	return endHitbox.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent
		local isAModel = parent:IsA("Model")
		if not isAModel then
			return
		end

		local isBooster = parent:HasTag("Booster")
		if not isBooster then
			return
		end

		parent:Destroy()
	end)
end

return function(base: Model, owner: Player)
	if not base or not owner then
		return
	end

	local conveyorBelt = base:FindFirstChild("ConveyorBelt") or base:WaitForChild("ConveyorBelt", 3)
	if not conveyorBelt then
		error("Conveyor Belt could not be found under Base: " .. base.Name)
	end

	local primaryPart = conveyorBelt.PrimaryPart
	primaryPart.AssemblyLinearVelocity = primaryPart.CFrame.LookVector * 3

	local _boosterDestroyerConnection = setupDestroyHitbox(conveyorBelt)
	local _boosterInserterConnection = startConveyor(conveyorBelt, owner)
end
