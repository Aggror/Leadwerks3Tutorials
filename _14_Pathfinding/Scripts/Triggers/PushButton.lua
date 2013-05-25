Script.enabled=true--bool "Enabled"
Script.soundfile=""--path "Sound" "Wav Files (*.wav):wav"

function Script:Start()
	if self.soundfile then
		self.sound = Sound:Load(self.soundfile)
	end
end

function Script:Use()
	if self.enabled then
		if self.sound then self.entity:EmitSound(self.sound) end
		self.component:CallOutputs("Use")
	end
end

function Script:Enable()--in
	if self.enabled==false then
		self.enabled=true
		self.component:CallOutputs("Enable")
		self.health=1
	end
end

function Script:Disable()--in
	if self.enabled then
		self.enabled=false
		self.component:CallOutputs("Disable")
		self.health=0
	end
end

function Script:Release()
	if self.sound then self.sound:Release() end
end
