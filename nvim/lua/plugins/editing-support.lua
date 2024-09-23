local textObjMaps = require("config.utils").extraTextobjMaps
--------------------------------------------------------------------------------

---Set up plugin-specific groups cleanly with the plugin config.
---@param key string
---@param label string
vim.g.whichkeyAddGroup = function(key, label)
	-- delayed, to ensure whichkey spec is loaded & not interfere with whichkey's lazy-loading
	vim.defer_fn(function()
		local ok, whichkey = pcall(require, "which-key")
		if not ok then return end
		whichkey.add { { key, group = label, mode = { "n", "x" } } }
	end, 1500)
end

return {
	{ -- which-key
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			-- remove bindings so they do not clutter which-key
			vim.keymap.del("n", "gcc")
			vim.keymap.del("o", "gc")
		end,
		keys = {
			{
				"<leader>?",
				-- alternative: `:Telescope keymaps` with `only_buf = true`
				function() require("which-key").show { global = false } end,
				desc = "⌨️ Buffer Keymaps",
			},
		},
		opts = {
			delay = 400,
			spec = {
				{
					mode = { "n", "x" },
					{ "<leader>", group = "󰓎 Leader" },
					{ "<leader>c", group = " Code Action" },
					{ "<leader>x", group = "󰓗 Execute" },
					{ "<leader>f", group = "󱗘 Refactor" },
					{ "<leader>g", group = "󰊢 Git" },
					{ "<leader>i", group = "󱈄 Inspect" },
					{ "<leader>o", group = "󰒓 Options" },
					{ "<leader>p", group = "󰏗 Packages" },
					{ "<leader>u", group = "󰕌 Undo" },
					{ "<leader>y", group = "󰅍 Yank" },
				},
				{ -- not using `text_objects` preset, since it's too crowded
					mode = { "o", "x" },
					{ "r", group = "rest of" },
					{ "i", group = "inner" },
					{ "a", group = "outer" },
					{ "g", group = "misc" },
					{ "ip", desc = "¶ paragraph" },
					{ "ap", desc = "¶ paragraph" },
					{ "ib", desc = "󰅲 bracket" },
					{ "ab", desc = "󰅲 bracket" },
					{ "it", desc = " tag" },
					{ "at", desc = " tag" },
					{ "is", desc = "󰰢 sentence" },
					{ "as", desc = "󰰢 sentence" },
					{ "iw", desc = "󰬞 word" },
					{ "aw", desc = "󰬞 word" },
				},
			},
			plugins = {
				marks = false,
				spelling = false,
				presets = { motions = false, g = false, text_objects = false, z = false },
			},
			filter = function(map) return map.desc and map.desc ~= "" end,
			replace = {
				-- redundant for hints (frontier-pattern to keep "outer any…" mappings)
				desc = {
					{ " outer %f[^a ]", " " },
					{ " inner %f[^a ]", " " },
					{ " rest of ", " " },
				},
			},
			win = {
				border = vim.g.borderStyle,
				width = 0.9,
				height = { min = 5, max = 22 },
				padding = { 1, 1 },
				col = math.floor(vim.o.columns * 0.05),
			},
			layout = {
				spacing = 2,
				width = { max = 34 },
				align = "left",
			},
			keys = { scroll_down = "<PageDown>", scroll_up = "<PageUp>" },
			icons = {
				mappings = false, -- not using auto-added icons, since I set my own
				group = "",
				separator = "│",
			},
			show_help = false,
		},
	},
	{ -- auto-pair
		-- EXAMPLE config of the plugin: https://github.com/Bekaboo/nvim/blob/master/lua/configs/ultimate-autopair.lua
		"altermo/ultimate-autopair.nvim",
		branch = "v0.6", -- recommended as each new version will have breaking changes
		event = { "InsertEnter", "CmdlineEnter" },
		opts = {
			bs = {
				space = "balance",
				cmap = false, -- keep my `<BS>` mapping for the cmdline
			},
			fastwarp = {
				map = "<D-f>",
				rmap = "<D-F>", -- backwards
				hopout = true,
				nocursormove = true,
				multiline = false,
			},
			cr = { autoclose = true },
			space = { enable = true },
			space2 = { enable = true },

			config_internal_pairs = {
				{ "'", "'", nft = { "markdown" } }, -- since used as apostroph
				{ '"', '"', nft = { "vim" } }, -- vimscript uses quotes as comments
			},
			-- INFO custom keys need to be "appended" to the opts as a list
			{ "*", "*", ft = { "markdown" } }, -- italics
			{ "__", "__", ft = { "markdown" } }, -- bold
			{ [[\"]], [[\"]], ft = { "zsh", "json", "applescript" } }, -- escaped quote

			{ -- commit scope (= only first word) for commit messages
				"(",
				"): ",
				ft = { "gitcommit" },
				cond = function(_) return not vim.api.nvim_get_current_line():find(" ") end,
			},

			-- for keymaps like `<C-a>`
			{ "<", ">", ft = { "vim" } },
			{ "<", ">", ft = { "lua" }, cond = function(fn) return fn.in_string() end },
		},
	},
	{ -- substitute & duplicate operator
		"echasnovski/mini.operators",
		keys = {
			{ "s", desc = "󰅪 Substitute Operator" }, -- in visual mode, `s` surrounds
			{ "w", mode = { "n", "x" }, desc = "󰅪 Multiply Operator" },
			{ "sy", desc = "󰅪 Sort Operator" },
			{ "sx", desc = "󰅪 Exchange Operator" },
			{ "S", "s$", desc = "󰅪 Substitute to EoL", remap = true },
			{ "W", "w$", desc = "󰅪 Multiply to EoL", remap = true },
			{ "sX", "sx$", desc = "󰅪 Exchange to EoL", remap = true },
		},
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
		config = function(_, opts)
			require("mini.operators").setup(opts)

			-- Do not set `substitute` mapping for visual mode, since we use `s` for
			-- `surround` there, and `p` effectively already substitutes
			require("mini.operators").make_mappings(
				"replace",
				{ textobject = "s", line = "ss", selection = "" }
			)
		end,
	},
	{ -- surround
		"kylechui/nvim-surround",
		keys = {
			{ "ys", desc = "󰅪 Add Surround Op." },
			{ "yS", "ys$", desc = "󰅪 Surround to EoL", remap = true },
			{ "s", mode = "x", desc = "󰅪 Add Surround Op." },
			{ "ds", desc = "󰅪 Delete Surround Op." },
			{ "cs", desc = "󰅪 Change Surround Op." },
		},
		opts = {
			move_cursor = false,
			aliases = { c = "}", r = "]", m = "W", q = '"', z = "'", e = "`" },
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
					delete = "([%w.:_]+%()().*(%))()",
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
				["/"] = { -- regex
					find = "/.-/",
					add = { "/", "/" },
					delete = "(/)().-(/)()",
					change = { target = "(/)().-(/)()" },
				},
			},
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
			{ "ä", '"zdawel"zph', ft = "markdown", desc = "󰔰 Move Word Right" },
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
			{ "<leader>s", "gww", ft = { "applescript", "plaintext" }, desc = "󰗈 Split line" },
			{ "<leader>s", "gwip", ft = "markdown", desc = "󰗈 Reflow paragraph" },
		},
		opts = {
			use_default_keymaps = false,
			cursor_behavior = "start",
			max_join_length = math.huge,
		},
		config = function(_, opts)
			local gww = { both = { fallback = function() vim.cmd("normal! gww") end } }
			local joinWithoutCurly = {
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
				rst = { paragraph = gww }, -- python docstrings (when rst is injected)
				comment = { source = gww, element = gww }, -- comments in any language
				lua = { comment = gww },
				jsdoc = { source = gww, description = gww },
				javascript = joinWithoutCurly,
				typescript = joinWithoutCurly,
			}
			require("treesj").setup(opts)
		end,
	},
	{ -- quick adding log statements
		"chrisgrieser/nvim-chainsaw",
		init = function() vim.g.whichkeyAddGroup("<leader>l", "󰐪 Log") end,
		opts = {
			marker = "🖨️",
			logStatements = {
				-- using lua for hammerspoon statements
				objectLog = { lua = 'print("%s %s: " .. hs.inspect(%s))' },
				clearLog = { lua = "hs.console.clearConsole() -- %s" },
				sound = {
					lua = 'hs.sound.getByName("Morse"):play() -- %s',
					nvim_lua = 'vim.system({"osascript", "-e", "beep"}) -- %s', -- macOS only
				},
			},
		},
		cmd = "ChainSaw",
		keys = {
			-- stylua: ignore start
			{"<leader>ll", function() require("chainsaw").variableLog() end, mode = {"n", "x"}, desc = "󰀫 variable" },
			{"<leader>lo", function() require("chainsaw").objectLog() end, mode = {"n", "x"}, desc = "⬠ object" },
			{"<leader>la", function() require("chainsaw").assertLog() end, mode = {"n", "x"}, desc = " assert" },
			{"<leader>lt", function() require("chainsaw").typeLog() end, mode = {"n", "x"}, desc = "⬠ type" },
			{"<leader>lm", function() require("chainsaw").messageLog() end, desc = "󰍡 message" },
			{"<leader>le", function() require("chainsaw").emojiLog() end, desc = "󰱨 emoji" },
			{"<leader>ls", function() require("chainsaw").sound() end, desc = "󰂚 sound" },
			{"<leader>lp", function() require("chainsaw").timeLog() end, desc = "󱎫 performance" },
			{"<leader>ld", function() require("chainsaw").debugLog() end, desc = "󰃤 debugger" },
			{"<leader>lS", function() require("chainsaw").stacktraceLog() end, desc = " stacktrace" },
			{"<leader>lk", function() require("chainsaw").clearLog() end, desc = "󰐪  clear" },

			{"<leader>lr", function() require("chainsaw").removeLogs() end, desc = "󰐪 󰅗 remove logs" },
			-- stylua: ignore end
		},
	},

	--------------------------------------------------------------------------------
}
