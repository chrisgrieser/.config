-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md
--------------------------------------------------------------------------------

---@param cmd string
local function createRunKeymap(cmd)
	local function runner(self) ---@param self { buf: number } passed by snacks
		vim.cmd("silent! update") -- ensure changes are saved
		local filepath = vim.api.nvim_buf_get_name(self.buf)
		local result = vim.system({ cmd, filepath }):wait()
		local out = vim.trim((result.stdout or "") .. "\n" .. (result.stderr or ""))

		local installed, icons = pcall(require, "mini.icons")
		local icon = installed and icons.get("filetype", vim.bo[self.buf].ft) or "󰜎"
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
		{ "<leader>es", function() require("snacks").scratch() end, desc = " Scratch buffer" },
		-- stylua: ignore
		{ "<leader>el", function() require("snacks").scratch.select() end, desc = " List scratches" },
	},
	opts = {
		scratch = {
			filekey = { count = false, cwd = false, branch = false }, -- just use one scratch
			win = {
				relative = "editor",
				position = "float", -- "right" also makes sense
				width = 0.8,
				height = 0.8,
				wo = { signcolumn = "yes:1" },
				zindex = 50, -- put above nvim-satellite
				footer_pos = "right",
				keys = { q = false, ["<D-w>"] = "close" }, -- so `q` is available as my comment operator
				on_win = function(win)
					-- FIX display of scratchpad title (partially hardcoded when setting icon, etc.)
					local icon = require("snacks").util.icon(vim.bo[win.buf].ft, "filetype")
					local title = (" %s Scratch "):format(icon)
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
			},
		},
	},
}
