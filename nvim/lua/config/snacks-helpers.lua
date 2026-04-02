local M = {}
--------------------------------------------------------------------------------

function M.toggleInvisibleChars()
	-- toggle invisible chars, disable when leaving buffer
	local function reEnable()
		vim.opt_local.listchars = vim.b.indent_prevListChars
		Snacks.indent.enable()
		vim.api.nvim_del_autocmd(vim.b.indent_autocmdId)
	end

	if Snacks.indent.enabled then
		vim.b.indent_prevListChars = vim.opt_local.listchars:get()
		-- stylua: ignore
		vim.opt_local.listchars:append { tab = " ", space = "·", trail = "·", lead = "·" }
		Snacks.indent.disable()
		vim.b.indent_autocmdId = vim.api.nvim_create_autocmd("BufLeave", {
			callback = reEnable,
			buffer = 0,
		})
	else
		reEnable()
	end
end

---@param cmd string
---@return { keys: { [string]: table } }
function M.createScratchRunKeymap(cmd)
	local function runner(self) ---@param self { buf: number } -- passed by snacks
		vim.cmd("silent! update") -- save before running
		local filepath = vim.api.nvim_buf_get_name(self.buf)
		local result = vim.system({ cmd, filepath }):wait()

		local out = vim.trim((result.stdout or "") .. "\n" .. (result.stderr or ""))
		local icon = Snacks.util.icon(vim.bo[self.buf].ft, "filetype")
		local level = vim.log.levels[result.code == 0 and "INFO" or "WARN"]

		vim.notify(out, level, { title = cmd, icon = icon, ft = "text" })
	end

	return {
		keys = {
			run = { "<CR>", runner, desc = ("run (%s)"):format(cmd) },
		},
	}
end

function M.ensureLuarcForScratch()
	local scratchRoot = vim.fn.stdpath("data") .. "/scratch" -- default root
	vim.fn.mkdir(scratchRoot, "p")
	local luarc = io.open(scratchRoot .. "/.luarc.jsonc", "w")
	assert(luarc, "Could not create luarc for lua scratch")
	luarc:write([[ {
	"runtime.version": "LuaJIT",
	"workspace.library": ["$VIMRUNTIME/lua", "${3rd}/luv/library"]
} ]])
	luarc:close()
end

--------------------------------------------------------------------------------
return M
