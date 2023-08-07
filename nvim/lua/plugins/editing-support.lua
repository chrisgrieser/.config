local u = require("config.utils")
--------------------------------------------------------------------------------

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
				rule('\\"', '\\"', "sh"):with_pair(), -- escaped double quotes
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
		ft = { "lua", "bash", "zsh", "sh", "vim", "ruby", "elixir" },
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- case conversion
		"johmsalas/text-case.nvim",
		lazy = true, -- loaded by keymaps
		init = function()
			local casings = {
				{ char = "u", arg = "upper", desc = "UPPER CASE" },
				{ char = "l", arg = "lower", desc = "lower case" },
				{ char = "t", arg = "title", desc = "Title case" },
				{ char = "c", arg = "camel", desc = "camelCase" },
				{ char = "p", arg = "pascal", desc = "PascalCase" },
				{ char = "s", arg = "snake", desc = "snake_case" },
				{ char = "k", arg = "dash", desc = "kebab-case" },
				{ char = "/", arg = "path", desc = "path/case" },
				{ char = ".", arg = "dot", desc = "dot.case" },
				{ char = "_", arg = "constant", desc = "SCREAMING_SNAKE_CASE" },
			}

			for _, case in pairs(casings) do
				vim.keymap.set(
					"n",
					"cr" .. case.char,
					("<cmd>lua require('textcase').current_word('to_%s_case')<CR>"):format(case.arg),
					{ desc = case.desc }
				)
				vim.keymap.set(
					"n",
					"cR" .. case.char,
					("<cmd>lua require('textcase').lsp_rename('to_%s_case')<CR>"):format(case.arg),
					{ desc = "󰒕 " .. case.desc }
				)
			end
		end,
	},
	{ -- swapping of sibling nodes
		"Wansmer/sibling-swap.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			use_default_keymaps = false,
			allowed_separators = { "..", "*" }, -- add multiplication & lua string concatenation
			highlight_node_at_cursor = true,
			ignore_injected_langs = true,
			allow_interline_swaps = false,
			interline_swaps_witout_separator = false,
		},
		keys = {
			-- stylua: ignore
			{ "ü", function() require("sibling-swap").swap_with_right() end, desc = "󰑃 Move Node Right" },
			-- stylua: ignore
			{ "Ü", function() require("sibling-swap").swap_with_left() end, desc = "󰑃 Move Node Left" },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown", "text", "gitcommit" },
				callback = function()
					-- stylua: ignore
					vim.keymap.set("n", "ü", '"zdawel"zph', { desc = "➡️ Move Word Right", buffer = true })
					-- stylua: ignore
					vim.keymap.set("n", "Ü", '"zdawbh"zph', { desc = "⬅️ Move Word Left", buffer = true })
				end,
			})
		end,
	},
	{ -- split-join lines
		"Wansmer/treesj",
		dependencies = "nvim-treesitter/nvim-treesitter",
		keys = {
			{ "<leader>s", function() require("treesj").toggle() end, desc = "󰗈 Split/join lines" },
		},
		opts = {
			use_default_keymaps = false,
			cursor_behavior = "start", -- start|end|hold
			max_join_length = 150,
			langs = {
				comment = {
					source = {
						both = {
							fallback = function() vim.cmd("normal! gww") end,
						},
					},
				},
			},
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
	{ -- automatically set correct indent for file
		"nmac427/guess-indent.nvim",
		event = "BufReadPre",
		opts = { override_editorconfig = false },
	},
	{
		"jokajak/keyseer.nvim",
		cmd = "KeySeer",
		opts = {
			include_builtin_keymaps = true,
			include_global_keymaps = true,
			include_buffer_keymaps = true,
			include_modified_keypresses = false,
			ignore_whichkey_conflicts = true,
			ui = {
				border = u.borderStyle,
				margin = { 1, 0, 1, 0 }, -- [top, right, bottom, left]
				winblend = 0, -- 100 for fully transparent
				size = { width = 65, height = 15 },
				icons = { keyseer = "" },
				show_header = true,
			},

			-- Keyboard options
			keyboard = {
				keycap_padding = { 0, 1, 0, 1 }, -- labels [top, right, bottom, left]
				highlight_padding = { 0, 0, 0, 0 },
				key_labels = {
					["<Space>"] = "␣",
					["<CR>"] = "⏎",
					["<Tab>"] = "↹",
				},
			},
		},
	},
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		init = function()
			-- leader prefixes normal mode
			require("which-key").register({
				f = { name = " 󱗘 Refactor" },
				u = { name = " 󰕌 Undo" },
				l = { name = "  Log / Cmdline" },
				g = { name = " 󰊢 Git" },
				o = { name = "  Options" },
				p = { name = " 󰏗 Package" },
			}, { prefix = "<leader>" })

			-- leader prefixes visual mode
			require("which-key").register({
				f = { name = " 󱗘 Refactor" },
				l = { name = "  Log / Cmdline" },
				g = { name = " 󰊢 Git" },
			}, { prefix = "<leader>", mode = "x" })
		end,
		opts = {
			plugins = {
				presets = { motions = false, g = false, z = false },
				spelling = { enabled = false },
			},
			triggers_blacklist = {
				-- FIX "y" needed to fix weird delay occurring when yanking after a change
				-- n = { "y" },
				-- FIX very weird bug where insert mode undo points (<C-g>u),
				-- as well as vim-matchup's <C-g>% binding insert extra `1`s
				-- after wrapping to the next line in insert mode. The `G` needs
				-- to be uppercased to affect the right mapping, too.
				i = { "<C-G>" },
			},
			hidden = { "<Plug>", "^:lua ", "<cmd>" },
			-- INFO to ignore a mapping use the label "which_key_ignore", not the "hidden" setting here
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
				border = { "", u.borderHorizontal, "", "" },
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
		},
	},
}
