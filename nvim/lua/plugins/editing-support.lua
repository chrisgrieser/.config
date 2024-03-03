local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- automatically set correct indent for file
		"nmac427/guess-indent.nvim",
		event = "BufReadPre",
		opts = { override_editorconfig = false },
	},
	{ -- comment
		"numToStr/Comment.nvim",
		keys = {
			{ "q", mode = { "n", "x" }, desc = " Comment Operator" },
			{ "Q", desc = " Append Comment at EoL" },
		},
		opts = {
			opleader = { line = "q", block = "<Nop>" },
			toggler = { line = "qq", block = "<Nop>" },
			extra = { eol = "Q", above = "qO", below = "qo" },
		},
	},
	{ -- surround
		"kylechui/nvim-surround",
		keys = {
			{ "ys", desc = "󰅪 Add Surround Operator" },
			{ "s", mode = "x", desc = "󰅪 Add Surround Operator" },
			{ "yS", "ys$", desc = "󰅪 Surround to EoL", remap = true },
			{ "ds", desc = "󰅪 Delete Surround Operator" },
			{ "cs", desc = "󰅪 Change Surround Operator" },
		},
		opts = {
			move_cursor = false,
			aliases = u.textobjRemaps,
			keymaps = {
				visual = "s",
				normal_line = false,
				normal_cur_line = false,
				visual_line = false,
				insert_line = false,
				insert = false,
			},
			surrounds = {
				invalid_key_behavior = { add = false, find = false, delete = false, change = false },
				-- `dsl` -> delete surrounding call
				-- (includes : for lua methods and css pseudo-classes)
				["l"] = {
					find = "[%w.:]+%b()",
					delete = "([%w.:]+%()().-(%))()",
				},
				["R"] = { -- wikilink
					find = "%[%[.-%]%]",
					add = { "[[", "]]" },
					delete = "(%[%[)().-(%]%])()",
					change = {
						target = "(%[%[)().-(%]%])()",
					},
				},
				["/"] = { -- regex
					find = "/.-/",
					add = { "/", "/" },
					delete = "(/)().-(/)()",
					change = {
						target = "(/)().-(/)()",
					},
				},
			},
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
			vim.g.undotree_DiffAutoOpen = 0
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

			require("nvim-autopairs").add_rules {
				rule("<", ">", "lua"):with_pair(isNodeType { "string", "string_content" }),
				rule("<", ">", { "vim", "html", "xml" }), -- keymaps & tags

				-- css: auto-add trailing semicolon, but only for declarations
				-- (which are at the end of the line and have no text afterwards)
				rule(":", ";", "css"):with_pair(negLookahead(".", 1)),

				-- auto-add trailing comma inside objects/arrays
				rule([[^%s*[:=%w]$]], ",", { "javascript", "typescript", "lua", "python" })
					:use_regex(true)
					:with_pair(negLookahead(".+")) -- neg. cond has to come first
					:with_pair(isNodeType { "table_constructor", "field", "object", "dictionary" })
					:with_del(function() return false end)
					:with_move(function(opts) return opts.char == "," end),

				-- git commit with scope auto-append `(` to `(): `
				rule("^%a+%(%)", ": ", "gitcommit")
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
			}
		end,
	},
	{ -- autopair, but for keywords
		"RRethy/nvim-treesitter-endwise",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = "InsertEnter",
	},
	{ -- auto-convert string and f/template string
		"chrisgrieser/nvim-puppeteer",
		ft = { "python", "javascript", "typescript", "lua" },
		cmd = "PuppeteerToggle",
		init = function() vim.g.puppeteer_disable_filetypes = {} end,
		keys = {
			{ "<leader>op", vim.cmd.PuppeteerToggle, desc = "󰅳 Puppeteer" },
		},
	},
	{ -- swapping of sibling nodes
		"Wansmer/sibling-swap.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		keys = {
			-- stylua: ignore start
			{ "ä", function() require("sibling-swap").swap_with_right() end, desc = "󰔰 Move Node Right" },
			{ "Ä", function() require("sibling-swap").swap_with_left() end, desc = "󰶢 Move Node Left" },
			-- stylua: ignore end
			{ "ä", '"zdawel"zph', ft = "markdown", desc = "󰶢 Move Word Right" },
			{ "Ä", '"zdawbh"zph', ft = "markdown", desc = "󰶢 Move Word Left" },
		},
		opts = {
			use_default_keymaps = false,
			allowed_separators = { "..", "*" }, -- add multiplication & lua string concatenation
			highlight_node_at_cursor = true,
			ignore_injected_langs = true,
			allow_interline_swaps = true,
			interline_swaps_without_separator = false,
		},
	},
	{ -- split-join lines
		"Wansmer/treesj",
		keys = {
			{ "<leader>s", function() require("treesj").toggle() end, desc = "󰗈 Split-join lines" },
			{ "<leader>s", "gww", ft = { "markdown", "applescript" }, desc = "󰗈 Split line" },
		},
		opts = {
			use_default_keymaps = false,
			cursor_behavior = "start",
			max_join_length = 160,
		},
		config = function(_, opts)
			local gww = { both = { fallback = function() vim.cmd("normal! gww") end } }
			local curleyLessIfStatementJoin = {
				-- remove curly brackets in js when joining if statements https://github.com/Wansmer/treesj/issues/150
				statement_block = {
					join = {
						format_tree = function(tsj)
							if tsj:tsnode():parent():type() == "if_statement" then
								tsj:remove_child { "{", "}" }
							else
								require("treesj.langs.javascript").statement_block.join.format_tree(tsj)
							end
						end,
					},
				},
				-- one-line-if-statement can be split into multi-line https://github.com/Wansmer/treesj/issues/150
				expression_statement = {
					join = { enable = false },
					split = {
						enable = function(tsn) return tsn:parent():type() == "if_statement" end,
						format_tree = function(tsj) tsj:wrap { left = "{", right = "}" } end,
					},
				},
			}
			opts.langs = {
				python = { string_content = gww }, -- python docstrings
				rst = { paragraph = gww }, -- python docstrings (when rsg is injected)
				comment = { source = gww, element = gww }, -- comments in any language
				jsdoc = { source = gww, description = gww },
				javascript = curleyLessIfStatementJoin,
				typescript = curleyLessIfStatementJoin,
			}
			require("treesj").setup(opts)
		end,
	},
	{ -- which-key
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
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
				border = { "", "─", "", "" }, -- only horizontal border to save space
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
		config = function(_, opts)
			local whichkey = require("which-key")
			whichkey.setup(opts)

			-- leader prefixes normal mode
			whichkey.register({
				u = { name = " 󰕌 Undo" },
				o = { name = "  Options" },
				p = { name = " 󰏗 Packages" },
				c = { name = "  Code Action" },
				i = { name = " 󱡴 Inspect" },
			}, { prefix = "<leader>" })

			-- leader prefixes normal+visual mode
			whichkey.register({
				f = { name = " 󱗘 Refactor" },
				g = { name = " 󰊢 Git" },
			}, { prefix = "<leader>", mode = { "x", "n" } })

			-- set by some plugins and unnecessarily clobbers whichkey
			vim.keymap.set("o", "<LeftMouse>", "<Nop>")
		end,
	},
	{
		"chrisgrieser/nvim-chainsaw",
		init = function() u.leaderSubkey("l", " Log") end,
		opts = {
			marker = "🔹",
			logStatements = {
				objectLog = {
					-- Obsidian API
					typescript = 'new Notice ("%s %s:" + %s.toString())',
				},
			},
		},
		keys = {
			-- stylua: ignore start
			{"<leader>lb", function() require("chainsaw").beepLog() end, desc = "󰸢 beep log" },
			{"<leader>ll", function() require("chainsaw").variableLog() end, mode = {"n", "x"}, desc = "󰸢 variable log" },
			{"<leader>lo", function() require("chainsaw").objectLog() end, mode = {"n", "x"}, desc = "󰸢 object log" },
			{"<leader>lm", function() require("chainsaw").messageLog() end, desc = "󰸢 message log" },
			{"<leader>lt", function() require("chainsaw").timeLog() end, desc = "󰸢 time log" },
			{"<leader>ld", function() require("chainsaw").debugLog() end, desc = "󰸢 debugger log" },
			{"<leader>la", function() require("chainsaw").assertLog() end, mode = {"n", "x"}, desc = "󰸢 assert log" },

			{"<leader>lr", function() require("chainsaw").removeLogs() end, desc = "󰹝 remove logs" },
			-- stylua: ignore end
		},
	},
}
