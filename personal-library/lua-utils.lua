-- PERSONAL LUA UTILS LIBRARY
-- needs to be hardlinked, since lua's require does not work with symlinks
--------------------------------------------------------------------------------

---home directory
home = os.getenv("HOME")

---returns current date in ISO 8601 format
---@return string|osdate
function isodate()
	return os.date("!%Y-%m-%d")
end

---appends t2 to t1 in-place
---@param t1 table
---@param t2 table
function concatTables(t1, t2)
	for _,v in ipairs(t2) do
		table.insert(t1, v)
	end
end

---@param str string
---@param separator string uses Lua Pattern, so requires escaping
---@return table
function split(str, separator)
	str = str .. separator
	local output = {}
	-- https://www.lua.org/manual/5.4/manual.html#pdf-string.gmatch
	for i in str:gmatch("(.-)" .. separator) do
		table.insert(output, i)
	end
	return output
end

---trims whitespace from string
---@param str string
---@return string
function trim(str)
	if not(str) then return "" end
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end
