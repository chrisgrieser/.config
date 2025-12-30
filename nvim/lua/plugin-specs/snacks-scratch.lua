-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md
--------------------------------------------------------------------------------

---@param cmd string
---@return { keys: { [string]: table } }
local function createRunKeymap(cmd)
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

--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	keys = {
		{ "<leader>es", function() Snacks.scratch() end, desc = " Scratch buffer" },
		{ "<leader>el", function() Snacks.scratch.select() end, desc = " List scratches" },
	},
	build = function() -- get nvim-lua typings at scratch location
		local scratchRoot = vim.fn.stdpath("data") .. "/scratch" -- default root
		vim.fn.mkdir(scratchRoot, "p")
		local luarc = io.open(scratchRoot .. "/.luarc.jsonc", "w")
		assert(luarc, "Could not create luarc for lua scratch")
		luarc:write([[ {
			"runtime.version": "LuaJIT",
			"workspace.library": ["$VIMRUNTIME/lua", "${3rd}/luv/library"]
		} ]])
		luarc:close()
	end,
	---@type snacks.Config
	opts = {
		scratch = {
			filekey = { count = false, cwd = false, branch = false }, -- just one scratch per ft
			win = {
				width = 0.75,
				height = 0.8,
				footer_pos = "right",
				keys = { q = false, ["<D-w>"] = "close" }, -- so `q` is available as my comment operator
				on_win = function(win)
					-- FIX display of scratchpad title (partially hardcoded icon, etc.)
					local title = vim.iter(win.opts.title)
						:map(function(part) return vim.trim(part[1]) end)
						:join(" ")
						:gsub("  ", " ")
					vim.api.nvim_win_set_config(win.win, { title = title })
				end,
			},
			win_by_ft = {
				javascript = createRunKeymap("node"),
				typescript = createRunKeymap("node"),
				python = createRunKeymap("python3"),
				applescript = createRunKeymap("osascript"),
				swift = createRunKeymap("swift"),
				zsh = createRunKeymap("zsh"),
				lua = {
					keys = {
						source = { desc = "source" }, -- just to shorten keymap hint
						print = {
							-- overwrite chainsaw's `objectLog` with snacks.scratch's
							-- special `print` (uses virtualtext instead of notification)
							"<leader>lo",
							function()
								local logLine = ("print(%s)"):format(vim.fn.expand("<cword>"))
								local installed, chainsaw = pcall(require, "chainsaw.config.config")
								if installed then logLine = logLine .. " -- " .. chainsaw.config.marker end
								vim.cmd.normal { "o", bang = true }
								vim.api.nvim_set_current_line(logLine)
							end,
							desc = "print",
						},
					},
				},
			},
		},
	},
}
