local Module = {}

function Module.SetInstanceOrGroup(_Instance: BasePart | Model | Folder, CollisionName: string)
	if not _Instance or not CollisionName then
		return
	end
	if _Instance:IsA("BasePart") then
		_Instance.CollisionGroup = CollisionName
	end
	local Children = _Instance:GetDescendants() :: { Instance }
	if #Children > 0 then
		for _Index: number, _ChildInstance in pairs(Children) do
			if _ChildInstance:IsA("BasePart") then
				_ChildInstance.CollisionGroup = CollisionName
			end
		end
	end
end

function Module.ToggleCanCollide(_Instance: BasePart | Model | Folder, Toggle: boolean)
	if not _Instance or not Toggle then
		return
	end
	if _Instance:IsA("BasePart") then
		_Instance.CanCollide = Toggle
	end
	local Children = _Instance:GetDescendants() :: { Instance }
	if #Children > 0 then
		for _Index: number, _ChildInstance in pairs(Children) do
			if _ChildInstance:IsA("BasePart") then
				_ChildInstance.CanCollide = Toggle
			end
		end
	end
end

return Module
