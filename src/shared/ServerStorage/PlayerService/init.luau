local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getPlayerBase = require(ReplicatedStorage.Shared.Gameplay.Utility.getPlayerBase)
local BaseService = require(script.Parent.BaseService)
local DataStoreService = require(script.Parent.DataStoreService)
local DevelopmentTerminal = require(script.Parent.DevelopmentTerminal)
local ToolService = require(script.Parent.ToolService)
local characterHandler = require(script.characterHandler)
local createPlayerInstances = require(script.createPlayerInstances)

local Module = {}

function Module.Load(player: Player)
	if not player then
		error("Player arg was not passed")
	end

	player:AddTag("Unsavable")
	player:SetAttribute("progressBar", 0)

	local playerInstancesCreated = createPlayerInstances(player) :: boolean
	if not playerInstancesCreated then
		player:Kick("Failed to load your data. Please rejoin.")
		error("Failed to create player instances for " .. player.Name)
	end

	local dataSynced = DataStoreService.Get(player) :: boolean
	if dataSynced then
		player:RemoveTag("Unsavable")
		player:SetAttribute("progressBar", player:GetAttribute("progressBar") :: number + 25)

		local character = player.Character
		if not character then
			character = player.CharacterAdded:Wait()
		end

		characterHandler(character)
		player:SetAttribute("progressBar", player:GetAttribute("progressBar") :: number + 25)

		DevelopmentTerminal(player)

		local availableBase = BaseService.getAvailableBase()
		if not availableBase then
			player:Kick("Could not get an available base for you. Please rejoin.")
		end

		player:SetAttribute("baseNumber", tonumber(string.split(availableBase.Name, "_")[2]))
		BaseService.loadBase(player, availableBase)

		player:SetAttribute("progressBar", player:GetAttribute("progressBar") :: number + 25)

		ToolService.loadPlayerTools(player)

		player:SetAttribute("progressBar", player:GetAttribute("progressBar") :: number + 25)
	end
end

function Module.Unload(player: Player)
	if not player then
		error("Player arg was not passed")
	end
	BaseService.resetBase(getPlayerBase(player))
	local cannotSave = player:HasTag("Unsavable")
	if cannotSave then
		return
	end
	DataStoreService.Set(player)
end

return Module
