-- based on https://stackoverflow.com/a/10459129/22114136
-- CAVEAT prints the 1st variable in the caller's scope that has the given value
---@param varValue any
local function printVariable(varValue)
	local varname

	-- varname: Check caller's scope
	for stackLvl = 1, math.huge do
		local localName, localValue = debug.getlocal(2, stackLvl, 1)
		if not localName then break end
		if vim.deep_equal(localValue, varValue) then varname = localName end
	end

	-- varnme: Check global scope
	if not varname then
		for globalName, globalValue in pairs(_G) do
			if vim.deep_equal(globalValue, varValue) then varname = globalName end
		end
	end

	-- line number of print statemetn
	local caller = debug.getinfo(1, "S")
	for stackLvl = 2, 10 do
		local info = debug.getinfo(stackLvl, "S")
		if
			info
			and info.source ~= caller.source
			and info.what ~= "C"
			and info.source ~= "lua"
			and info.source ~= "@" .. (vim.env.MYVIMRC or "")
		then
			caller = info
			break
		end
	end
	local lnum = caller.currentline

	-- notify, with settings for snacks.nvim/nvim-notify
	local title = ("%s (L%d)"):format(varname or "unknown", lnum)
	local icon = "󰹈"
	if package.loaded["notify"] then title = vim.trim(icon .. " " .. title) end
	vim.notify(
		vim.inspect(varValue),
		vim.log.levels.DEBUG,
		{ title = title, icon = icon, ft = "lua" }
	)
end

--------------------------------------------------------------------------------

local b = 20
printVariable(b)
