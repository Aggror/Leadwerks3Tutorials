WorldGetEntitiesInAABBDoCallbackTable = nil
GetEntityNeighborsScriptedOnly=false

function WorldGetEntitiesInAABBDoCallback(entity,extra)
	if entity~=extra then
		if GetEntityNeighborsScriptedOnly==false or entity.script~=nil then
			table.insert(WorldGetEntitiesInAABBDoCallbackTable,entity)
		end
	end
end

------------------------------------------------------------------------------------------
--Get all neigbhoring top-level entities within the specified radius.
--The optional scriptOnly parameter will skip entities that do not have a script attached.
------------------------------------------------------------------------------------------
function GetEntityNeighbors(entity,radius,scriptOnly)
	local result
	local aabb = AABB()
	local p = entity:GetPosition(true)
	local temp = GetEntityNeighborsScriptedOnly
	GetEntityNeighborsScriptedOnly=scriptOnly
	aabb.min = p - radius
	aabb.max = p + radius
	aabb:Update()
	local table = WorldGetEntitiesInAABBDoCallbackTable 
	WorldGetEntitiesInAABBDoCallbackTable = {}
	entity.world:ForEachEntityInAABBDo(aabb,"WorldGetEntitiesInAABBDoCallback",entity)	
	result = WorldGetEntitiesInAABBDoCallbackTable
	WorldGetEntitiesInAABBDoCallbackTable = table
	GetEntityNeighborsScriptedOnly = temp
	return result
end
