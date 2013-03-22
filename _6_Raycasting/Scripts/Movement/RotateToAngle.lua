require "Scripts/Math/math.lua"

Script.angle = Vec3(0)--vec3 "Angle"
Script.enabled=false--bool "Enabled"
Script.speed = 0.5--float "Speed"

function Script:Start()
	self.targetrotation = Quat(self.angle)
end

function Script:Enable()--in
	if self.enabled~=true then
		self.enabled=true
		self.component:CallOutputs("Enable")
	end
end

function Script:Disable()--in
	if self.enabled then
		self.enabled=false
		self.component:CallOutputs("Disable")
	end
end

function Script:UpdatePhysics()
	if self.enabled then
		local currentrotation = self.entity:GetQuaternion()
		local q = currentrotation:Slerp(self.targetrotation,0.1)
		self.entity:SetRotation(q)
	end
end