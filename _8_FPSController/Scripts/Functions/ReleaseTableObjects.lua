function ReleaseTableObjects(table)
	local key,value
	for key,value in pairs(table) do
		if type(value)=="table" then
			ReleaseTableObjects(value)		
		elseif type(value)=="userdata" then
			value:Release()
		end
	end
end