local u = require("config.utils")
local textObjMaps = require("config.utils").extraTextobjMaps
--------------------------------------------------------------------------------

return {
	{
		"chrisgrieser/nvim-rip-substitute",
		keys = {
			{
				"<leader>fs",
				function() require("rip-substitute").sub() end,
				mode = { "n", "x" },
				desc = " rip substitute",
			},
		},
		opts = {
			popupWin = {
				width = 35,
				border = vim.g.borderStyle,
			},
		},
	},
	{ -- refactoring utilities
		"ThePrimeagen/refactoring.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		opts = { show_success_message = true },
		keys = {
			{
				"<leader>fi",
				function() require("refactoring").refactor("Inline Variable") end,
				mode = { "n", "x" },
				desc = "󱗘 Inline Var",
			},
			{
				"<leader>fe",
				function() require("refactoring").refactor("Extract Variable") end,
				mode = "x",
				desc = "󱗘 Extract Var",
			},
		},
	},
	{ -- substitute & duplicate operator
		"echasnovski/mini.operators",
		keys = {
			{ "s", desc = "󰅪 Substitute Operator" }, -- in visual mode, `s` surrounds
			{ "w", mode = { "n", "x" }, desc = "󰅪 Multiply Operator" },
			{ "sy", mode = { "n", "x" }, desc = "󰅪 Sort Operator" },
			{ "sx", mode = { "n", "x" }, desc = "󰅪 Exchange Operator" },
			{ "S", "s$", desc = "󰅪 Substitute to EoL", remap = true },
			{ "W", "w$", desc = "󰅪 Multiply to EoL", remap = true },
			{ "sX", "sx$", desc = "󰅪 Exchange to EoL", remap = true },
			{ "sY", "sy$", desc = "󰅪 Sort to EoL", remap = true },
		},
		config = function(_, opts)
			require("mini.operators").setup(opts)

			-- Do not set `substitute` mapping for visual mode, since we use `s` for
			-- `surround` there, and `p` effectively already substitutes
			require("mini.operators").make_mappings(
				"replace",
				{ textobject = "s", line = "ss", selection = "" }
			)
		end,
		opts = {
			evaluate = { prefix = "" }, -- disable
			replace = { prefix = "", reindent_linewise = true },
			exchange = { prefix = "sx", reindent_linewise = true },
			sort = { prefix = "sy" },
			multiply = {
				prefix = "w",
				func = function(content)
					-- IF LINEWISE, TRANSFORM 1ST LNE
					if content.submode == "V" then
						local line = content.lines[1]
						local ft = vim.bo.filetype

						if ft == "css" then
							if line:find("top:") then
								line = line:gsub("top:", "bottom:")
							elseif line:find("bottom:") then
								line = line:gsub("bottom:", "top:")
							end
							if line:find("right:") then
								line = line:gsub("right:", "left:")
							elseif line:find("left:") then
								line = line:gsub("left:", "right:")
							end
						elseif ft == "javascript" or ft == "typescript" then
							if line:find("^%s*if.+{$") then line = line:gsub("^(%s*)if", "%1} else if") end
						elseif ft == "lua" then
							if line:find("^%s*if.+then%s*$") then
								line = line:gsub("^(%s*)if", "%1elseif")
							end
						elseif ft == "sh" then
							if line:find("^%s*if.+then$") then line = line:gsub("^(%s*)if", "%1elif") end
						elseif ft == "python" then
							if line:find("^%s*if.+:$") then line = line:gsub("^(%s*)if", "%1elif") end
						end

						content.lines[1] = line
					end

					-- REMEMBER CURSOR COLUMN
					-- HACK needs to work with `defer_fn`, since the transformer function is
					-- called only before multiplication
					local rowBefore = vim.api.nvim_win_get_cursor(0)[1]
					vim.defer_fn(function()
						local rowAfter = vim.api.nvim_win_get_cursor(0)[1]
						local line = vim.api.nvim_get_current_line()
						local _, valuePos = line:find("[:=] ? %S") -- find value
						local _, _, fieldPos = line:find("@.-()%w+$") -- luadoc or jsdoc
						local gotoPos = fieldPos or valuePos
						if rowBefore ~= rowAfter and gotoPos then
							vim.api.nvim_win_set_cursor(0, { rowAfter, gotoPos - 1 })
						end
					end, 1)

					return content.lines
				end,
			},
		},
	},
	{ -- automatically set correct indent for file
		"nmac427/guess-indent.nvim",
		event = "BufReadPre",
		opts = true,
	},
	{ -- surround
		"kylechui/nvim-surround",
		keys = {
			{ "ys", desc = "󰅪 Add Surround Operator" },
			{ "s", mode = "x", desc = "󰅪 Add Surround Operator" },
			{ "yS", "ys$", desc = "󰅪 Surround to EoL", remap = true },
			{ "ds", desc = "󰅪 Delete Surround Operator" },
			{ "cs", desc = "󰅪 Change Surround Operator" },
			{
				"<D-t>",
				"${}<Left>" .. '<Esc>cs"`a',
				mode = "i",
				remap = true,
				desc = "$󰘦 Template string & change quotes",
			},
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
				[textObjMaps.call] = {
					find = "[%w.:_]+%b()", -- includes `:` for lua methods and css pseudo-classes
					delete = "([%w.:_]+%()().-(%))()",
				},
				[textObjMaps.func] = {
					-- only one-line lua functions
					find = "function ?[%w_]* ?%b().- end",
					delete = "(function ?[%w_]* ?%b() ?)().-( end)()",
				},
				[textObjMaps.condition] = {
					-- only one-line lua conditionals
					find = "if .- then .- end",
					delete = "(if .- then )().-( end)()",
				},
				[textObjMaps.wikilink] = {
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
	{ -- autopair brackets/quotes
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			-- add brackets to cmp completions, e.g. "function" -> "function()"
			local ok, cmp = pcall(require, "cmp")
			if ok then
				local onConfirmDone = require("nvim-autopairs.completion.cmp").on_confirm_done()
				cmp.event:on("confirm_done", function(evt)
					if vim.bo.filetype == "css" then return end -- FIX autopairs broken for CSS
					onConfirmDone(evt)
				end)
			end

			-- CUSTOM RULES
			-- DOCS https://github.com/windwp/nvim-autopairs/wiki/Rules-API
			require("nvim-autopairs").setup { check_ts = true } -- use treesitter for custom rules

			local rule = require("nvim-autopairs.rule")
			local isNodeType = require("nvim-autopairs.ts-conds").is_ts_node
			local isNotNodeType = require("nvim-autopairs.ts-conds").is_not_ts_node
			local negLookahead = require("nvim-autopairs.conds").not_after_regex

			require("nvim-autopairs").add_rules {
				-- autopair <> for keymaps like `<C-d>` & html-tags
				rule("<", ">", "lua"):with_pair(isNodeType { "string", "string_content" }),
				rule("<", ">", { "vim", "html", "xml" }),

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
				i = { name = " 󱡴 Inspect" },
			}, { prefix = "<leader>" })

			-- leader prefixes normal+visual mode
			whichkey.register({
				c = { name = "  Code Action" },
				f = { name = " 󱗘 Refactor" },
				g = { name = " 󰊢 Git" },
			}, { prefix = "<leader>", mode = { "x", "n" } })

			-- set by some plugins and unnecessarily clobbers whichkey
			vim.keymap.set("o", "<LeftMouse>", "<Nop>")
		end,
	},
	{
		"chrisgrieser/nvim-chainsaw",
		init = function() u.leaderSubkey("l", " Log", { "n", "x" }) end,
		opts = {
			marker = "⭕",
			logStatements = {
				objectLog = {
					-- repurposing objectLog for debugging via AppleScript notification
					sh = [[osascript -e "display notification \"%s $%s\" with title \"%s\""]],

					-- hammerspoon
					lua = [[print("%s %s: " .. hs.inspect(%s))]],
				},
			},
		},
		keys = {
			-- stylua: ignore start
			{"<leader>ll", function() require("chainsaw").variableLog() end, mode = {"n", "x"}, desc = "󰸢 variable" },
			{"<leader>lo", function() require("chainsaw").objectLog() end, mode = {"n", "x"}, desc = "󰸢 object" },
			{"<leader>lb", function() require("chainsaw").beepLog() end, desc = "󰸢 beep" },
			{"<leader>lm", function() require("chainsaw").messageLog() end, desc = "󰸢 message" },
			{"<leader>lt", function() require("chainsaw").timeLog() end, desc = "󰸢 time" },
			{"<leader>ld", function() require("chainsaw").debugLog() end, desc = "󰸢 debugger" },
			{"<leader>ls", function() require("chainsaw").stacktraceLog() end, desc = "󰸢 stacktrace" },
			{"<leader>la", function() require("chainsaw").assertLog() end, mode = {"n", "x"}, desc = "󰸢 assert" },

			{"<leader>lr", function() require("chainsaw").removeLogs() end, desc = "󰹝 remove logs" },
			-- stylua: ignore end
		},
	},

	--------------------------------------------------------------------------------
}
