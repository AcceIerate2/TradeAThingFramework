local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local ToolService = require(ServerStorage.Services.ToolService)
ToolService()

local PlayerService = require(ServerStorage.Services.PlayerService)
Players.PlayerAdded:Connect(PlayerService.Load)
Players.PlayerRemoving:Connect(PlayerService.Unload)
