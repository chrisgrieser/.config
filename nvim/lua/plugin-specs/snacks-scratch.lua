-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md
--------------------------------------------------------------------------------

---@param cmd string
local function createRunKeymap(cmd)
	local function runner(self) ---@param self { buf: number } passed by snacks
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
			[cmd] = { "<CR>", runner, desc = ("Run (%s)"):format(cmd) },
		},
	}
end

--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	keys = {
		{ "<leader>es", function() Snacks.scratch() end, desc = " Scratch buffer" },
		{ "<leader>el", function() Snacks.scratch.select() end, desc = " List scratches" },
	},
	opts = {
		scratch = {
			filekey = { count = false, cwd = false, branch = false }, -- just one scratch per ft
			win = {
				width = 0.75,
				height = 0.75,
				footer_pos = "right",
				keys = { q = false, ["<D-w>"] = "close" }, -- so `q` is available as my comment operator
				on_win = function(win)
					-- FIX display of scratchpad title (partially hardcoded when setting icon, etc.)
					local title = vim.iter(win.opts.title)
						:map(function(part) return vim.trim(part[1]) end)
						:join(" ")
						:gsub("  ", " ")
					vim.api.nvim_win_set_config(win.win, { title = title })
				end,
				on_buf = function(buf)
					-- get nvim-lua typings at scratch location
					if buf.opts.bo.filetype == "lua" then
						local luarc = vim.fn.stdpath("data") .. "/scratch/.luarc.jsonc"
						local file = io.open(luarc, "w")
						local content = [[ {
							"runtime.version": "LuaJIT",
							"workspace.library": ["$VIMRUNTIME/lua", "${3rd}/luv/library"],
							"diagnostics.globals": ["Chainsaw"]
						} ]]
						assert(file, "Could not create luarc for lua scratch")
						file:write(content)
						file:close()
					end
				end,
			},
			win_by_ft = {
				javascript = createRunKeymap("node"),
				typescript = createRunKeymap("node"),
				python = createRunKeymap("python3"),
				applescript = createRunKeymap("osascript"),
				swift = createRunKeymap("swift"),
				zsh = createRunKeymap("zsh"),
			},
		},
	},
}
