local counter = 0

-- based on https://www.vikasraj.dev/blog/vim-dot-repeat
function _Dot(motion)
	if motion == nil then
		-- since our operation does not expect a motion, we use `l` as dummy
		-- motion to not move the cursor.
		vim.o.operatorfunc = "v:lua._Dot"
		vim.cmd.normal { "g@l", bang = true }
		return
	end
	counter = counter + 1
	print("counter:", counter, "motion:", motion)
end

vim.keymap.set("n", "gt", _Dot)

--------------------------------------------------------------------------------
-- INFO the use of `normal` in the appendLines function breaks
-- dot-repeatability, needs to be fixed first.

local counter = 0
function M.variableLog(motion)
	if motion == nil then
		vim.o.operatorfunc = "v:lua.require'chainsaw'.variableLog"
		vim.cmd.normal { "g@l", bang = true }
		return
	end
	counter = counter + 1
	print("counter: " .. counter)

	local config = require("chainsaw.config").config
	local varname = getVar()
	local logLines = u.getTemplateStr("variableLog", config.logStatements)
	if not logLines then return end
	u.appendLines(logLines, { config.marker, varname, varname })
end
