local TextChatService = game:GetService("TextChatService")
local TextChannels = TextChatService:WaitForChild("TextChannels") :: TextChannel

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TypeCheck = require(ReplicatedStorage.Shared.Utility.TypeCheck)
local eventListener = require(ReplicatedStorage.Shared.Utility.eventListener)
return function()
	eventListener.listenToRemoteEvent("serverChat", function(message: string)
		print(message)
		if not TypeCheck.string(message) then
			return
		end
		TextChannels.RBXSystem:DisplaySystemMessage(message)
	end)
end
