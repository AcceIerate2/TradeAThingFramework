--!strict
-- Handles Baseparts, Models and Folders too
local SafeFunctionCaller = require(script.Parent.SafeFunctionCaller)

return function(_Instance: BasePart?, NetworkOwner: Player | nil)
	if not _Instance or not NetworkOwner then
		return
	end
	local IsBasePart = _Instance:IsA("BasePart") :: boolean
	if IsBasePart then
		SafeFunctionCaller(_Instance.SetNetworkOwner, _Instance, NetworkOwner)
	end
	local Children = _Instance:GetDescendants() :: {}
	for _Index: number, _ChildInstance: BasePart in pairs(Children) do
		local ChildIsBasePart = _ChildInstance:IsA("BasePart") :: boolean
		if ChildIsBasePart then
			SafeFunctionCaller(_ChildInstance.SetNetworkOwner, _ChildInstance, NetworkOwner)
		end
	end
end
