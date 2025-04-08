-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md
--------------------------------------------------------------------------------

---@param self { buf: number } passed by snacks
---@param cli string|string[]
---@param name string
local function run(self, cli, name)
	local args = type(cli) == "table" and cli or { cli }
	local file = vim.api.nvim_buf_get_name(self.buf)
	vim.list_extend(args, { file })

	local result = vim.system(args):wait()
	local out = vim.trim((result.stdout or "") .. "\n" .. (result.stderr or ""))

	local ok, icons = pcall(require, "mini.icons")
	local icon = ok and icons.get("filetype", vim.bo[self.buf].ft) or "󰜎"
	icon = icons.get("filetype", vim.bo[self.buf].ft)

	vim.notify(out, nil, { title = name, icon = icon })
end

---@param cli string|string[]
---@param key string
---@return snacks.win.Keys keymap
local function createRunKeymap(cli, key)
	local name = type(cli) =="string" and cli or cli[1]
	local keymap = {
		key,
		function(self) run(self, cli, name) end,
		desc = ("Run (%s)"):format(name),
	}
	return keymap
end

--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	keys = {
		{ "<leader>es", function() require("snacks").scratch() end, desc = " Scratch buffer" },
		{ "<leader>el", function() Snacks.scratch.select() end, desc = " List scratches" },
	},
	opts = {
		---@type snacks.scratch.Config
		scratch = {
			ft = function()
				if vim.bo.buftype ~= "" or vim.bo.ft == "" then return "markdown" end
				if vim.bo.ft == "typescript" then return "javascript" end
				return vim.bo.ft
			end,
			root = vim.g.icloudSync .. "/picker-scratch",
			filekey = {
				count = true, -- allows count to create multiple scratch buffers
				cwd = false, -- otherwise only one scratch per filetype
				branch = false,
			},
			win = {
				relative = "editor",
				position = "float", -- "right" also makes sense
				width = 80,
				height = 25,
				wo = { signcolumn = "yes:1" },
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
				footer_pos = "right",
				keys = {
					["<D-w>"] = "close",
					q = false, -- so `q` is available as my comment operator
				},
			},
			win_by_ft = {
				javascript = {
					keys = {
						["run"] = createRunKeymap("node", "<CR>"),
						["run2"] = createRunKeymap({ "osascript", "-l", "JavaScript" }, "<S-CR>"),
					},
				},
				python = {
					keys = {
						["run"] = createRunKeymap("python3", "<CR>"),
					},
				},
				zsh = {
					keys = {
						["run"] = createRunKeymap("zsh", "<CR>"),
						["run2"] = createRunKeymap("bash", "<S-CR>"),
					},
				},
				applescript = {
					keys = {
						["run"] = createRunKeymap("osascript", "<CR>"),
					},
				},
			},
		},
	},
}
