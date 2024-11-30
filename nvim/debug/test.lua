local function printVariable(value)
	local name

	-- see if we can find a local in the caller's scope with the given value
	for stackLvl = 1, math.huge do
		local localname, localvalue = debug.getlocal(2, stackLvl, 1)
		if not localname then break end
		if localvalue == value then name = localname end
	end

	-- if we couldn't find a local, check globals
	if not name then
		for globalname, globalvalue in pairs(_G) do
			if globalvalue == value then name = globalname end
		end
	end

	if name then
		print(string.format("%s = %s", name, tostring(value)))
	else
		print(string.format("No variable found for the value '%s'.", tostring(value)))
	end
end

local b = 20
printVariable(b)
