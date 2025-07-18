return function(player: Player, playerGui: PlayerGui)
	local children = script:GetChildren()
	for _index: number, moduleScript: ModuleScript in pairs(children) do
		require(moduleScript)(player, playerGui)
	end
end
