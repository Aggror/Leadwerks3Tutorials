angleCounter = 0;

function Script:UpdateWorld()
	
	angleCounter = angleCounter + (1 * Time:GetSpeed())
	self.entity:SetRotation(0,0,angleCounter)

	--Everytime we reach the max angle 
	if angleCounter > 360 then
		self.component:CallOutputs("Done rotating")
		angleCounter = 0
	end

end