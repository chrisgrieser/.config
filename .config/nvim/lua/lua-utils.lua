-- PERSONAL LUA UTILS LIBRARY
-- needs to be hardlinked, since lua's require does not work with symlinks
--------------------------------------------------------------------------------

---home directory
home = os.getenv("HOME")

---@param str string
---@param separator string uses Lua Pattern, so requires escaping
---@return table
function split(str, separator)
	str = str .. separator
	local output = {}
	for i in str:gmatch("(.-)" .. separator) do -- https://www.lua.org/manual/5.4/manual.html#pdf-string.gmatch
		table.insert(output, i)
	end
	return output
end

---trims whitespace from string
---@param str string
---@return string
function trim(str)
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end
