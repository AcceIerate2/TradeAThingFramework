local placedCharacterService = require(script.Parent.placedCharacterService)
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

function Module.loadBase(owner: Player, Base: Folder | Model)
	Base:AddTag("Taken")
	local baseOwner = Base:FindFirstChild("Owner") :: ObjectValue
	baseOwner.Value = owner
	placedCharacterService.load(owner)
end

function Module.resetBase(Base: Folder | Model)
	Base:RemoveTag("Taken")
	local baseOwner = Base:FindFirstChild("Owner") :: ObjectValue
	baseOwner.Value = nil

	local placedCharacterFolder = Base:FindFirstChild("placedCharacters") or Base:WaitForChild("placedCharacters", 3)
	if not placedCharacterFolder then
		error("could not get placedCharacterFolder under: " .. baseOwner.Name)
	end

	local children = placedCharacterFolder:GetChildren()
	for _index: number, placedCharacter: Model in pairs(children) do
		placedCharacter:Destroy()
	end
end

return Module
