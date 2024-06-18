local M = {}
--------------------------------------------------------------------------------

---@param motionType? "line"|"char"|"block" set via usage of `g@`
function M.luaevalOperator(motionType)
	if motionType == nil then
		local thisModule = "funcs.lua-eval"
		local thisFunc = "luaevalOperator"
		vim.o.operatorfunc = ("v:lua.require'%s'.%s"):format(thisModule, thisFunc)
		return "g@"
	end

	-- `] and `[ contain the start and end of the selection
	local startLn, startCol = unpack(vim.api.nvim_buf_get_mark(0, "["))
	local endLn, endCol = unpack(vim.api.nvim_buf_get_mark(0, "]"))

	if motionType == "char" then
		local lines = vim.api.nvim_buf_get_text(0, startLn - 1, startCol, endLn - 1, endCol + 1, {})
		local text = table.concat(lines, "\n")
		vim.notify(vim.inspect(vim.fn.luaeval(text)))
	elseif motionType == "line" then
		local lines = vim.api.nvim_buf_get_lines(0, startLn - 1, endLn, false)
		local tmpfile = os.tmpname()

		local file, _ = io.open(tmpfile, "w")
		if not file then return end
		file:write(table.concat(lines, "\n"))
		file:close()

		local result = vim.system({ "nvim", "-l", tmpfile }):wait()
		local out = (result.stdout or "") .. (result.stderr or "") -- nvim writes to stderr
		vim.notify(out, vim.log.levels[result.code == 0 and "INFO" or "ERROR"])
	end
end

function M.luaEvalLine()
	local line = vim.api.nvim_get_current_line()
	vim.notify(vim.inspect(vim.fn.luaeval(line)))
end

--------------------------------------------------------------------------------
return M
