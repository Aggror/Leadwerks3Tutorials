Script.enabled=true--bool "Enabled"
Script.sound0 = Sound:Load("sound/doors/castle_door_lock_07.wav")
Script.sound1 = Sound:Load("sound/doors/dungeon_troll_gate02.wav")

function Script:Push()
	if self.enabled then
		self.sound0:Play()
		self.sound1:Play()
		self.component:CallOutputs("Push")
	end
end

function Script:Enable()--in
	if self.enabled==false then
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