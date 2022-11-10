-- PERSONAL LUA UTILS LIBRARY
-- needs to be hardlinked, since lua's require does not work with symlinks
--------------------------------------------------------------------------------

---home directory
home = os.getenv("HOME")

---returns current date in ISO 8601 format
function isodate ()
	return os.date("!%Y-%m-%d")
end

---string.sub, but for two-byte characters
function utf8.sub(s, i, j)
    return utf8.char(utf8.codepoint(s, i, j))
end

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
