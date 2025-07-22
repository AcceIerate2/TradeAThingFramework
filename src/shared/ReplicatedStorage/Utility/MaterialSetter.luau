local function update(basePart: BasePart, material: Enum.Material)
	basePart:SetAttribute("defaultMaterial", material.Name)
	basePart.Material = material
end

local Module = {}

function Module.set(instance: Model | Folder | BasePart, material: Enum.Material)
	if instance:IsA("BasePart") then
		update(instance, material)
	end
	local descendants = instance:GetDescendants()
	if #descendants > 0 then
		for _index: number, descendant in pairs(descendants) do
			if descendant:IsA("BasePart") then
				update(descendant, material)
			end
		end
	end
end

function Module.reset(instance: Model | Folder | BasePart)
	if instance:IsA("BasePart") then
		local defaultMaterial = instance:GetAttribute("defaultMaterial") :: string
		instance.Material = Enum.Material[defaultMaterial] :: Enum.Material
	end
	local descendants = instance:GetDescendants()
	if #descendants > 0 then
		for _index: number, descendant in pairs(descendants) do
			if descendant:IsA("BasePart") then
				local defaultMaterial = descendant:GetAttribute("defaultMaterial") :: string
				descendant.Material = Enum.Material[defaultMaterial] :: Enum.Material
			end
		end
	end
end

return Module
