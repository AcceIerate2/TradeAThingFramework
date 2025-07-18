local Module = {}

local function Check(_Instance: ValueBase, Name: string): boolean
	if not _Instance or not Name then
		return false
	end
	if _Instance.Name == Name then
		return true
	end
	return false
end

local function GetValueBaseInstance(Player: Player, Name: string): ValueBase | nil
	if not Player or not Name then
		return
	end
	for _Index, _Instance in pairs(Player:GetChildren()) do
		local SavableInstance = _Instance:HasTag("Savable")
		if SavableInstance then
			if _Instance:IsA("ValueBase") then
				local ExactInstance = Check(_Instance, Name)
				if ExactInstance then
					return _Instance
				end
			elseif _Instance:IsA("Folder") then
				for _ChildIndex, _ChildInstance in pairs(_Instance:GetChildren()) do
					if _ChildInstance:IsA("ValueBase") then
						local ExactInstance = Check(_ChildInstance, Name)
						if ExactInstance then
							return _ChildInstance
						end
					end
				end
			end
		end
	end
	return nil
end

function Module.SetData(Player: Player, UserData: {})
	if not Player or not UserData then
		return
	end
	for InstanceName, InstanceValue in pairs(UserData) do
		local ExactInstance = GetValueBaseInstance(Player, InstanceName)
		if ExactInstance then
			ExactInstance.Value = InstanceValue
		end
	end
end

function Module.GetData(Player: Player): {}
	local DataToSave = {}
	for _Index, _Instance in pairs(Player:GetChildren()) do
		local SavableInstance = _Instance:HasTag("Savable")
		if SavableInstance then
			if _Instance:HasTag("Savable") then
				if _Instance:IsA("ValueBase") then
					DataToSave[_Instance.Name] = _Instance.Value
				elseif _Instance:IsA("Folder") then
					for _ChildIndex, _ChildInstance in pairs(_Instance:GetChildren()) do
						if _ChildInstance:HasTag("Savable") then
							if _ChildInstance:IsA("ValueBase") then
								DataToSave[_ChildInstance.Name] = _ChildInstance.Value
							end
						end
					end
				end
			end
		end
	end
	return DataToSave
end

return Module
