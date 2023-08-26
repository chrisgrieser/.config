return {
	{ -- pending: https://github.com/Djancyp/regex.nvim/pull/2
		"chrisgrieser/regex.nvim",
		cmd = "RegexHelper", -- called in javascript & typescript ftplugins
		dev = true,
		opts = true,
	},
	{ -- autopair brackets/quotes
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			-- add brackets to cmp completions, e.g. "function" -> "function()"
			local ok, cmp = pcall(require, "cmp")
			if ok then
				local cmp_autopairs = require("nvim-autopairs.completion.cmp")
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end

			require("nvim-autopairs").setup {
				check_ts = true, -- use treesitter
			}

			-- CUSTOM RULES
			-- DOCS https://github.com/windwp/nvim-autopairs/wiki/Rules-API
			local rule = require("nvim-autopairs.rule")
			local isNodeType = require("nvim-autopairs.ts-conds").is_ts_node
			local negLookahead = require("nvim-autopairs.conds").not_after_regex

			require("nvim-autopairs").add_rules {
				rule("<", ">", "lua"):with_pair(isNodeType { "string", "string_content" }),
				rule("<", ">", { "vim", "html", "xml" }), -- keymaps & tags
				rule('\\"', '\\"', { "sh", "json" }), -- escaped quotes
				rule("*", "*", "markdown"), -- italics
				rule("__", "__", "markdown"), -- bold
				rule("![", "]()", "markdown"):set_end_pair_length(1), -- images

				-- auto-add trailing semicolon, but only for declarations
				-- (which are at the end of the line and have no text afterwards)
				rule(":", ";", "css"):with_pair(negLookahead(".")),

				-- auto-add trailing comma inside tables/objects
				rule("=", ",", "lua")
					:with_pair(negLookahead(" ?}", 3)) -- not in one-liner
					:with_pair(isNodeType { "table_constructor", "field" }),
				rule(":", ",", { "javascript", "typescript", "json" })
					:with_pair(negLookahead(" ?}", 3)) -- not in one-liner
					:with_pair(isNodeType("object")),
				rule("", ",") -- automatically move past commas
					:with_move(function(opts) return opts.char == "," end)
					:with_pair(function() return false end)
					:with_del(function() return false end)
					:with_cr(function() return false end)
					:use_key(","),

				-- add brackets to if/else in js/ts
				rule("^%s*if $", "()", { "javascript", "typescript" })
					:use_regex(true)
					:set_end_pair_length(1), -- only move one char to the side
				rule("^%s*else if $", "()", { "javascript", "typescript" })
					:use_regex(true)
					:set_end_pair_length(1),
				rule("^%s*} ?else if $", "() {", { "javascript", "typescript" })
					:use_regex(true)
					:set_end_pair_length(3),

				-- quicker template string
				rule("$", "{}", { "javascript", "typescript", "json" })
					:with_pair(isNodeType { "string", "template_string", "string_fragment" })
					:set_end_pair_length(1),
			}
		end,
	},
	{ -- virtual text context at the end of a scope
		"haringsrob/nvim_context_vt",
		event = "VeryLazy",
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			prefix = " 󱞷",
			highlight = "NonText",
			min_rows = 7,
			disable_ft = { "markdown", "css" },
			-- Disable display of virtual text below blocks for indentation based
			-- languages like Python
			disable_virtual_lines_ft = { "yaml" },
		},
	},
	{ -- automatically set correct indent for file
		"nmac427/guess-indent.nvim",
		event = "BufReadPre",
		opts = { override_editorconfig = false },
	},
	{ -- basically autopair, but for keywords
		"RRethy/nvim-treesitter-endwise",
		event = "InsertEnter",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- case conversion
		"johmsalas/text-case.nvim",
		init = function()
			local casings = {
				{ char = "u", arg = "upper", desc = "UPPER CASE" },
				{ char = "l", arg = "lower", desc = "lower case" },
				{ char = "t", arg = "title", desc = "Title case" },
				{ char = "c", arg = "camel", desc = "camelCase" },
				{ char = "s", arg = "snake", desc = "snake_case" },
				{ char = "k", arg = "dash", desc = "kebab-case" },
				{ char = "/", arg = "path", desc = "path/case" },
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
			allow_interline_swaps = true,
			interline_swaps_witout_separator = false,
		},
		keys = {
			-- stylua: ignore
			{ "ü", function() require("sibling-swap").swap_with_right() end, desc = "󰔰 Move Node Right" },
			-- stylua: ignore
			{ "Ü", function() require("sibling-swap").swap_with_left() end, desc = "󰶢 Move Node Left" },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown", "text", "gitcommit" },
				callback = function()
					-- stylua: ignore
					vim.keymap.set("n", "ü", '"zdawel"zph', { desc = "󰔰 Move Word Right", buffer = true })
					-- stylua: ignore
					vim.keymap.set("n", "Ü", '"zdawbh"zph', { desc = "󰶢 Move Word Left", buffer = true })
				end,
			})
		end,
	},
	{ -- fixes scrolloff at end of file
		"Aasim-A/scrollEOF.nvim",
		event = "CursorMoved",
		opts = true,
	},
	{ -- split-join lines
		"Wansmer/treesj",
		dependencies = "nvim-treesitter/nvim-treesitter",
		keys = {
			{ "<leader>s", function() require("treesj").toggle() end, desc = "󰗈 Split-join lines" },
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
			-- INFO not binding p/P in visual mode, since I prefer my switch of
			-- "p" and "P" to be in visual mode for not replacing stuff
			{ "p", "<Plug>(YankyPutAfter)", desc = " Paste (Yanky)" },
			{ "P", "<Plug>(YankyCycleForward)", desc = " Cycle Killring" },
			{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = " Sticky Yank" },
			{ "Y", "y$" }, -- is already sticky, but to be set to load Yanky for lazy loading
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
	{ -- which-key
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup {
				triggers_blacklist = {
					-- FIX very weird bug where insert mode undo points (<C-g>u),
					-- as well as vim-matchup's `<C-G>%` binding insert extra `1`s
					-- after wrapping to the next line in insert mode. The `G` needs
					-- to be uppercased to affect the right mapping.
					i = { "<C-G>" },
				},
				plugins = {
					presets = { motions = false, g = false, z = false },
					spelling = { enabled = false },
				},
				-- INFO ignore a mapping with desc "which_key_ignore", with this "hidden" setting
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
			}

			-----------------------------------------------------------------------

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

			-- needed so localleader prefixes work with whichkey
			require("which-key").register {
				["<localleader>"] = { name = "filetype-specific", mode = { "n", "x" } },
			}

			-- set by some plugins and unnecessarily clobbers whichkey
			vim.keymap.set("n", "<LeftMouse>", "<Nop>")
		end,
	},
}
