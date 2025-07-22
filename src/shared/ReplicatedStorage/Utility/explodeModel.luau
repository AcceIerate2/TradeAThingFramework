return function(model: Model)
	local descendants = model:GetDescendants()
	for _index: number, descendant: BasePart in pairs(descendants) do
		if descendant:IsA("BasePart") then
			local xAxis = math.random(-20, 20)
			local yAxis = math.random(20, 40)
			local zAxis = math.random(-20, 20)

			local impulseVector = Vector3.new(xAxis, yAxis, zAxis)

			descendant.AssemblyLinearVelocity = impulseVector
		end
	end
end
