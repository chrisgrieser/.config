return {
	{ -- autopair brackets/quotes
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = { "hrsh7th/nvim-cmp", "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-autopairs").setup { check_ts = true } -- use treesitter
			local rule = require("nvim-autopairs.rule")
			local isNodeType = require("nvim-autopairs.ts-conds").is_ts_node

			require("nvim-autopairs").add_rules {
				rule("<", ">", "lua"):with_pair(isNodeType("string")), -- keymaps
				rule("<", ">", "vim"):with_pair(), -- keymaps
				rule('\\"', '\\"', "json"):with_pair(), -- escaped double quotes
				rule("*", "*", "markdown"):with_pair(), -- italics
				rule("__", "__", "markdown"):with_pair(), -- bold
			}

			-- add brackets to cmp completions, e.g. "function" -> "function()"
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{ -- basically autopair, but for keywords
		"RRethy/nvim-treesitter-endwise",
		ft = { "lua", "bash", "sh", "vim", "ruby", "elixir" },
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- AI support
		"Bryley/neoai",
		dependencies = "MunifTanjim/nui.nvim",
		cmd = { "NeoAI", "NeoAIContext", "NeoAIInject", "NeoAIInjectCode", "NeoAIInjectContextCode" },
		opts = {
			ui = { -- percentages
				width = 40,
				output_popup_height = 75,
			},
			inject = {
				cutoff_width = vim.opt.textwidth:get() + 5,
			},
			shortcuts = {}, -- disable built-in shortcuts
		},
	},
	{ -- case conversion
		"johmsalas/text-case.nvim",
		lazy = true, -- loaded by keymaps
	},
	{ -- swapping of sibling nodes
		"Wansmer/sibling-swap.nvim",
		lazy = true, -- loaded by keymaps
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			use_default_keymaps = false,
			allowed_separators = { "..", "*" }, -- multiplication & lua string concatenation
			highlight_node_at_cursor = true,
			ignore_injected_langs = true,
			allow_interline_swaps = true,
			interline_swaps_witout_separator = false,
		},
	},
	{ -- split-join lines
		"Wansmer/treesj",
		dependencies = "nvim-treesitter/nvim-treesitter",
		cmd = "TSJToggle",
		opts = {
			use_default_keymaps = false,
			cursor_behavior = "start", -- start|end|hold
			max_join_length = 180,
		},
	},
	{ -- clipboard history / killring
		"gbprod/yanky.nvim",
		event = "BufReadPost",
		opts = {
			ring = { history_length = 50 },
			highlight = {
				on_yank = false, -- using nicer highlights from vim.highlight.on_yank() instead
				on_put = true,
				timer = 500,
			},
		},
	},
	{ -- auto-bullets for markdown-like filetypes
		"dkarter/bullets.vim",
		ft = { "markdown", "text" },
		init = function() vim.g.bullets_delete_last_bullet_if_empty = 1 end,
	},
	{ -- automatically set correct indent for file
		"nmac427/guess-indent.nvim",
		event = "BufReadPre",
		opts = { override_editorconfig = false },
	},
	{ -- key chord hints
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup {
				plugins = {
					presets = {
						motions = false,
						g = false,
						z = false,
					},
				},
				triggers_blacklist = { n = { "y" } }, -- FIX "y" needed to fix weird delay occurring when yanking after a change
				-- INFO to ignore a mapping use the label "which_key_ignore", not the "hidden" setting here
				hidden = { "<Plug>", "^:lua ", "<cmd>" },
				key_labels = { -- seems these are not working?
					["<CR>"] = "↵ ",
					["<BS>"] = "⌫",
					["<space>"] = "󱁐",
					["<Tab>"] = "↹ ",
					["<Esc>"] = "⎋",
					["<F1>"] = "^", -- karabiner remapping
					["<F2>"] = "<S-Space>", -- karabiner remapping
				},
				window = {
					-- only horizontal border to save space
					border = { "", require("config.utils").borderHorizontal, "", "" },
					padding = { 0, 0, 0, 0 },
					margin = { 0, 0, 0, 0 },
				},
				popup_mappings = {
					scroll_down = "<PageDown>",
					scroll_up = "<PageUp>",
				},
				layout = { -- of the columns
					height = { min = 4, max = 11 },
					width = { min = 33, max = 35 },
					spacing = 2,
					align = "center",
				},
			}
			require("which-key").register({
				f = { name = "refactor" },
				t = { name = "terminal / test" },
				b = { name = "debugger" },
				u = { name = "undo" },
				l = { name = "log / cmdline" },
				g = { name = "git" },
				o = { name = "option" },
				p = { name = "package" },
			}, { prefix = "<leader>" })
		end,
	},
}
