Script.rotation = Vec3(0.1, 0.3, 0.2) --Vec3
Script.randomValue = Vec3(0.1, 0.3) --Vec2
Script.alive = false --bool
Script.name = "Aggror" --string
Script.mood = "Happy, Angry, Sad" --choice
Script.monster = "Vampire, Zombie, Ghost" --choiceedit
Script.otherEntity = "" --entity

function Script:Start()

	-- A comment
	--[[
		a multi-line comment
	--]]

	System:Print("hello world")

	if self.alive == false then
		--self.entity:Hide()
	end

	if self.name == "Aggror" then
		--self.entity:SetColor(1,0,0)
	end

	if self.mood == 2  then
		--self.entity:SetScale(0.5,0.5,0.5)
	end

	if self.monster == "ZombieGhost" then
		self.entity:SetScale(5,5,5)
	end

	if self.otherEntity ~= nil then
		self.otherEntity:SetPosition(5,3,5)
	end
end

function Script:UpdateWorld()
	self.entity:Turn(self.rotation.x * Time:GetSpeed(),
			self.rotation.y * Time:GetSpeed(),
			self.rotation.z * Time:GetSpeed())
end

function Script:Collision(entity, position, normal, speed)
	entity:SetColor(math.random(0,1), math.random(0,1), math.random(0,1))
end