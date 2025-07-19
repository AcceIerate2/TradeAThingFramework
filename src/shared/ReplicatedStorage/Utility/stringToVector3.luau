return function(vector3String: string): Vector3
	local x, y, z = string.match(vector3String, "([^,]+),([^,]+),([^,]+)")
	return Vector3.new(tonumber(x), tonumber(y), tonumber(z))
end
