local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- comment
		"numToStr/Comment.nvim",
		keys = {
			{ "q", mode = { "n", "x" }, desc = " Comment Operator" },
			{ "Q", desc = " Append Comment at EoL" },
			{ "qo", desc = " Comment below" },
			{ "qO", desc = " Comment above" },
		},
		opts = {
			opleader = { line = "q", block = "<Nop>" },
			toggler = { line = "qq", block = "<Nop>" },
			extra = { eol = "Q", above = "qO", below = "qo" },
		},
	},
	{ -- undo history
		"mbbill/undotree",
		keys = {
			{ "<leader>ut", vim.cmd.UndotreeToggle, desc = " Undotree" },
		},
		init = function()
			vim.g.undotree_WindowLayout = 3
			vim.g.undotree_DiffpanelHeight = 10
			vim.g.undotree_ShortIndicators = 1
			vim.g.undotree_SplitWidth = 30
			vim.g.undotree_DiffAutoOpen = 1
			vim.g.undotree_SetFocusWhenToggle = 1
			vim.g.undotree_HelpLine = 1

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "undotree",
				callback = function()
					vim.defer_fn(function()
						vim.keymap.set("n", "J", "6j", { buffer = true })
						vim.keymap.set("n", "K", "6k", { buffer = true })
					end, 1)
				end,
			})
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

				-- git commit with scope auto-append `()` to `:`
				rule("^%a+%(%)", ":", "gitcommit")
					:use_regex(true)
					:with_pair(negLookahead(".+"))
					:with_pair(isNotNodeType("message"))
					:with_move(function(opts) return opts.char == ":" end),

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
	{ -- swapping of sibling nodes
		"Wansmer/sibling-swap.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			use_default_keymaps = false,
			allowed_separators = { "..", "*" }, -- add multiplication & lua string concatenation
			highlight_node_at_cursor = true,
			ignore_injected_langs = true,
			allow_interline_swaps = true,
			interline_swaps_without_separator = false,
		},
		keys = {
			-- stylua: ignore
			{ "ü", function() require("sibling-swap").swap_with_right() end, desc = "󰔰 Move Node Right" },
			-- stylua: ignore
			{ "Ü", function() require("sibling-swap").swap_with_left() end, desc = "󰶢 Move Node Left" },
		},
	},
	{ -- split-join lines
		"Wansmer/treesj",
		init = function()
			-- always use `gww` in markdown
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function() vim.keymap.set("n", "<leader>s", "gww", { buffer = true }) end,
			})
		end,
		keys = {
			{ "<leader>s", function() require("treesj").toggle() end, desc = "󰗈 Split-join lines" },
		},
		opts = {
			use_default_keymaps = false,
			cursor_behavior = "start",
			max_join_length = 160,
			langs = {
				python = { -- python docstrings
					string_content = { both = { fallback = function() vim.cmd("normal! gww") end } },
				},
				comment = { -- comments in any language
					source = { both = { fallback = function() vim.cmd("normal! gww") end } },
					element = { both = { fallback = function() vim.cmd("normal! gww") end } },
				},
			},
		},
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
				p = { name = " 󰏗 Packages" },
				d = { name = "  Diagnostics" },
				c = { name = "  Calls" },
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
	{
		"chrisgrieser/nvim-chainsaw",
		keys = {
			-- stylua: ignore start
			{"<leader>lb", function() require("chainsaw").beepLog() end, desc = "󰸢 beep log" },
			{"<leader>lm", function() require("chainsaw").messageLog() end, desc = "󰸢 message log" },
			{"<leader>l1", function() require("chainsaw").timeLog() end, desc = "󰸢 time log" },
			{"<leader>ld", function() require("chainsaw").debugLog() end, desc = "󰸢 debugger log" },
			{"<leader>lr", function() require("chainsaw").removeLogs() end, desc = "󰹝 remove logs" },

			{"<leader>ll", function() require("chainsaw").variableLog() end, mode = {"n", "x"}, desc = "󰸢 variable log" },
			{"<leader>lo", function() require("chainsaw").objectLog() end, mode = {"n", "x"}, desc = "󰸢 object log" },
			{"<leader>la", function() require("chainsaw").assertLog() end, mode = {"n", "x"}, desc = "󰸢 assert log" },
			-- stylua: ignore end
		},
	},
}
