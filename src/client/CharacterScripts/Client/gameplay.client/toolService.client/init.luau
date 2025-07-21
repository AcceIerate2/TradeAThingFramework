local hitbox = require(script.toolFunctions.toolPlacer.hitbox) :: BasePart

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local highlightDestroyer = require(script.Utility.highlightDestroyer)
local plotExpander = require(script.toolFunctions.plotExpander)
local toolPlacer = require(script.toolFunctions.toolPlacer)
local getPlayerBase = require(ReplicatedStorage.Shared.Gameplay.Utility.getPlayerBase)
local FireEvent = require(ReplicatedStorage.Shared.Utility.FireEvent)

local _childAddedConnection: RBXScriptConnection | nil
local _toolEquippedConnection: RBXScriptConnection | nil
local _toolUnEquippedConnection: RBXScriptConnection | nil
local _toolTriggeredConnection: RBXScriptConnection | nil
local _mouseConnection: RBXScriptConnection | nil

local function disconnectTriggeredConnection()
	if _toolTriggeredConnection then
		_toolTriggeredConnection:Disconnect()
		_toolTriggeredConnection = nil
	end
end

local function disconnectMouseConnection()
	highlightDestroyer()
	hitbox.Transparency = 1
	if _mouseConnection then
		_mouseConnection:Disconnect()
		_mouseConnection = nil
	end
end

local function disconnectUnequippedConnection()
	if _toolUnEquippedConnection then
		_toolUnEquippedConnection:Disconnect()
		_toolUnEquippedConnection = nil
	end
end

local function disconnectEquippedConnection()
	if _toolEquippedConnection then
		_toolEquippedConnection:Disconnect()
		_toolEquippedConnection = nil
	end
end

local function disconnectChildAddedConnection()
	if _childAddedConnection then
		_childAddedConnection:Disconnect()
		_childAddedConnection = nil
	end
end

return function(player: Player)
	disconnectChildAddedConnection()

	if not player then
		return
	end

	local character = script.Parent.Parent.Parent.Parent
	if not character then
		return
	end

	_childAddedConnection = character.ChildAdded:Connect(function(newInstance: Tool)
		local isATool = newInstance:IsA("Tool")
		if isATool then
			disconnectEquippedConnection()
			disconnectUnequippedConnection()
			_toolEquippedConnection = newInstance.Equipped:Connect(function(mouse: Mouse)
				disconnectTriggeredConnection()
				disconnectMouseConnection()
				hitbox.Transparency = 0.75

				local ToolType = newInstance:GetAttribute("ToolType")
				local functionToCall = toolPlacer
				local remoteNameToFire = "placeItem"

				if ToolType == "Plot Expander" then
					functionToCall = plotExpander
					remoteNameToFire = "expandPlot"
				end

				local playerBase = getPlayerBase(player)
				local base_PLATE = playerBase:FindFirstChild("base") or playerBase:WaitForChild("base", 3)
				if not base_PLATE then
					error("Could not get base_PLATE!")
				end

				_mouseConnection = RunService.RenderStepped:Connect(function(_deltaTime: number)
					if ToolType == "Plot Expander" then
						functionToCall(mouse, playerBase)
					else
						functionToCall(mouse, base_PLATE)
					end
				end)
				_toolTriggeredConnection = newInstance.Activated:Connect(function()
					if hitbox.Color == Color3.fromRGB(255, 0, 0) then
						warn("Can't place here!")
						return
					end
					local args = {}
					if remoteNameToFire == "placeItem" then
						args = {
							newInstance.Name,
							hitbox.Position,
						}
					elseif remoteNameToFire == "expandPlot" then
						local mouseTarget = mouse.Target
						local targetParent = mouseTarget.Parent
						if targetParent.Parent.Parent ~= playerBase.Land then
							return
						end
						args = {
							targetParent.Name,
						}
					end
					FireEvent.fireRemoteEvent(remoteNameToFire, table.unpack(args))
				end)
			end)
			_toolUnEquippedConnection = newInstance.Unequipped:Connect(function()
				disconnectTriggeredConnection()
				disconnectMouseConnection()
			end)
			newInstance.Destroying:Once(function()
				disconnectMouseConnection()
				disconnectEquippedConnection()
				disconnectUnequippedConnection()
				disconnectTriggeredConnection()
			end)
		end
	end)
end
