local TweenService = game:GetService("TweenService")
local TweenConfiguration = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

local function tween(sound: Sound, volume: number)
	local _tween = TweenService:Create(sound, TweenConfiguration, { ["Volume"] = volume })
	_tween:Play()
	_tween.Completed:Wait()
	_tween:Destroy()
	_tween = nil
end

local Module = {}

function Module.fadeOut(sound: Sound)
	if not sound then
		return
	end
	tween(sound, 0)
	sound:Stop()
end

function Module.fadeIn(sound: Sound)
	sound.Volume = 0
	sound:Play()
	if not sound then
		return
	end
	tween(sound, 0.5)
end

function Module.transition(folder: Folder, name: string)
	if not folder or not name then
		return
	end
	local children = folder:GetChildren()
	for _index: number, sound: Sound in pairs(children) do
		local targetSound = sound.Name == name
		if not targetSound then
			Module.fadeOut(sound)
			continue
		end
		Module.fadeIn(sound)
	end
end

function Module.fadeAllOut(folder: Folder)
	if not folder then
		return
	end
	local children = folder:GetChildren()
	for _index: number, sound: Sound in pairs(children) do
		if sound.IsPlaying == true then
			Module.fadeOut(sound)
		end
	end
end

return Module
