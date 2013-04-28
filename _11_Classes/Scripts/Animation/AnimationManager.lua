--[[
This script provides a programming interface to easily manage animation transitions.
Just call the SetAnimationSequence() function from any other script and the entity's animation
will be automatically blended from the previous sequence.  It's okay to call this repeatedly with
the same sequence.  A new sequence will only be added in the animation stack when it is different 
from the previous sequence.
]]--
function Script:Start()
	self.animations={}
	self.frameoffset = math.random(0,1000)
end

function Script:SetAnimationSequence(sequence, speed, blendtime, mode, endHookScript, endHook)
	
	--Handle default parameters
	if speed==nil then speed=1.0 end
	if blendtime==nil then blendtime=500 end
	if  mode==nil then mode=0 end
	
	--Check for redundant animation descriptor
	if mode==0 then
		if #self.animations>0 then
			if self.animations[#self.animations].sequence==sequence then
				if self.animations[#self.animations].speed==speed then
					--No change to blend time, so don't alter this?
					self.animations[#self.animations].blendtime=blendtime
					return
				end
			end
		end
	end
	
	--Create new animation descriptor and add to animation stack
	local animation={}
	animation.blendstart=Time:GetCurrent()
	animation.blendfinish=animation.blendstart+blendtime
	animation.sequence=sequence
	animation.speed=speed
	animation.mode=mode
	animation.starttime=animation.blendstart
	animation.endHookScript=endHookScript
	animation.endHook=endHook
	animation.endOfSequenceReached=false
	
	--Add a random offset to looped animations so they're not all identical
	--if mode==0 then
	--	animation.frameoffset = math.random(0,(self.entity:GetAnimationLength(sequence)))
	--end
	
	table.insert(self.animations,animation)
end

function Script:ClearAnimations()
	self.animations = {}
end

--[[
function Script:GetFrame(seq)
	local i,animation
	currenttime=Time:GetCurrent()
	
        for i,animation in ipairs(self.animations) do
		if animation.sequence == seq then
			return (currenttime-animation.blendstart) * animation.speed
		end
	end
	
	return -1 
end
]]--

function Script:Draw()
	local i,animation,blend,frame,n,completedanimation
	local doanimation=false
	local currenttime=Time:GetCurrent()
	local maxanim=-1
	
	for i,animation in ipairs(self.animations) do
		
		--Lock the matrix before the first sequence is applied
		if doanimation==false then
			doanimation=true
			self.entity:LockMatrix()
		end
		
		--Calculate blend value
		blend = (currenttime-animation.blendstart)/(animation.blendfinish-animation.blendstart)
		blend = math.min(1.0,blend)		
		
		if animation.mode==0 then
			frame = currenttime * animation.speed + self.frameoffset--animation.frameoffset
		else
			frame = (currenttime-animation.blendstart) * animation.speed
			local length = self.entity:GetAnimationLength(animation.sequence,true)
			if frame>=length-1 then
				frame=length-1
				maxanim = i+1--clears all animations up to this one, and then this one
				if (not animation.endOfSequenceReached) then
					animation.endOfSequenceReached=true
					if animation.endHookScript then
						if animation.endHook then
							animation.endHook(animation.endHookScript)
						end
					end
				end
			end
		end
		
		--Apply the animation
		self.entity:SetAnimationFrame(frame, blend, animation.sequence, true)
		
		--If this animation is blended in 100%, all previous looping animation sequences can be dropped
		if blend>=1.0 then
			maxanim = math.max(maxanim,i)
		end
		
	end
	
	--Unlock entity matrix if any animations were applied
	if doanimation==true then
		self.entity:UnlockMatrix()
	end
	
	--Clear blended out animation - moved this out of the loop to prevent jittering
	if maxanim>-1 then
		local index=1
		for n,completedanimation in ipairs(self.animations) do
			if n<maxanim then
				if completedanimation.mode==0 or completedanimation.endOfSequenceReached==true then
					table.remove(self.animations,index)
				else
					index=index+1
				end
			else
				break
			end
		end
	end
	
end

function Script:GetAnimationStackSize()
	return #self.animations
end