local TypeCheck = require(script.Parent.TypeCheck)
return function(Class: string, Name: string, Parent: Instance): Instance | nil
	if TypeCheck.string(Class) == false then
		error("Argument 'Class' is nil or not passed!")
	end
	local Object = Instance.new(Class) :: Instance
	if Object then
		if TypeCheck.string(Name) == true then
			Object.Name = Name
		end
		if TypeCheck.Instance(Parent) == true then
			Object.Parent = Parent
		end
	elseif Object == nil then
		error("Passed Argument 'Class' is not a valid ClassName!")
	end
	return Object
end
