local TweenService = game:GetService("TweenService")
return function(model: Model, size: Vector3, tweenConfiguration: TweenInfo)
	for _index: number, basePart in pairs(model:GetDescendants()) do
		if not basePart:IsA("BasePart") then
			continue
		end
		local Tween = TweenService:Create(basePart, tweenConfiguration, { ["Size"] = size }) :: Tween
		Tween:Play()
		Tween.Completed:Once(function()
			task.wait()
			Tween:Destroy()
			Tween = nil
		end)
	end
end
