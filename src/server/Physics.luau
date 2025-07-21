local PhysicsService = game:GetService("PhysicsService")
return function()
	local collisionName = "Characters"
	PhysicsService:RegisterCollisionGroup(collisionName)
	PhysicsService:CollisionGroupSetCollidable(collisionName, collisionName, false)
end
