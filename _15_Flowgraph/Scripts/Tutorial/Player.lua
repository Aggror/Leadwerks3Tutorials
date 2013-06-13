function Script:Start()
	
end

function Script:UpdateWorld()
move = 0
	if App.window:KeyDown(Key.W) then
		move = 5
	end
	if App.window:KeyDown(Key.S) then
		move = -5
	end
	
	self.entity:SetInput(0,move,0)	

	App.camera:SetPosition(self.entity:GetPosition())
	App.camera:Move(0,2,-3)
end