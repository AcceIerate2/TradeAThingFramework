local ConveyorBelt = require(script.ConveyorBelt)
local placedCharacterService = require(script.Parent.placedCharacterService)
local PlotExpander_server = require(script["PlotExpander.server"])
local Bases = workspace.Bases

local Module = {}

function Module.getAvailableBase()
	local baseToReturn = nil
	local children = Bases:GetChildren()
	for _index: number, base in pairs(children) do
		local isTaken = base:HasTag("Taken")
		if isTaken then
			continue
		end
		baseToReturn = base
		break
	end
	return baseToReturn
end

function Module.loadBase(owner: Player, Base: Model)
	Base:AddTag("Taken")
	local baseOwner = Base:FindFirstChild("Owner") :: ObjectValue
	baseOwner.Value = owner
	placedCharacterService.load(owner)
	ConveyorBelt(Base :: Model, owner)
	PlotExpander_server.load(owner, Base)
end

function Module.resetBase(Base: Model)
	Base:RemoveTag("Taken")
	local baseOwner = Base:FindFirstChild("Owner") :: ObjectValue
	baseOwner.Value = nil

	local placedCharacterFolder = Base:FindFirstChild("placedCharacters") or Base:WaitForChild("placedCharacters", 3)
	if not placedCharacterFolder then
		error("could not get placedCharacterFolder under: " .. Base.Name)
	end

	local children = placedCharacterFolder:GetChildren()
	for _index: number, placedCharacter: Model in pairs(children) do
		placedCharacter:Destroy()
	end

	local placedBoosterFolder = Base:FindFirstChild("placedBoosters") or Base:WaitForChild("placedBoosters", 3)
	if not placedBoosterFolder then
		error("could not get placedBoosterFolder under: " .. Base.Name)
	end

	local boostChildren = placedBoosterFolder:GetChildren()
	for _index: number, placedBooster: Model in pairs(boostChildren) do
		placedBooster:Destroy()
	end

	PlotExpander_server.reset(Base)
end

return Module
