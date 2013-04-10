Script.openstate=false--bool "Start Open"
Script.offset=Vec3(0)--Vec3 "Offset"
Script.movespeed=1--float "Move speed" 0,100,3
Script.opensoundfile=""--path "Open Sound" "Wav File (*wav)|wav"
Script.loopsoundfile=""--path "Loop Sound" "Wav File (*wav)|wav"
Script.closesoundfile=""--path "Close Sound" "Wav File (*wav)|wav"
Script.closedelay=2000--int "Close delay"
Script.enabled=true--bool "Enabled"

function Script:Start()
	--Debug:Error("Door script was called")

self.entity:SetGravityMode(false)
	if self.entity:GetMass()==0 then
		Debug:Error("Entity mass must be greater than 0.")
	end
	if self.opensoundfile~="" then self.opensound = Sound:Load(self.opensoundfile) end
	if self.loopsoundfile~="" then self.loopsound = Sound:Load(self.loopsoundfile) end
	if self.closesoundfile~="" then self.closesound = Sound:Load(self.closesoundfile) end
	self.opentime=0
	if self.openstate then
		self.openposition=self.entity:GetPosition(true)
		self.closedposition=self.openposition+self.offset
		self.desiredposition=Vec3(self.openposition.x,self.openposition.y,self.openposition.z)
	else
		self.closedposition=self.entity:GetPosition(true)
		self.openposition=self.closedposition+self.offset
		self.desiredposition=Vec3(self.closedposition.x,self.closedposition.y,self.closedposition.z)
	end
	self.entity:SetMass(0)
	--local pin=self.offset:Normalize()
	--self.base=Pivot:Create()
	--self.base:SetPosition(self.closedposition)
	--self.joint=Joint:Slider(self.closedposition.x,self.closedposition.y,self.closedposition.z,pin.x,pin.y,pin.z,self.entity,self.base,0,self.offset:Length())
end

function Script:Stop()
	if self.opensound then self.opensound:Release() end
	if self.loopsound then self.loopsound:Release() end
	if self.closesound then self.closesound:Release() end
	if self.loopsource then self.loopsource:Release() end
end

function Script:Open()--in
	if self.enabled then
		self.opentime = Time:GetCurrent()
		if self.openstate==false then
			self.openstate=true
			if self.opensound then
				self.entity:EmitSound(self.opensound)
			end
			self.component:CallOutputs("Open")
		end
	end
end

function Script:Close()--in
	if self.enabled then
		if self.openstate then
			if self.loopsource then
				self.loopsource:Release()
				self.loopsource=nil
			end
			if self.closesound then
				self.entity:EmitSound(self.closesound)
			end
			self.openstate=false
			self.component:CallOutputs("Close")
		end
	end
end

function Script:UpdatePhysics()
	
	if self.openstate then
		if self.closedelay>0 then
			local time = Time:GetCurrent()
			if time-self.opentime>self.closedelay then
				self:Close()
			end
		end
	end
	
	--Figure out where the door should be
	local diff
	if self.openstate then
		diff = self.openposition - self.desiredposition
	else
		diff = self.closedposition - self.desiredposition
	end
	local l = diff:Length()
	if l>self.movespeed/60 then
		diff = diff:Normalize() * self.movespeed/60
	end
	self.desiredposition = self.desiredposition + diff
	
	--Find the difference between where we want the door to be, and where it is
	diff = self.desiredposition - self.entity:GetPosition(true)
	
	--If the difference is more than a tiny bit, use physics to add forces to make it go where we want
	if diff:Length()>0.01 then
		--System:Print(math.random())
		self.entity:SetPosition(self.desiredposition.x,self.desiredposition.y,self.desiredposition.z)
	end
end

function Script:Release()
	self.base:Release()
	self.base=nil
end