----------------------------------------------------------------------
--This script will make a camera follow any entity

--target: The entity to follow
--distance: The distance away from the entity to place the camera
--radius: collision radius of the camera (so it doesn't go through walls)
----------------------------------------------------------------------

Script.target = nil--Entity "Target"
--Script.distance = 6--float
--Script.debugmode = false--bool
--Script.pitch = 15--float
--Script.height = 6--float
Script.radius = 0.5--float

function Script:Start()
	self.smoothness=60
	if self.target==nil then
		return
		--Debug:Error("Script must have a target.")
	end
	
	self.firstframe=true

	self.targetoffset=Vec3(0)
	self.targetpositionoffset=Vec3(0)
	local camposition = self.entity:GetPosition(true)
	self.targetposition = self.target:GetPosition(true)
	self.relativeposition = camposition - self.targetposition
	
	--Construct a vertical plane facing the camera
	local v = Vec3(self.relativeposition.x,0,self.relativeposition.z)
	local vn = v:Normalize()
	local plane = Plane(self.targetposition,vn)
	local result = Vec3(0)
	local dir = Transform:Point(0,0,1000,self.entity,nil)
	if plane:IntersectsLine(camposition,camposition + dir,result) then
		self.targetpositionoffset = result - self.targetposition
	end
	
	self.height = self.entity.mat[3][1]

	--self.entity:SetDebugPhysicsMode(self.debugmode)
	--self.entity:SetDebugNavigationMode(true)
	--self.entity:SetDebugPhysicsMode(true)
	--self.entity:SetRotation(self.pitch,0,0)
	self.entity:SetPickMode(0)
end

function Script:UpdateWorld()
	
	--Exit the function if the target entity doesn't exist
	if self.target==nil then return 0 end
	
	--Get the target entity's position, in global coordinates
	local p0 = self.target:GetPosition(true) + self.targetpositionoffset
	local p1 = p0 + self.relativeposition--Vec3(p0.x,p0.y+self.height,p0.z-self.distance)
	local velocity = self.target:GetVelocity()
	velocity.y=0
	 
	self.targetoffset.x = Math:Curve(velocity.x*0.25,self.targetoffset.x,self.smoothness / Time:GetSpeed())
	self.targetoffset.z = Math:Curve(velocity.z*0.25,self.targetoffset.z,self.smoothness / Time:GetSpeed())
	
	--if(velocity.x ~= 0) then
	--	io.write (velocity.x,", ",velocity.y,", ",velocity.z, "\n")
	--end
	
	--Add our original offset vector to the target entity position
	--p0 = p0 + velocity * 2
	--p1 = offset + velocity * 2
	
	p0 = p0 + self.targetoffset
	p1 = p1 + self.targetoffset
	
	--Calculate a second point by backing up the camera away from the first point
	--local p1 = p0 + Transform::Normal(0,0,-1,self.entity,nil) * distance
	
	--Perform a raycast to see if the ray hits anything
	local pickinfo = PickInfo();
	
	local pickmode = self.target:GetPickMode()
	self.target:SetPickMode(0)
	--if self.entity.world:Pick(p0,p1,pickinfo,self.radius,true,Collision.Debris) then
		--If anything was hit, modify the camera position
	--	p1 = pickinfo.position
	--end
	self.target:SetPickMode(pickmode)
	
	--Smooth the camera motion
	--[[
	if self.smoothness>0 then
		local currentpos = self.entity:GetPosition(true)
		p1.x = Math:Curve(p1.x,currentpos.x,self.smoothness)--/Time:GetSpeed())
		p1.y = Math:Curve(p1.y,currentpos.y,self.smoothness)--/Time:GetSpeed())
		p1.z = Math:Curve(p1.z,currentpos.z,self.smoothness)--/Time:GetSpeed())
	end
	]]--
	
	--[[local currentPosition = self.entity:GetPosition(true)

		currentPosition.x = Math:Curve(p1.x,currentPosition.x,self.smoothness)--/Time:GetSpeed())
		--p1.y = Math:Curve(p1.y,p0.y,self.smoothness)--/Time:GetSpeed())
		currentPosition.z = Math:Curve(p1.z,currentPosition.z,self.smoothness)--/Time:GetSpeed())]]--
	--Finally, set the camera position
	
	--Smooth the height when going up stairs, etc.
	if self.firstframe then
		self.firstframe=false
		self.height = p1.y
	else
		self.height = Math:Curve(p1.y,self.height,5)	
	end
	p1.y = self.height

	self.entity:SetPosition(p1,true)
	
end
