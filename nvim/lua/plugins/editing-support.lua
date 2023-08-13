return {
	{ -- automatically set correct indent for file
		"nmac427/guess-indent.nvim",
		event = "BufReadPre",
		opts = { override_editorconfig = false },
	},
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
	{ -- auto-insert ;,=:
		"filNaj/tree-setter",
		-- list of supported languages: https://github.com/filNaj/tree-setter/tree/master/queries
		ft = { "c", "cpp", "java", "javascript", "typescript", "python", "rust", "go" },
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
	{ -- killring & highlights on `p`
		"gbprod/yanky.nvim",
		keys = {
			{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = " Paste (Yanky)" },
			{ "P", "<Plug>(YankyCycleForward)", mode = { "n", "x" }, desc = " Cycle Killring" },
			{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = " Sticky Yank" },
			{ "Y" }, -- is already sticky, but needs to load Yanky for the highlight settings
		},
		opts = {
			ring = { history_length = 50 },
			highlight = { timer = 1000 },
		},
		-- IncSearch is the default highlight group for post-yank highlights
		init = function()
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					vim.api.nvim_set_hl(0, "YankyYanked", { link = "IncSearch", default = true })
				end,
			})
		end,
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

			-- set by some plugins and  obscures whichkey
			vim.keymap.set("n", "<LeftMouse>", "<Nop>")
		end,
		opts = {
			plugins = {
				presets = { motions = false, g = false, z = false },
				spelling = { enabled = false },
			},
			-- INFO to ignore a mapping use the label "which_key_ignore", not the "hidden" setting here
			hidden = { "<Plug>", "^:lua ", "<cmd>" },
			key_labels = {
				["<CR>"] = "↵ ",
				["<BS>"] = "⌫",
				["<space>"] = "󱁐",
				["<Tab>"] = "↹ ",
				["<Esc>"] = "⎋",
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
				height = { min = 5, max = 15 },
				width = { min = 31, max = 34 },
				spacing = 1,
				align = "center",
			},
		},
	},
}
