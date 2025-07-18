local coreAdjustments = require(script.Parent.coreAdjustments)
coreAdjustments()

local inputListener = require(script.Parent.inputListener)
local userInterface = require(script.Parent.userInterface)
inputListener.Connect()

userInterface()
