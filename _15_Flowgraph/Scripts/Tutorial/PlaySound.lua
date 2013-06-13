scarySound = ""
timer = 0
timerActive = false

function Script:Start()
	sound = Sound:Load("Sound/ghost.wav")
end

function Script:UpdateWorld()
	if timerActive == true then
		timer = timer + (Time:GetSpeed()/100)
		if timer > 5 then
			timerActive = false
			timer = 0
			self:TimerDone()	
		end

	end
end

function Script:StartSound()--in
	sound:Play()
	timerActive = true
end

function Script:TimerDone()--out
	self.component:CallOutputs("TimerDone")	
end