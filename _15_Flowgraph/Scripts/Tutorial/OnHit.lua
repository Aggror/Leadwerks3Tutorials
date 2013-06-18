hitActive = true

function Script:Collision(entity, position, normal, speed)
	
	if hitActive == true and entity:GetKeyValue("type") == "box" then
		self.component:CallOutputs("OnHit")
		hitActive = false
	end	
end

function Script:OnHitReset()--in
	hitActive = true	
end

function Script:RandomTimeLimit()--arg
	return math.random(1, 5)
end