--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InstanceCreator = require(ReplicatedStorage.Shared.Utility.InstanceCreator)
local TypeCheck = require(ReplicatedStorage.Shared.Utility.TypeCheck)
local InstancesToCreate = require(script.InstancesToCreate)

type IndexableValueBase = ValueBase & { Value: any }
local function SetValue(_Instance: ValueBase, Value: any)
	if not _Instance or not Value then
		return
	end
	(_Instance :: IndexableValueBase).Value = Value
end

local function AddTags(_Instance: Instance, TagsToAdd: {})
	if not _Instance or not TagsToAdd then
		return
	end
	for _Index, Tag in pairs(TagsToAdd) do
		_Instance:AddTag(Tag)
	end
end

local function SetupInstance(
	_InstanceName: string,
	_InstanceProperties: {},
	Parent: Instance
): (Instance | nil, boolean | nil)
	if not _InstanceName or not _InstanceProperties or not Parent then
		return nil
	end
	local _Instance = InstanceCreator(_InstanceProperties["Class"], _InstanceName, Parent) :: ValueBase | Folder
	if _Instance then
		AddTags(_Instance, _InstanceProperties["Tags"])

		if _Instance:IsA("ValueBase") then
			SetValue(_Instance, _InstanceProperties["DefaultValue"])
		end

		local HasChildren = TypeCheck.table(_InstanceProperties["Children"])
		return _Instance, HasChildren
	end
	return nil
end

return function(Player: Player): boolean
	if not Player then
		return false
	end
	for _InstanceName, _InstanceProperties in pairs(InstancesToCreate) do
		local _Instance, HasChildren = SetupInstance(_InstanceName, _InstanceProperties, Player)
		if _Instance then
			if HasChildren == true then
				for _ChildName, _ChildProperties in pairs(_InstanceProperties["Children"]) do
					SetupInstance(_ChildName, _ChildProperties, _Instance)
				end
			end
		end
	end
	return true
end
