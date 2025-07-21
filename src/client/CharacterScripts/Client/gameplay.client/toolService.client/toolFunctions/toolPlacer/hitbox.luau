local hitbox = workspace:FindFirstChild("hitbox")

if not hitbox then
	hitbox = Instance.new("Part")
	hitbox.TopSurface = Enum.SurfaceType.Smooth
	hitbox.Material = Enum.Material.Neon
	hitbox.Name = "hitbox"
	hitbox.Anchored = true
	hitbox.Size = Vector3.new(4, 0.1, 4)
	hitbox.Transparency = 0.75
	hitbox.Color = Color3.fromRGB(0, 255, 0)
	hitbox.CanCollide = false
	hitbox.Parent = workspace
end

return hitbox :: Part
