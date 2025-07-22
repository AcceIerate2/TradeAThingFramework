return function(instance: Model | Folder | BasePart, newColor: Color3)
	if instance:IsA("BasePart") then
		instance.Color = newColor
	end
	-- WORK IN PROGRESS!
end
