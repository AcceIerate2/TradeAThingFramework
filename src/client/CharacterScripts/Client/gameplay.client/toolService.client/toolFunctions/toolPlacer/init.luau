local hitbox = require(script.hitbox) :: Part

local Players = game:GetService("Players")

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

local function isXZInside(base_PLATE: BasePart): boolean
	local hitboxCFrame, hitboxSize = hitbox.CFrame, hitbox.Size
	local baseCFrame, baseSize = base_PLATE.CFrame, base_PLATE.Size

	local hitboxMinX = hitboxCFrame.Position.X - (hitboxSize.X / 2)
	local hitboxMaxX = hitboxCFrame.Position.X + (hitboxSize.X / 2)
	local hitboxMinZ = hitboxCFrame.Position.Z - (hitboxSize.Z / 2)
	local hitboxMaxZ = hitboxCFrame.Position.Z + (hitboxSize.Z / 2)

	local baseMinX = baseCFrame.Position.X - (baseSize.X / 2)
	local baseMaxX = baseCFrame.Position.X + (baseSize.X / 2)
	local baseMinZ = baseCFrame.Position.Z - (baseSize.Z / 2)
	local baseMaxZ = baseCFrame.Position.Z + (baseSize.Z / 2)

	return (hitboxMinX >= baseMinX and hitboxMaxX <= baseMaxX) and (hitboxMinZ >= baseMinZ and hitboxMaxZ <= baseMaxZ)
end

return function(mouse: Mouse, base_PLATE)
	local mouseX, mouseY = mouse.X, mouse.Y
	local unitRay = workspace.CurrentCamera:ScreenPointToRay(mouseX, mouseY)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	raycastParams.FilterDescendantsInstances = { getPlayerCharacters(), hitbox }

	local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 100, raycastParams)
	if not raycastResult or raycastResult.Instance ~= base_PLATE then
		return
	end

	local hitPos = raycastResult.Position
	local yPos = base_PLATE.Position.Y + base_PLATE.Size.Y / 2 + hitbox.Size.Y / 2
	hitbox.Position = Vector3.new(hitPos.X, yPos, hitPos.Z)

	local blocked = false
	local partsInHitbox = workspace:GetPartsInPart(hitbox)
	for _index: number, otherPart in pairs(partsInHitbox) do
		if otherPart == base_PLATE then
			continue
		end
		blocked = true
		break
	end

	if not isXZInside(base_PLATE) then
		blocked = true
	end

	if blocked then
		hitbox.Color = Color3.fromRGB(255, 0, 0)
	else
		hitbox.Color = Color3.fromRGB(0, 255, 0)
	end
end
