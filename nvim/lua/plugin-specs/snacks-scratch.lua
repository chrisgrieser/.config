-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md
--------------------------------------------------------------------------------
---@module "snacks"

---@param self { buf: number } passed by snacks
---@param cli string|string[]
---@param name string
local function runner(self, cli, name)
	local args = type(cli) == "table" and cli or { cli }
	local file = vim.api.nvim_buf_get_name(self.buf)
	vim.list_extend(args, { file })

	local result = vim.system(args):wait()
	local out = vim.trim((result.stdout or "") .. "\n" .. (result.stderr or ""))

	local ok, icons = pcall(require, "mini.icons")
	local icon = ok and icons.get("filetype", vim.bo[self.buf].ft) or "󰜎"
	icon = icons.get("filetype", vim.bo[self.buf].ft)

	vim.notify(out, nil, { title = name, icon = icon, ft = "text" })
end

---@param cli1 string|string[]
---@param cli2 string|string[]|nil
---@return snacks.win.Keys keymap
local function createRunKeymap(cli1, cli2)
	local config = { keys = {} }
	local name1 = type(cli1) == "string" and cli1 or cli1[1]
	config.keys[name1] = {
		"<CR>",
		function(self) runner(self, cli1, name1) end,
		desc = ("Run (%s)"):format(name1),
	}
	if not cli2 then return config end

	local name2 = type(cli2) == "string" and cli2 or cli2[1]
	config.keys[name2] = {
		"<S-CR>",
		function(self) runner(self, cli2, name2) end,
		desc = ("Run (%s)"):format(name2),
	}
	return config
end

--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	keys = {
		{ "<leader>es", function() Snacks.scratch() end, desc = " Scratch buffer" },
		{ "<leader>el", function() Snacks.scratch.select() end, desc = " List scratches" },
	},
	opts = {
		---@type snacks.scratch.Config
		scratch = {
			ft = function()
				if vim.bo.buftype ~= "" or vim.bo.ft == "" then return "markdown" end
				return vim.bo.ft
			end,
			root = vim.g.icloudSync .. "/snacks_scratch",
			filekey = { count = false, cwd = false, branch = false }, -- just use one scratch
			win = {
				relative = "editor",
				position = "float", -- "right" also makes sense
				width = 0.8,
				height = 0.8,
				wo = { signcolumn = "yes:1" },
				zindex = 50, -- put above nvim-satellite
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
				footer_pos = "right",
				keys = { q = false }, -- so `q` is available as my comment operator
				on_win = function(win)
					-- FIX display of scratchpad title (partially hardcoded, when setting icon, etc.)
					local icon = Snacks.util.icon(vim.bo[win.buf].ft, "filetype")
					local title = (" %s Scratch "):format(icon)
					vim.api.nvim_win_set_config(win.win, { title = title })
				end,
			},
			win_by_ft = {
				javascript = createRunKeymap("node", { "osascript", "-l", "JavaScript" }),
				typescript = createRunKeymap("node"),
				python = createRunKeymap("python3"),
				applescript = createRunKeymap("osascript"),
				swift = createRunKeymap("swift"),
				zsh = createRunKeymap("zsh", "bash"),
			},
		},
	},
}
