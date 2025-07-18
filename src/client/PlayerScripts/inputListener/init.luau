local UserInputService = game:GetService("UserInputService")
local _inputBeganConnection: RBXScriptConnection | nil
local _inputEndedConnection: RBXScriptConnection | nil

local keyBinds = require(script.keyBinds)

local Module = {}

function Module.getAction(inputObject: InputObject, _gpe: boolean)
	local keyCode = inputObject.KeyCode
	if keyCode ~= Enum.KeyCode.Tab then
		if _gpe then
			return
		end
	end
	local action = keyBinds[keyCode]
	if not action then
		return
	end
	action(inputObject)
end

function Module.Connect()
	Module.Disconnect()
	_inputBeganConnection = UserInputService.InputBegan:Connect(Module.getAction)
	_inputEndedConnection = UserInputService.InputEnded:Connect(Module.getAction)
end

function Module.Disconnect()
	if _inputBeganConnection then
		_inputBeganConnection:Disconnect()
		_inputBeganConnection = nil
	end
	if _inputEndedConnection then
		_inputEndedConnection:Disconnect()
		_inputEndedConnection = nil
	end
end

return Module
