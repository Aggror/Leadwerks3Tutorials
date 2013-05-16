require "Scripts/Functions/ReleaseTableObjects.lua"

--Public
Script.chaseDistance = 60
Script.sightRadius = 10
Script.speed = 5
Script.maxaccel = 5
Script.health = 30
Script.attackRange = 1.5

--Private
Script.lastCheckForTargetTime=0
Script.currentState=-1
Script.swingmode=0
Script.followingTarget=false
Script.inhibitNewAttack=false
Script.stunned = false
Script.lastAttackTime=0
Script.dealtDamage=false
Script.deathFrame=0
Script.deathStartTime=0
Script.idlesoundtimer = 0
Script.meleeattackdelay = 300
Script.attackinprogress=false
Script.movemodechangetime=0
Script.movemode=0
Script.runthreshold=2

--Define player states
Script.state={}
Script.state.idle=0
Script.state.walk=1
Script.state.chase=2
Script.state.attack=3
Script.state.hurt=4
Script.state.dying=5
Script.state.dead=6

--Define animation sequences
Script.sequence={}
Script.sequence.walk=5
Script.sequence.run=3
Script.sequence.idle=6
Script.sequence.die=2
Script.sequence.attack0=0
Script.sequence.attack1=1
Script.sequence.hurt=4

--Load sounds
Script.sound={}

Script.sound.pain={}
Script.sound.pain[0]=Sound:Load("Sound/Goblin/gnome_hit_01.wav")
Script.sound.pain[1]=Sound:Load("Sound/Goblin/gnome_hit_02.wav")
Script.sound.pain[2]=Sound:Load("Sound/Goblin/gnome_hit_03.wav")
Script.sound.pain[3]=Sound:Load("Sound/Goblin/gnome_hit_04.wav")

Script.sound.swordhit={}
Script.sound.swordhit[0]=Sound:Load("Sound/Weapons/sword_strike_body_stab_01.wav")
Script.sound.swordhit[1]=Sound:Load("Sound/Weapons/sword_strike_body_stab_04.wav")
Script.sound.swordhit[2]=Sound:Load("Sound/Weapons/sword_strike_body_slash_05.wav")
Script.sound.swordhit[3]=Sound:Load("Sound/Weapons/sword_strike_body_slash_04.wav")

Script.sound.swordswing={}
Script.sound.swordswing[0]=Sound:Load("Sound/Weapons/sword_whoosh07.wav")
Script.sound.swordswing[1]=Sound:Load("Sound/Weapons/sword_whoosh12.wav")

Script.sound.attack={}
Script.sound.attack.lasttimeplayed = 0
Script.sound.attack[0]=Sound:Load("Sound/Goblin/gnome_attack_01.wav")
Script.sound.attack[1]=Sound:Load("Sound/Goblin/gnome_attack_02.wav")
Script.sound.attack[2]=Sound:Load("Sound/Goblin/gnome_attack_03.wav")
Script.sound.attack[3]=Sound:Load("Sound/Goblin/gnome_attack_04.wav")

Script.sound.death={}
Script.sound.death[0]=Sound:Load("Sound/Goblin/gnome_die_01.wav")
Script.sound.death[1]=Sound:Load("Sound/Goblin/gnome_die_02.wav")

Script.sound.idle={}
Script.sound.idle[0]=Sound:Load("Sound/Goblin/gnome_idle_01.wav")
Script.sound.idle[1]=Sound:Load("Sound/Goblin/gnome_idle_02.wav")
Script.sound.idle[2]=Sound:Load("Sound/Goblin/gnome_idle_03.wav")
Script.sound.idle[3]=Sound:Load("Sound/Goblin/gnome_idle_04.wav")

function Script:Start()
	if self.entity:GetMass()==0 then self.entity:SetMass(1.0) end
	--self.mass = self.entity:GetMass()-- save initial mass value
	--self.entity:SetMass(0)
end

function EnemyForEachEntityInAABBDoCallback(entity,extra)
	if extra.goblinai.target==nil then
		if extra~=entity then
			if entity.player~=nil then
				extra.goblinai.target=entity.player
			end
		end
	end
end

function Script:UpdatePhysics()
	
	--if dead then don't update
	if self.currentState==self.state.dead or self.health <= 0 then return end
	
	local time=Time:GetCurrent()
	self.prevstate=self.currentState
	
	if self.currentState==-1 then self.currentState=self.state.idle end
	
	--if one-shot animation is playing then return, so that enemy can only do 1 action at a time
	if self.stunned==true then return end
	
	--Handle attack
	if self.attackinprogress==true and self.dealtDamage==false then
		if (Time:GetCurrent()-self.attackstarttime) > self.meleeattackdelay then
			self.dealtDamage = true
			self:Attack()
		end
	end

	if self.attackinprogress==true then return end

	--If the enemy is stunned then return
	if self.stunned==true then 
		self.entity:Stop()
		--self.entity:SetMass(0)
		return 
	end
	
	--Check for a new target in the area
	if not self.target then
		if time-self.lastCheckForTargetTime>500 then
			self.lastCheckForTargetTime=time
			local position = self.entity:GetPosition(true)
			local aabb = AABB()
			
			aabb.min.x=position.x-self.sightRadius
			aabb.min.y=position.y-self.sightRadius
			aabb.min.z=position.z-self.sightRadius
			aabb.max.x=position.x+self.sightRadius
			aabb.max.y=position.y+self.sightRadius
			aabb.max.z=position.z+self.sightRadius	
			aabb:Update()
			self.entity.world:ForEachEntityInAABBDo(aabb,"EnemyForEachEntityInAABBDoCallback",self.entity)
			
			if self.target then
				self.entity:EmitSound(self.sound.attack[math.random(0,#self.sound.attack)])
				self.currentState=self.state.chase
				self.entity:Follow(self.target.entity,self.speed,self.maxaccel)
				--self.entity:SetMass(self.mass)
				self.followingTarget=true
			end
		end
	end
	
	if self.target then		
		local dist = self.entity:GetDistanceToEntity(self.target.entity)
		
		--Stop chasing if target has been reached
		if self.currentState==self.state.chase then
			if dist<self.attackRange then	
				self.entity:Stop()
				--self.entity:SetMass(0)
				self.followingTarget=false
				self.currentState=self.state.attack
			end
		end
			
		--Stop following if the target is too far away
		if self.currentState==self.state.chase then
			if dist>self.chaseDistance then
				self.target=nil
				self.currentState=self.state.idle
				self.entity:Stop()
				--self.entity:SetMass(0)
				self.followingTarget=false
			end
		end
		
		--If target goes out of attack range, switch back to chase mode
		if self.currentState==self.state.attack then
			if dist>self.attackRange then
				if self.attackinprogress==false and self.stunned==false then-- Don't move if a one-shot animation is being played
					self.currentState=self.state.chase
					--self.entity:SetMass(self.mass)
					self.entity:Follow(self.target.entity,self.speed,self.maxaccel)
					--self.entity:SetMass(self.mass)
					self.followingTarget=true
					self.movemode=0-- start out walking
				end
			end
		end
		
	end
	
	--Play animations based on the enemy state
	self:ManageAnimations()
end

function Script:ManageAnimations()
	
	--This will switch between walking and running animations depending on velocity
	if self.currentState==self.state.chase then
		if Time:GetCurrent() - self.movemodechangetime > 1000 then
			--nulltable.test=1-- test debugging
			if self.movemode==1 then				
				if self.entity:GetVelocity():Length()<self.runthreshold then
					self.movemodechangetime=Time:GetCurrent()
					self.movemode=0
					self.entity.animationmanager:SetAnimationSequence(self.sequence.walk,0.04,200)
					return
				end
			else
				if self.entity:GetVelocity():Length()>self.runthreshold then
					self.movemodechangetime=Time:GetCurrent()
					self.movemode=1
					self.entity.animationmanager:SetAnimationSequence(self.sequence.run,0.04,200)
					return
				end				
			end
		end
	end
	
	--Update animation if state changed
	if self.prevstate~=self.currentState or self.currentState==self.state.attack or self.currentState==self.state.hurt then
		if self.entity.animationmanager then
			if self.currentState==self.state.idle then
				--Play idle sound
				if self.lasttimeidlesoundplayed==nil then
					self.lasttimeidlesoundplayed = Time:GetCurrent() + math.random(0,11000)
				elseif Time:GetCurrent() > self.lasttimeidlesoundplayed then
					self.lasttimeidlesoundplayed = Time:GetCurrent() + 8000 + Math:Rnd(-3000,3000)
					self.entity:EmitSound(self.sound.idle[math.random(0,#self.sound.idle)])					
				end
				self.entity.animationmanager:SetAnimationSequence(self.sequence.idle,0.05,200)
			elseif self.currentState==self.state.chase then
				if self.movemode==0 then
					self.entity.animationmanager:SetAnimationSequence(self.sequence.walk,0.04,200)
				else
					self.entity.animationmanager:SetAnimationSequence(self.sequence.run,0.04,200)
				end
			elseif self.currentState==self.state.hurt then
				self.entity.animationmanager:ClearAnimations()
				self.stunned = true
				self.entity.animationmanager:SetAnimationSequence(self.sequence.hurt,.02,200,1,self,self.EndStun)	
			elseif self.currentState==self.state.attack then
				if self.stunned==false and self.attackinprogress==false then
					self.attackinprogress = true
					self.attackstarttime = Time:GetCurrent()
					self.swingmode = 1-self.swingmode
					self.entity:EmitSound(self.sound.swordswing[math.random(0,#self.sound.swordswing)])
					if Time:GetCurrent() > self.sound.attack.lasttimeplayed then
						self.sound.attack.lasttimeplayed = Time:GetCurrent()+ 800 + Math:Rnd(-200,200)
						self.entity:EmitSound(self.sound.attack[math.random(0,#self.sound.attack)])
					end
					if self.swingmode==1 then
						self.entity.animationmanager:SetAnimationSequence(self.sequence.attack0,0.03,200,1,self,self.EndAttack)
					else
						self.entity.animationmanager:SetAnimationSequence(self.sequence.attack1,0.025,200,1,self,self.EndAttack)
					end
				end
			end
		end
	end
end

function Script:TakeDamage(damage)
	if self.health>0 then
		self.health=self.health-damage		
		self.currentState=self.state.hurt
		self.entity:Stop()
		self:ManageAnimations()
		self.attackinprogress = false
		if self.health<=0 then
			self.entity.animationmanager:ClearAnimations()
			self.entity:Stop()
			--self.entity:SetMass(0)
			self.currentState = self.state.dead
			self.entity.animationmanager:SetAnimationSequence(self.sequence.die,0.03,200,1,self,self.Death)
			self.entity:EmitSound(self.sound.death[math.random(0,#self.sound.death)])
		else
			self.entity:EmitSound(self.sound.pain[math.random(0,#self.sound.pain)])
		end
	end
end

function Script:EndAttack()
	self.attackinprogress=false
	self.dealtDamage=false
end

function Script:EndStun()
	self.stunned = false
	self.currentState = self.state.attack
	--self.inhibitNewAttack=false
end

function Script:ManageIdleSounds()
	if Time:GetCurrent() > self.idlesoundtimer then
		self.idlesoundtimer = Time:GetCurrent() + 8000 + Math:Rnd(-3000,3000)
		self.entity:EmitSound(self.sound.idle[math.random(0,#self.sound.idle)])
	end
end

function Script:Death()
	self.UpdatePhysics = nil--This will remove the entity from the script UpdatePhysics list
	self.entity:SetCollisionType(0)
	self.entity:SetMass(0)
	self.entity:SetPhysicsMode(Entity.RigidBodyPhysics)
	self.UpdatePhysics = nil
end

function Script:AttackEnemy(player)

	local entitypos = player.entity:GetPosition(true)
	local pos = Transform:Point(entitypos.x,entitypos.y,entitypos.z,nil,self.entity)

	--Rotate to face target
	local p0 = self.entity:GetPosition(true)
	local p1 = self.target.entity:GetPosition(true)
	local yaw = Math:ATan2(p1.x-p0.x,p1.z-p0.z)-180
	yaw = Math:CurveAngle(self.entity:GetRotation().y,yaw,2)
	self.entity:SetInput(yaw,0,0,0,false,0)	
	
	pos = pos * self.entity:GetScale()
	pos.z = pos.z * -1
	if pos.z>0 and pos.z<self.attackRange then
		if pos.z>math.abs(pos.x) then
			if pos.z>math.abs(pos.y) then	
				player:TakeDamage(10,self.entity)
				self.entity:EmitSound(self.sound.swordhit[math.random(0,#self.sound.swordhit)])
			end
		end
	end
	
end

function EnemyAttackForEachEntityInAABBDoCallback(entity,extra)	
	if extra~=entity then
		if entity.player~=nil then
			extra.goblinai:AttackEnemy(entity.player)
		end
	end
end

function Script:Attack()

	local position = self.entity:GetPosition(true)
	
	local aabb = AABB()
	aabb.min.x=position.x-self.attackRange
	aabb.min.y=position.y-self.attackRange
	aabb.min.z=position.z-self.attackRange
	aabb.max.x=position.x+self.attackRange
	aabb.max.y=position.y+self.attackRange
	aabb.max.z=position.z+self.attackRange
	aabb:Update()
	
	self.entity.world:ForEachEntityInAABBDo(aabb,"EnemyAttackForEachEntityInAABBDoCallback",self.entity)
end

function Script:Cleanup()
	ReleaseTableObjects(Script.sound)
end