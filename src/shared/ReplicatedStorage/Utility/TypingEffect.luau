return function(TextLabel: TextLabel, Text: string, Hide: boolean | nil, SoundIfAny: Sound | nil)
	if not TextLabel or not Text then
		return
	end
	if Hide == nil or Hide == false then
		TextLabel.Text = ""
		for Index = 0, #Text, 1 do
			TextLabel.Text = string.sub(Text, 1, Index)
			if SoundIfAny then
				SoundIfAny:Play()
			end
			task.wait(0.05)
		end
	elseif Hide and Hide == true then
		for Index = #Text, 0, -1 do
			TextLabel.Text = string.sub(Text, 1, Index)
			if SoundIfAny then
				SoundIfAny:Play()
			end
			task.wait()
		end
	end
end
