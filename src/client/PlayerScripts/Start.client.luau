local coreAdjustments = require(script.Parent.coreAdjustments)
coreAdjustments()

local inputListener = require(script.Parent.inputListener)
local serverChat = require(script.Parent.serverChat)
local userInterface = require(script.Parent.userInterface)
inputListener.Connect()

userInterface()

serverChat()
