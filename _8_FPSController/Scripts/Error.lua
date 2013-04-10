--This function is used to handle errors that occur as a result of an Invoke() function.
function LuaErrorHandler(message)
	Debug:Error("Lua Error: "..message)
end