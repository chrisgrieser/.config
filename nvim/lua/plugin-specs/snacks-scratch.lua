-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md
--------------------------------------------------------------------------------

---@param self { buf: number }
---@param cli string|string[]
local function run(self, cli)
	local args = type(cli) == "table" and cli or { cli }
	local file = vim.api.nvim_buf_get_name(self.buf)
	vim.list_extend(args, { file })

	local result = vim.system(args):wait()
	local out = vim.trim((result.stdout or "") .. "\n" .. (result.stderr or ""))

	local ok, icons = pcall(require, "mini.icons")
	local icon = ok and icons.get("filetype", vim.bo[self.buf].ft) or "󰜎"
	icon = icons.get("filetype", vim.bo[self.buf].ft)

	vim.notify(out, nil, { title = args[1], icon = icon })
end

--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	keys = {
		{ "<leader>es", function() require("snacks").scratch() end, desc = " Scratch buffer" },
		{ "<leader>el", function() Snacks.scratch.select() end, desc = " List scratches" },
	},
	---@type snacks.Config
	opts = {
		ft = function()
			if vim.bo.buftype ~= "" or vim.bo.filetype == "" then return "markdown" end
			if 
			return vim.bo.filetype
		end,
		scratch = {
			root = vim.g.icloudSync .. "/picker-scratch",
			filekey = {
				count = true, -- allows count to create multiple scratch buffers
				cwd = false, -- otherwise only one scratch per filetype
				branch = false,
			},
			win = {
				relative = "editor",
				position = "float", -- or "right"
				width = 80,
				height = 25,
				wo = { signcolumn = "yes:1" },
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"|"shadow"]],
				footer_pos = "right",
				keys = { q = false }, -- so `q` is available as my comment operator
			},
			win_by_ft = {
				javascript = {
					keys = {
						["run"] = { "<CR>", function(self) run(self, "node") end, desc = "Run (node)" },
						["run2"] = {
							"<S-CR>",
							function(self) run(self, { "osascript", "-l", "javascript" }) end,
							desc = "Run (JXA)",
						},
					},
				},
				applescript = {
					keys = {
						["run"] = {
							"<CR>",
							function(self) run(self, "osascript") end,
							desc = "Run (osascript)",
						},
					},
				},
				python = {
					keys = {
						["run"] = {
							"<CR>",
							function(self) run(self, "python3") end,
							desc = "Run (python3)",
						},
					},
				},
			},
		},
	},
}
