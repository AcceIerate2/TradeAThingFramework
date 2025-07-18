local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TradeService = require(script.Parent.TradeService)
local FireEvent = require(ReplicatedStorage.Shared.Utility.FireEvent)
return function(player: Player)
	if not player then
		error("Invalid player provided.")
	end

	local isDev = table.find(require(script.DevIds), player.UserId) ~= nil
	if not isDev then
		return
	end
	FireEvent.fireRemoteEvent("serverChat", player, "Development Terminal is now active.")

	player.Chatted:Connect(function(message)
		if message == "/trade" then
			local dataToSend = {
				["toTradeWith"] = {},
				["toGet"] = {},
			}
			for _index, tool in pairs(player.Backpack:GetChildren()) do
				table.insert(dataToSend.toTradeWith, tool.Name)
			end
			if #dataToSend.toTradeWith == 0 then
				FireEvent.fireRemoteEvent("serverChat", player, "You have no tools to trade.")
				return
			end
			dataToSend.toGet = { "Golden" }
			FireEvent.fireRemoteEvent("serverChat", player, `Choices: {table.concat(dataToSend.toGet, ", ")}`)

			TradeService.trade(player, dataToSend)
		end
	end)
end
