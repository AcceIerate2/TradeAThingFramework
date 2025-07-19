local function round(num)
	return math.floor(num * 1000 + 0.5) / 1000
end
return function(vector3: Vector3)
	return `{round(vector3.X)},{round(vector3.Y)},{round(vector3.Z)}`
end
