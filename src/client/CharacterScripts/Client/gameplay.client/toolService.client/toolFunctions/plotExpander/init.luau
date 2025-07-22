local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local AnchorHandler = require(ReplicatedStorage.Shared.Utility.AnchorHandler)
local highlightDestroyer = require(script.Parent.Parent.Utility.highlightDestroyer)
local InstanceCreator = require(ReplicatedStorage.Shared.Utility.InstanceCreator)
local explodeModel = require(ReplicatedStorage.Shared.Utility.explodeModel)
local shrinkModel = require(ReplicatedStorage.Shared.Utility.shrinkModel)

local tweenConfiguration = TweenInfo.new(0.2, Enum.EasingStyle.Linear)

local Module = {}

function Module.update(mouse: Mouse, base: Model)
	if not mouse or not base then
		return
	end

	local landFolder = base:FindFirstChild("Land")
	if not landFolder then
		return
	end

	highlightDestroyer(landFolder)

	local selectedPart = mouse.Target
	if not selectedPart then
		return
	end

	if selectedPart.Parent.Parent.Parent == landFolder then
		local highlight = InstanceCreator("Highlight", "Highlight", selectedPart) :: Highlight
		highlight.FillTransparency = 0.5
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineTransparency = 1
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Adornee = selectedPart.Parent
		highlight.Parent = selectedPart.Parent
		highlight.Enabled = true
	end
end

function Module.action(landToDestroy)
	AnchorHandler(landToDestroy, false)
	explodeModel(landToDestroy)
	shrinkModel(landToDestroy, Vector3.zero, tweenConfiguration)

	task.delay(2, function()
		landToDestroy:Destroy()
	end)
end

return Module
