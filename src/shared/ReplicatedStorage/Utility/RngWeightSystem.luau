return function(Data: { [string]: number }, luck: number?): string | nil
	if luck == nil or luck < 1 then
		luck = 1
	end

	local LuckMultiplier = luck :: number
	local Sum = 0 :: number

	-- Calculate adjusted total weight
	local AdjustedData = {}

	for Key: string, Weight: number in pairs(Data) do
		-- Adjust weight using inverse exponential to favor rare items
		local AdjustedWeight = Weight ^ (1 / LuckMultiplier)
		AdjustedData[Key] = AdjustedWeight
		Sum += AdjustedWeight
	end

	local RandomThreshold = math.random() * Sum

	-- Select based on adjusted weights
	for Key: string, AdjustedWeight: number in pairs(AdjustedData) do
		RandomThreshold -= AdjustedWeight
		if RandomThreshold <= 0 then
			return Key
		end
	end

	return nil
end
