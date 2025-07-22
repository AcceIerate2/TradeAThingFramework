local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getPlayerBase = require(ReplicatedStorage.Shared.Gameplay.Utility.getPlayerBase)
local JSONHandler = require(ReplicatedStorage.Shared.Utility.JSONHandler)
local TypeCheck = require(ReplicatedStorage.Shared.Utility.TypeCheck)
local eventListener = require(ReplicatedStorage.Shared.Utility.eventListener)
local Module = {}

function Module.listenToClients()
	eventListener.listenToRemoteFunction("expandPlot", function(player: Player, landIdentifier: string)
		if not player then
			return
		end

		local isValidIdentification = TypeCheck.string(landIdentifier)
		if isValidIdentification == false then
			error("Passed 'landIdentifier' argument not a string!")
		end

		local playerBase = getPlayerBase(player) :: Model
		if not playerBase then
			error(`Could not get base from {player.Name}!`)
		end

		local landFolder = playerBase:FindFirstChild("Land") :: Folder
		if not landFolder then
			error("Could not get Folder: [Land] under base: " .. playerBase.Name .. ".")
		end

		local land = landFolder:FindFirstChild(landIdentifier, true) :: Model
		if not land then
			error("Could not get land model with the name: " .. landIdentifier .. "!")
		end

		local landPrice = land:GetAttribute("Price")
		if TypeCheck.number(landPrice) == false then
			error("Land price is not a number! LandName: " .. land.Name)
		end

		local leaderstats = player:FindFirstChild("leaderstats")
		local playerCash = leaderstats:FindFirstChild("Cash")

		if playerCash.Value < landPrice then
			return
		end

		playerCash.Value -= landPrice

		local unlockedLand = player:FindFirstChild("UnlockedLand")
		unlockedLand.Value = JSONHandler.Insert(unlockedLand.Value, nil, landIdentifier)

		land:SetAttribute("CFrame", land:GetPivot())
		task.wait()
		land:PivotTo(CFrame.new(land:GetPivot().X, -100, land:GetPivot().Z))

		print("what")
		return true
	end)
end

function Module.load(owner: Player, base: Model)
	local landFolder = base:FindFirstChild("Land") or base:WaitForChild("Land", 3)

	local unlockedLand = owner:FindFirstChild("UnlockedLand") or owner:WaitForChild("UnlockedLand", 3) :: StringValue

	local playerLandData = HttpService:JSONDecode(unlockedLand.Value)
	local isTable = TypeCheck.table(playerLandData)
	if not isTable then
		error("playerLandData is not a Table!")
	end

	for _index: number, landIdentifier in pairs(playerLandData) do
		local land = landFolder:FindFirstChild(landIdentifier, true) :: Model
		land:SetAttribute("CFrame", land:GetPivot())
		task.wait()
		land:PivotTo(CFrame.new(land:GetPivot().X, -100, land:GetPivot().Z))
	end
end

function Module.reset(base: Model)
	local landFolder = base:FindFirstChild("Land") or base:WaitForChild("Land", 3)
	for _index: number, land: Model in pairs(landFolder:GetDescendants()) do
		if land:IsA("Model") then
			local defaultCFrame = land:GetAttribute("CFrame")
			if TypeCheck.CFrame(defaultCFrame) then
				land:PivotTo(defaultCFrame)
			end
		end
	end
end

return Module
