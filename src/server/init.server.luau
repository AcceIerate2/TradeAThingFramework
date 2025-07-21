require(script.Physics)()

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

Players.PlayerAdded:Connect(function(player)
	require(ServerStorage.Services:WaitForChild("PlayerService")).Load(player)
end)
Players.PlayerRemoving:Connect(require(ServerStorage.Services:WaitForChild("PlayerService")).Unload)

local ToolService = require(ServerStorage.Services.ToolService)
ToolService.listenToClients()

local PlotExpander_server = require(ServerStorage.Services.BaseService["PlotExpander.server"])
PlotExpander_server.listenToClients()
