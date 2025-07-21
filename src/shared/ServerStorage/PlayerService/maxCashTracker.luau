return function(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local playerCash = leaderstats:FindFirstChild("Cash")
	local maxCash = player:WaitForChild("MaxCash")

	if playerCash.Value > maxCash.Value then
		maxCash.Value = playerCash.Value
	end

	playerCash:GetPropertyChangedSignal("Value"):Connect(function()
		if playerCash.Value > maxCash.Value then
			maxCash.Value = playerCash.Value
		end
	end)
end
