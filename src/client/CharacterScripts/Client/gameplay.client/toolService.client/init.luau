local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FireEvent = require(ReplicatedStorage.Shared.Utility.FireEvent)

local hitbox = Instance.new("Part")
hitbox.TopSurface = Enum.SurfaceType.Smooth
hitbox.Material = Enum.Material.Neon
hitbox.Anchored = true
hitbox.Size = Vector3.new(4, 0.1, 4)
hitbox.Transparency = 0.75
hitbox.Color = Color3.fromRGB(0, 255, 0)
hitbox.CanCollide = false
hitbox.Parent = workspace

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

local function getPlayerCharacters(): { Model }
	local tableToReturn = {} :: { Model }
	for _index: number, player in pairs(Players:GetPlayers()) do
		if not player.Character then
			continue
		end
		table.insert(tableToReturn, player.Character)
	end
	return tableToReturn
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
				_mouseConnection = RunService.RenderStepped:Connect(function(_deltaTime: number)
					local mouseX, mouseY = mouse.X, mouse.Y
					local unitRay = workspace.CurrentCamera:ScreenPointToRay(mouseX, mouseY)

					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.RespectCanCollide = true
					raycastParams.FilterDescendantsInstances = { getPlayerCharacters(), hitbox }

					local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 100, raycastParams)
					if not raycastResult or raycastResult.Instance ~= workspace.Baseplate then
						return
					end

					local hitPos = raycastResult.Position
					local yPos = workspace.Baseplate.Position.Y + workspace.Baseplate.Size.Y / 2 + hitbox.Size.Y / 2
					hitbox.Position = Vector3.new(hitPos.X, yPos, hitPos.Z)
				end)
				_toolTriggeredConnection = newInstance.Activated:Connect(function()
					FireEvent.fireRemoteEvent("placeCharacter", hitbox.Position)
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
