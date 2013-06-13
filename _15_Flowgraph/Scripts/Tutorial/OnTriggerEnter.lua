enabled = false;

function Script:Collision(entity, position, normal, speed)
	self:OnTriggerEnter()
end

function Script:OnTriggerEnter()--out
	if enabled == false then
		self.component:CallOutputs("OnTriggerEnter")
		enabled = true
	end
end

function Script:ResetTrigger()--in
	enabled = false
	System:Print("asdfasdfasdf")
end