return {
	{ "Darazaki/indent-o-matic" }, -- automatically set right indent for file
	{ "chrisgrieser/nvim-various-textobjs", dev = true, lazy = true },
	{ "bkad/CamelCaseMotion", event = "BufReadPost" },
	{
		"rhysd/clever-f.vim",
		keys = { "f", "F", "t", "T" },
		init = function()
			vim.g.clever_f_smart_case = 1
			vim.g.clever_f_mark_direct = 1 -- essentially quickscope
			vim.g.clever_f_chars_match_any_signs = " " -- space matches special chars
		end,
	},
	{
		"windwp/nvim-autopairs",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"nvim-treesitter/nvim-treesitter",
		},
		event = "InsertEnter",
		config = function()
			local npairs = require("nvim-autopairs")
			local rule = require("nvim-autopairs.rule")
			local isNodeType = require("nvim-autopairs.ts-conds").is_ts_node

			npairs.setup { check_ts = true } -- use treesitter

			npairs.add_rules {
				-- auto-pair <> if inside string (e.g. for keymaps)
				rule("<", ">", "lua"):with_pair(isNodeType { "string" }),
				-- auto-pair for markdown syntax
				rule("*", "*", "markdown"):with_pair(),
				rule("__", "__", "markdown"):with_pair(),
			}

			-- add brackets to cmp completions, e.g. "function" -> "function()"
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		init = function()
			vim.g.undotree_WindowLayout = 3
			vim.g.undotree_DiffpanelHeight = 8
			vim.g.undotree_ShortIndicators = 1
			vim.g.undotree_SplitWidth = 30
			vim.g.undotree_DiffAutoOpen = 0
			vim.g.undotree_SetFocusWhenToggle = 1
			vim.g.undotree_DiffCommand = "delta"
			vim.g.undotree_HelpLine = 1
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "undotree",
				callback = function()
					vim.keymap.set("n", "<D-w>", ":UndotreeToggle<CR>", { buffer = true })
					vim.opt_local.listchars = "space: "
				end,
			})
		end,
	},
	{
		"mizlan/iswap.nvim", -- swapping of nodes
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function() require("iswap").setup { autoswap = true } end,
		cmd = "ISwapWith",
	},
	{
		"Wansmer/treesj", -- split-join
		dependencies = "nvim-treesitter/nvim-treesitter",
		cmd = "TSJToggle",
		config = function()
			require("treesj").setup {
				use_default_keymaps = false,
				cursor_behavior = "start", -- start|end|hold
				max_join_length = 180,
			}
		end,
	},
	{
		"nacro90/numb.nvim", -- display line numbers while going to a line with `:`
		keys = ":",
		config = function() require("numb").setup() end,
	},
	{
		"dkarter/bullets.vim", -- auto-bullets for markdown-like filetypes
		ft = { "markdown", "text", "gitcommit" },
		init = function() vim.g.bullets_delete_last_bullet_if_empty = 1 end,
	},
}
