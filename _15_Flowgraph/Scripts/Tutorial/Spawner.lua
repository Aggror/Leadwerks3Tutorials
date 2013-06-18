function Script:CreateSphere()--in
	--Create a model
        model = Model:Sphere()
        model:SetPosition(0,6,0)
        model:SetColor(0,0,1)
        model:SetMass(1)
	model:SetKeyValue("type","sphere")
        --Create a shape
        shape = Shape:Sphere(0,0,0, 0,0,0, 1,1,1)
        model:SetShape(shape)
        shape:Release()

end

function Script:CreateBox()--in
	--Create a model
        model = Model:Box()
        model:SetPosition(2,6,0)
        model:SetColor(1,0,1)
        model:SetMass(1)
	model:SetKeyValue("type","box")

        --Create a shape
        shape = Shape:Box(0,0,0, 0,0,0, 1,1,1)
        model:SetShape(shape)
        shape:Release()

end

function Script:CreateCone()--in
	--Create a model
        model = Model:Cone()
        model:SetPosition(5,7,0)
        model:SetColor(0,1,1)
        model:SetMass(1)
	model:SetKeyValue("type","cone")

        --Create a shape
        shape = Shape:Cone(0,0,0, 0,0,0, 1,1,1)
        model:SetShape(shape)
        shape:Release()

end