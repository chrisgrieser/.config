function _G.myFunc(motionType)
	if motionType == nil then
		vim.o.operatorfunc = "v:lua.myFunc"
		return "g@"
	end

	-- `] and `[ contain the start and end of the selection
	local startLn, startCol = unpack(vim.api.nvim_buf_get_mark(0, "["))
	local endLn, endCol = unpack(vim.api.nvim_buf_get_mark(0, "]"))
	local lines
	if motionType == "char" then
		lines = vim.api.nvim_buf_get_text(0, startLn - 1, startCol, endLn - 1, endCol + 1, {})
	elseif motionType == "line" then
		lines = vim.api.nvim_buf_get_lines(0, startLn - 1, endLn, false)
	end
	local text = table.concat(lines, "\n")
	local result = vim.system({ "nvim", "-l", tmpfile }):wait()
	local severity = result.code == 0 and "INFO" or "ERROR"
	local out = result.code == 0 and result.stdout or result.stderr or ""
	vim.notify(out, vim.log.levels[severity])
end

vim.keymap.set("n", "gt", _G.myFunc, { expr = true })

local a = { "hello", "world" }
