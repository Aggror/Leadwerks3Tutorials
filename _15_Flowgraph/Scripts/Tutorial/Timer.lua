active = false
timer = 0
maxTimer = 0

function Script:UpdateWorld()
	if active then	
		timer = timer + (Time:GetSpeed()/100)
		if timer > maxTimer then
			self.component:CallOutputs("Timer done")
			active = false
		end
	end
end

function Script:StartTimer(maxTime)--in
	System:Print(maxTime)
	active = true
	timer = 0
	maxTimer = maxTime
end