local u = require("config.utils")

return {
	{ -- autopair
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
	{ -- autopair, but for keywords
		"RRethy/nvim-treesitter-endwise",
		event = "BufEnter",
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
	{ -- better marks
		"tomasky/bookmarks.nvim",
		event = "VimEnter", -- cannot be loaded on keymaps due to the bookmark signs
		opts = {
			save_file = u.vimDataDir .. "/bookmarks",
			signs = {
				add = { text = "" },
			},
		},
	},
	{ -- case conversion
		"johmsalas/text-case.nvim",
		lazy = true, -- loaded by keymaps
	},
	{ -- Jump out of scope in insert mode
		"abecodes/tabout.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = "InsertEnter",
		opts = {
			act_as_shift_tab = true,
			ignore_beginning = true,
			tabouts = {
				{ open = "'", close = "'" },
				{ open = '"', close = '"' },
				{ open = "`", close = "`" },
				{ open = "(", close = ")" },
				{ open = "[", close = "]" },
				{ open = "{", close = "}" },
				{ open = "*", close = "*" }, -- markdown italics (multi-char not supported by tabout)
				{ open = "<", close = ">" }, -- tags / keybindings in lua
			},
		},
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
			ring = {
				history_length = 30,
				cancel_event = "update", -- move|update
			},
			highlight = {
				on_yank = false, -- using for nicer highlights via vim.highlight.on_yank()
				on_put = true,
				timer = 400,
			},
		},
	},
	{ -- auto-bullets for markdown-like filetypes
		"dkarter/bullets.vim",
		ft = { "markdown", "text" },
		init = function() vim.g.bullets_delete_last_bullet_if_empty = 1 end,
	},
	{ -- automatically set right indent for file
		"nmac427/guess-indent.nvim",
		event = "BufReadPre",
		opts = {
			override_editorconfig = false,
		},
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
