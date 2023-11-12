--# selene: allow(mixed_table) -- lazy.nvim uses them
local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- better increment/decrement + toggling command
		"monaqa/dial.nvim",
		keys = {
			{
				"+",
				function() return require("dial.map").inc_normal() end,
				desc = "󰘂 Dial +",
				expr = true,
			},
			{
				"ä",
				function() return require("dial.map").dec_normal() end,
				desc = "󰘂 Dial -",
				expr = true,
			},
		},
		config = function()
			local augend = require("dial.augend")
			local toggle = require("dial.augend").constant.new
			require("dial.config").augends:register_group {
				default = {
					augend.integer.alias.decimal_int,
					augend.constant.alias.bool,
					toggle { elements = { "let", "const" } },
					toggle { elements = { "and", "or" } },
					toggle { elements = { "increase", "decrease" }, word = false },
					toggle { elements = { "enable", "disable" }, word = false },
					toggle { elements = { "dark", "light" }, word = false },
					toggle { elements = { "right", "left" }, word = false },
					toggle { elements = { "~=", "==" }, word = false },
					toggle { elements = { "!==", "===" }, word = false },
					toggle { elements = { "&&", "||" }, word = false },
				},
			}
		end,
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

			-- CUSTOM RULES
			-- DOCS https://github.com/windwp/nvim-autopairs/wiki/Rules-API
			require("nvim-autopairs").setup { check_ts = true } -- use treesitter for custom rules

			local rule = require("nvim-autopairs.rule")
			local isNodeType = require("nvim-autopairs.ts-conds").is_ts_node
			local isNotNodeType = require("nvim-autopairs.ts-conds").is_not_ts_node
			local negLookahead = require("nvim-autopairs.conds").not_after_regex
			local notBefore = require("nvim-autopairs.conds").not_before_text

			require("nvim-autopairs").add_rules {
				rule("<", ">", "lua"):with_pair(isNodeType { "string", "string_content" }),
				rule("<", ">", { "vim", "html", "xml" }), -- keymaps & tags
				rule("*", "*", "markdown"), -- italics
				rule("![", "]()", "markdown"):set_end_pair_length(1), -- images

				-- git conventional commit with scope: auto-append `:`
				rule("^%a+%(%)", ":", "gitcommit")
					:use_regex(true)
					:with_pair(negLookahead(".+"))
					:with_pair(isNotNodeType("message"))
					:with_move(function(opts) return opts.char == ":" end),

				-- auto-add trailing semicolon, but only for declarations
				-- (which are at the end of the line and have no text afterwards)
				rule(":", ";", "css"):with_pair(negLookahead(".+")),

				-- auto-add trailing comma inside objects/arrays
				rule([[^%s*[:=%w]$]], ",", { "javascript", "typescript", "lua", "python" })
					:use_regex(true)
					:with_pair(negLookahead(".+")) -- neg. cond has to come first
					:with_pair(notBefore(vim.bo.commentstring))
					:with_pair(isNodeType { "table_constructor", "field", "object", "dictionary" })
					:with_del(function() return false end)
					:with_move(function(opts) return opts.char == "," end),

				-- add brackets to if/else in js/ts
				rule("^%s*if $", "()", { "javascript", "typescript" })
					:use_regex(true)
					:with_del(function() return false end)
					:set_end_pair_length(1), -- only move one char to the side
				rule("^%s*else if $", "()", { "javascript", "typescript" })
					:use_regex(true)
					:with_del(function() return false end)
					:set_end_pair_length(1),
				rule("^%s*} ?else if $", "() {", { "javascript", "typescript" })
					:use_regex(true)
					:with_del(function() return false end)
					:set_end_pair_length(3),

				-- add colon to if/else in python
				rule("^%s*e?l?if$", ":", "python")
					:use_regex(true)
					:with_del(function() return false end)
					:with_pair(isNotNodeType("string_content")), -- no docstrings
				rule("^%s*else$", ":", "python")
					:use_regex(true)
					:with_del(function() return false end)
					:with_pair(isNotNodeType("string_content")), -- no docstrings
				rule("", ":", "python") -- automatically move past colons
					:with_move(function(opts) return opts.char == ":" end)
					:with_pair(function() return false end)
					:with_del(function() return false end)
					:with_cr(function() return false end)
					:use_key(":"),

				-- quicker template string
				rule("$", "{}", { "javascript", "typescript" })
					:with_pair(negLookahead("{", 1))
					:with_pair(isNodeType { "string", "template_string", "string_fragment" })
					:set_end_pair_length(1),
			}
		end,
	},
	{ -- auto-convert string and f/template string
		"chrisgrieser/nvim-puppeteer",
		ft = { "python", "javascript", "typescript", "lua" },
		init = function() vim.g.puppeteer_lua_format_string = true end,
		keys = {
			{ -- Toggle string formatting in lua
				"<leader>op",
				function()
					vim.g.puppeteer_lua_format_string = not vim.g.puppeteer_lua_format_string
					local status = vim.g.puppeteer_lua_format_string and "enabled" or "disabled"
					u.notify("Puppeteer", "Lua string formatting " .. status)
				end,
				ft = "lua",
				desc = "󰅳 Lua string formatting",
			},
		},
	},
	{ -- autopair, but for keywords
		"RRethy/nvim-treesitter-endwise",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = "InsertEnter",
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
	},
	{ -- fixes scrolloff at end of file
		"Aasim-A/scrollEOF.nvim",
		event = "CursorMoved",
		opts = true,
	},
	{ -- split-join lines
		"Wansmer/treesj",
		keys = {
			{ "<leader>s", function() require("treesj").toggle() end, desc = "󰗈 Split-join lines" },
		},
		opts = {
			use_default_keymaps = false,
			cursor_behavior = "start",
			max_join_length = 160,
			langs = {
				python = {
					string_content = { -- python docstrings
						both = { fallback = function() vim.cmd("normal! gww") end },
					},
				},
				comment = {
					source = {
						both = { fallback = function() vim.cmd("normal! gww") end },
					},
				},
				html = {
					fragment = {
						both = { fallback = function() vim.cmd("normal! gww") end },
					},
				},
				markdown_inline = {
					inline = {
						both = { fallback = function() vim.cmd("normal! gww") end },
					},
				},
			},
		},
	},
	{ -- killring & highlights on `p`
		"gbprod/yanky.nvim",
		keys = {
			-- https://github.com/gbprod/yanky.nvim#%EF%B8%8F-special-put
			{ "p", "<Plug>(YankyPutAfter)", desc = " Paste (Yanky)" },
			{ "P", "<Plug>(YankyPutIndentAfterShiftRight)", desc = " Paste & Indent" },
			{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = " Sticky Yank" },
			{ "<D-p>", "<Plug>(YankyCycleForward)", desc = " Cycle Killring" },
			{
				"p",
				function() require("yanky.textobj").last_put() end,
				mode = "o",
				desc = "󱡔 Last Paste textobj",
			},
			-- so it loads the killring in time
			{ "Y", "y$" },
			"d",
			"D",
		},
		opts = {
			ring = { history_length = 100 }, -- also relevant for cmp_yanky
			highlight = { timer = 1000 },
			textobj = { enabled = true },
		},
		-- IncSearch is the default highlight group for post-yank highlights
		init = function() u.colorschemeMod("YankyYanked", { link = "IncSearch" }) end,
	},
	{ -- which-key
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup {
				-- FIX very weird bug where insert mode undo points (<C-g>u),
				-- as well as vim-matchup's `<C-G>%` binding insert extra `1`s
				-- after wrapping to the next line in insert mode. The `G` needs
				-- to be uppercased to affect the right mapping.
				triggers_blacklist = { i = { "<C-G>" } },

				plugins = {
					presets = { motions = false, g = false, z = false },
					spelling = { enabled = false },
				},
				-- INFO ignore a mapping with desc "which_key_ignore", with this "hidden" setting
				hidden = { "<Plug>", "^:lua ", "<cmd>" },
				key_labels = {
					["<CR>"] = "↵",
					["<BS>"] = "⌫",
					["<space>"] = "󱁐",
					["<Tab>"] = "󰌒",
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
				u = { name = " 󰕌 Undo" },
				o = { name = "  Options" },
				p = { name = " 󰏗 Package" },
			}, { prefix = "<leader>" })

			-- leader prefixes normal+visual mode
			require("which-key").register({
				f = { name = " 󱗘 Refactor" },
				l = { name = "  Log / Cmdline" },
				g = { name = " 󰊢 Git" },
			}, { prefix = "<leader>", mode = { "x", "n" } })

			-- needed so localleader prefixes work with whichkey
			require("which-key").register {
				["<localleader>"] = { name = "filetype-specific", mode = { "n", "x" } },
			}

			-- set by some plugins and unnecessarily clobbers whichkey
			vim.keymap.set("o", "<LeftMouse>", "<Nop>")
		end,
	},
}
