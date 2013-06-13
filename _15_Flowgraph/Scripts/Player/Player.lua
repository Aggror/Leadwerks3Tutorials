require "Scripts/Functions/GetEntityNeighbors.lua"
require "Scripts/Animation/AnimationManager.lua"
require "Scripts/Functions/ReleaseTableObjects.lua"

local testmultiplier = 1--use this value to test animation in slow-motion
local walkmultiplier = 0.8
local runmultiplier = 0.8

Script.health = 100 --int
Script.MoveSpeed = 2.4 * testmultiplier * walkmultiplier
Script.RunSpeed = 6.5 * testmultiplier * runmultiplier
Script.maxAcceleration = 1.0--float
 
--Player states
Script.state={}
Script.state.idle=0
Script.state.walk=1
Script.state.run=2
Script.state.attack=3
Script.state.hurt=4
Script.state.dead=5

--Animation sequences
Script.sequence={} 
Script.sequence.walk=6
Script.sequence.run=2
Script.sequence.idle=1
Script.sequence.attack0=3
Script.sequence.attack1=4
Script.sequence.hit = 5
Script.sequence.death = 6

--Animation speed
Script.animationspeed={}
Script.animationspeed.walk = 0.05 * testmultiplier * walkmultiplier
Script.animationspeed.run = 0.04 * testmultiplier * runmultiplier

--Private
Script.inhibitAttack = false
Script.stunned = false
Script.swordattackdelay = 400

function Script:Start()
	self.animationmanager = AnimationManager:Create(self.entity)
	
	--Add camera
	self.camera = Camera:Create()
	self.camera:SetPosition(self.entity:GetPosition(true))
	self.camera:Translate(0,0.6,0)
	self.camera:SetRotation(45,0,0)
	self.camera:Move(0,0,-5)
	self.camera:SetFOV(70)
	self.camera:SetScript("Scripts/Cameras/3rdPersonFollow.lua",false)
	self.camera.script.target=self.entity
	self.camera.script:Start()
	
	self.teamid=1
	self.alive=true

	local platformname = System:GetPlatformName()	
	if platformname=="iOS" or platformname=="Android" then
		self.usetouchcontrols = true
	else
		self.usetouchcontrols = false	
	end

	self.healthbar = Texture:Load("Materials/HUD/healthbar.tex")
	self.healthmeter = Texture:Load("Materials/HUD/healthmeter.tex")
	
	--Create a listener
	self.listener = Listener:Create()
	local v = self.entity:GetPosition(true)
	v.y = v.y + 1.8
	self.listener:SetPosition(v,true)
	
	self.currentyrotation=self.entity:GetRotation().y

	self.currentState=-1
	self.turnSpeed=5
	self.swingmode=0
	
	self.sound={}

	self.sound.swordhit={}
	self.sound.swordhit[0]=Sound:Load("Sound/Weapons/sword_strike_body_stab_01.wav")
	self.sound.swordhit[1]=Sound:Load("Sound/Weapons/sword_strike_body_stab_04.wav")
	self.sound.swordhit[2]=Sound:Load("Sound/Weapons/sword_strike_body_slash_05.wav")
	self.sound.swordhit[3]=Sound:Load("Sound/Weapons/sword_strike_body_slash_04.wav")

	self.sound.swordswing={}
	self.sound.swordswing[0]=Sound:Load("Sound/Weapons/sword_whoosh07.wav")
	self.sound.swordswing[1]=Sound:Load("Sound/Weapons/sword_whoosh12.wav")

	self.sound.pain={}
	self.sound.pain.lasttimeplayed=0
	self.sound.pain[0]=Sound:Load("Sound/Player/warriors_pain_single_01.wav")
	self.sound.pain[1]=Sound:Load("Sound/Player/warriors_pain_single_02.wav")
	self.sound.pain[2]=Sound:Load("Sound/Player/warriors_pain_single_11.wav")
	
	self.smoothedhealth = self.health
	
	--Load HUD images
	if self.usetouchcontrols then
		self.buttonimage = Texture:Load("Materials/HUD/virtualbutton.tex")
		self.buttonindent=50
		self.buttonsize = self.buttonimage:GetWidth()*0.75
		self.rightbuttonposition = Vec2(App.context:GetWidth()-self.buttonindent-self.buttonsize/2,App.context:GetHeight()-self.buttonindent-self.buttonsize/2)
		self.leftbuttonposition = Vec2(self.buttonindent+self.buttonsize/2,App.context:GetHeight()-self.buttonindent-self.buttonsize/2)
		self.virtualstickposition = Vec2(self.leftbuttonposition.x,self.leftbuttonposition.y)
		self.virtualstickorigin = Vec2(self.leftbuttonposition.x,self.leftbuttonposition.y)		
		self.virtualsticktouchindex=-1
	end
end



function Script:UpdatePhysics()
	local movement=Vec3()
	local window=Window:GetCurrent()
	local changed
	local move=0
	local prevState = self.currentState
	
	--Position the listener.  We're doing this manually instead of parenting it because we want it to keep the same orientation as the camera
	local v = self.entity:GetPosition(true)
	v.y = v.y + 1.8
	self.listener:SetPosition(v,true)
	
	if self.currentState~=self.state.attack then
		self.currentState=self.state.idle
	end
	
	--Detect if attack started
	if self.currentState~=self.state.attack then
		local doattack = false
		if self.usetouchcontrols then
			local touchpos
			local i
			for i=0,4 do
				if window:TouchHit(i) then
					touchpos = window:GetTouchPosition(i)
					
					--Check if right button hit
					if touchpos:DistanceToPoint(self.rightbuttonposition)<self.buttonsize/2 then
						doattack=true
					--Check if left button hit
					elseif touchpos:DistanceToPoint(self.leftbuttonposition)<self.buttonsize/2 then
						
						--If virtual stick touch index is unassigned, use this touch index
						if self.virtualsticktouchindex == -1 then
							self.virtualsticktouchindex = i
							self.virtualstickposition = Vec2(touchpos.x,touchpos.y)
							self.virtualstickorigin = Vec2(touchpos.x,touchpos.y)
						end
					end
				else
					
					if self.virtualsticktouchindex == i then
						if window:TouchDown(i) then
							touchpos = window:GetTouchPosition(i)
							self.virtualstickposition = Vec2(touchpos.x,touchpos.y)

							--If distance is too far, let it go
							if touchpos:DistanceToPoint(self.virtualstickorigin)>self.buttonsize then
								self.virtualsticktouchindex = -1
							end
						else
							--If touch index is not pressed, release the virtual stick
							self.virtualsticktouchindex = -1
						end
					end
				end
			end
		else
			if window:KeyDown(Key.Space) then doattack=true end
		end
		if doattack then
			self.currentState=self.state.attack
			self.attackstarttime = Time:GetCurrent()
		end
	elseif not self.inhibitAttack then --only attack if the sword is in mid-swing
		if Time:GetCurrent() - self.attackstarttime > self.swordattackdelay then
			self:Attack()
		end
	end
	
	--Movement
	if self.usetouchcontrols then
		--If virtual stick is being controlled...
		if self.virtualsticktouchindex>-1 then
			movement.x = (self.virtualstickposition.x - self.virtualstickorigin.x) * 0.1
			movement.z = (self.virtualstickposition.y - self.virtualstickorigin.y) * -0.1
			if math.abs(movement.x)>0.01 or math.abs(movement.z)>0.01 then
				changed=true
				if self.currentState~=self.state.attack then
					move = movement:Length()
					if move>self.MoveSpeed*0.5 then
						self.currentState=self.state.walk
						if move>self.RunSpeed then
							self.currentState=self.state.run
							move=self.RunSpeed
						end
					else
						move=0
					end
				end
			end
		end
	else
		--Code for detecting key hits for movement and attacks
		if (window:KeyDown(Key.D)) then movement.x=movement.x+1 changed=true end
		if (window:KeyDown(Key.A)) then movement.x=movement.x-1 changed=true end
		if (window:KeyDown(Key.W)) then movement.z=movement.z+1 changed=true end
		if (window:KeyDown(Key.S)) then movement.z=movement.z-1 changed=true end
		if changed then
			if self.currentState~=self.state.attack then
				if window:KeyDown(Key.Shift) then--this will never happen with touch controls
					movement = movement:Normalize() * self.RunSpeed
					move=self.RunSpeed
					self.currentState=self.state.run
				else
					move=self.MoveSpeed
					movement = movement:Normalize() * self.MoveSpeed
					self.currentState=self.state.walk			
				end
			end
		end
	end
	
	--Rotate model to face correct direction
	if (changed) then
		movement = movement:Normalize()
		local targetRotation = Math:ATan2(movement.x,movement.z)-180
		self.currentyrotation = Math:IncAngle(targetRotation,self.currentyrotation,self.turnSpeed)--first two parameters were swapped
	end
	
	self.entity:SetInput(self.currentyrotation,move,0,0,false,self.maxAcceleration)	
	
	--Update animation
	if prevState~=self.currentState then
		if self.animationmanager then
			if self.currentState==self.state.idle then
				self.animationmanager:SetAnimationSequence(self.sequence.idle,0.05,200)
			elseif self.currentState==self.state.walk then
				self.animationmanager:SetAnimationSequence(self.sequence.walk,self.animationspeed.walk,200)			
			elseif self.currentState==self.state.run then
				self.animationmanager:SetAnimationSequence(self.sequence.run,self.animationspeed.run,200)
			elseif self.currentState==self.state.attack then
				self.swingmode = 1-self.swingmode
				self.sound.swordswing[math.random(0,#self.sound.swordswing)]:Play()
				if self.swingmode==1 then
					self.animationmanager:SetAnimationSequence(self.sequence.attack0,0.03,200,1,self,self.EndAttack)
				else
					self.animationmanager:SetAnimationSequence(self.sequence.attack1,0.03,200,1,self,self.EndAttack)
				end
			end
		end
	end
end

function Script:EndAttack()
	self.currentState=-1
	self.inhibitAttack = false
end

function Script:EndStun()
	self.stunned = false
end

function Script:Delete()
	local key,value
	local subkey,subvalue
	for key,value in pairs(self.sound) do
		if istable(value) then
			for subkey,subvalue in pairs(value) do
				subvalue:Release()
			end		
		else
			value:Release()
		end
	end
end

function Script:Attack() --broad check for nearby enemies 
	local k,entity
	local attackrange=3
	
	--Turn off the ability to attack again
	self.inhibitAttack = true
	
	--Get a table of all neighboring top-level entities
	local entities = GetEntityNeighbors(self.entity,attackrange,true)
	
	--Loop through all neighboring entities
	for k,entity in pairs(entities) do
		
		--Team ID should either be nil or not our own
		if entity.script.teamid~=self.teamid then
			
			--Get the other entity's position relative to this entity
			local entitypos = entity:GetPosition(true)
			local pos = Transform:Point(entitypos.x,entitypos.y,entitypos.z,nil,self.entity)			
			pos = pos * self.entity:GetScale()
			pos.z = pos.z * -1
			
			if pos.z>0 and pos.z<2.5 then
				if pos.z>math.abs(pos.x) then
					if pos.z>math.abs(pos.y) then
						
						--Check if TakeDamage function is present
						if type(entity.script.TakeDamage)=="function" then

							--Only attack if they have some health
							if entity.script.health>0 then

								--Call the TakeDamage() function
								entity.script:TakeDamage(10)
						
								--Play a sound
								self.sound.swordhit[math.random(0,#self.sound.swordhit)]:Play()
								
							end
							
						end
						
						--Check if Use function is present
						if type(entity.script.Use)=="function" then

							--Call the TakeDamage() function
							entity.script:Use()
							
						end
						
					end
				end
			end
		end
	end
end

function Script:TakeDamage(damage,source)

	--Don't do anything to dead players
	if self.health>0 then
		self.health = self.health - damage
		
		if self.health>0 then
			
			--We don't want to play the pain sound or animation if player is attacking
			if self.currentState ~= self.state.attack then
				
				--Play the pain animation if player is idle
				if self.currentState==self.state.idle then
					if self.stunned==false then
						self.stunned=true
						self.animationmanager:SetAnimationSequence(self.sequence.hit,0.04,100,1,self,self.EndStun)
					end
				end
				
				--Play the pain sound, but not too frequently
				if Time:GetCurrent() > self.sound.pain.lasttimeplayed then
					self.sound.pain.lasttimeplayed = Time:GetCurrent()+ 1000 + Math:Random(-200,200)
					self.sound.pain[math.random(0,#self.sound.pain)]:Play()
				end
				
			end

		else
			self.currentState = self.state.dead
			self.animationmanager:SetAnimationSequence(self.sequence.death,0.03,200,1,self,self.EndDeath)
		end
	end
	
end

function Script:EndDeath()
	
end

function Script:Draw()
	self.animationmanager:Update()
end

function Script:PostRender()
	local iw = self.healthbar:GetWidth()
	local ih = self.healthbar:GetHeight()
	local indent = 12
	local x = App.context:GetWidth()-indent-iw
	local y = indent
	
	--Slowly move virtual stick back to original position
	if self.virtualsticktouchindex==-1 then
		self.virtualstickposition.x = Math:Curve(self.virtualstickposition.x,self.leftbuttonposition.x,10/Time:GetSpeed())
		self.virtualstickposition.y = Math:Curve(self.virtualstickposition.y,self.leftbuttonposition.y,10/Time:GetSpeed())
	end
	
	--Smooth the displayed health value
	self.smoothedhealth = Math:Curve(self.health,self.smoothedhealth,10 / Time:GetSpeed())
	
	App.context:SetColor(0,1,0)
	App.context:DrawImage(self.healthmeter,x+30,y+8,196*self.smoothedhealth/100,16)
	App.context:SetColor(1,1,1)
	
	App.context:SetBlendMode(Blend.Alpha)
	App.context:DrawImage(self.healthbar,x,y)
	
	if self.usetouchcontrols then
		App.context:SetColor(1,1,1,0.25)
		App.context:DrawImage(self.buttonimage,self.virtualstickposition.x-self.buttonsize/2,self.virtualstickposition.y-self.buttonsize/2,self.buttonsize,self.buttonsize)
		App.context:DrawImage(self.buttonimage,App.context:GetWidth()-self.buttonindent-self.buttonsize,App.context:GetHeight()-self.buttonindent-self.buttonsize,self.buttonsize,self.buttonsize)
		App.context:SetColor(1,1,1,1)
	end
	App.context:SetBlendMode(Blend.Solid)
end

function Script:Cleanup()
	ReleaseTableObjects(self.sound)
end
