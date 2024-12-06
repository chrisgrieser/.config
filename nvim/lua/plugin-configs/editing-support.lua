local textObjMaps = require("config.utils").extraTextobjMaps
--------------------------------------------------------------------------------

return {
	{ -- auto-pair
		"altermo/ultimate-autopair.nvim",
		branch = "v0.6", -- recommended as each new version will have breaking changes
		event = { "InsertEnter", "CmdlineEnter" },
		keys = {
			-- Open new scope (`remap` to trigger auto-pairing)
			{ "<D-o>", "a{<CR>", desc = " Open new scope", remap = true },
			{ "<D-o>", "{<CR>", mode = "i", desc = " Open new scope", remap = true },
		},
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
			{ "**", "**", ft = { "markdown" } }, -- bold
			{ [[\"]], [[\"]], ft = { "zsh", "json", "applescript" } }, -- escaped quote

			{ -- commit scope (= only first word) for commit messages
				"(",
				"): ",
				ft = { "gitcommit" },
				cond = function(_) return not vim.api.nvim_get_current_line():find(" ") end,
			},

			-- for keymaps like `<C-a>`
			{ "<", ">", ft = { "vim" } },
			{
				"<",
				">",
				ft = { "lua" },
				cond = function(fn)
					-- FIX https://github.com/altermo/ultimate-autopair.nvim/issues/88
					local inLuaLua = vim.endswith(vim.api.nvim_buf_get_name(0), "/ftplugin/lua.lua")
					return not inLuaLua and fn.in_string()
				end,
			},
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
		},
		opts = {
			evaluate = { prefix = "" }, -- disable
			replace = { prefix = "s", reindent_linewise = true },
			exchange = { prefix = "sx", reindent_linewise = true },
			sort = { prefix = "sy" },
			multiply = {
				prefix = "", -- set our own in `make_mappings`
			},
		},
		config = function(_, opts)
			require("mini.operators").setup(opts)

			-- Do not set `multiply` mapping for line, since we use our own, as
			-- multiply's transformation function only supports pre-duplication
			-- changes, which prevents us from doing post-duplication cursor
			-- movements.
			require("mini.operators").make_mappings(
				"multiply",
				{ textobject = "w", selection = "w", line = "" }
			)
		end,
	},
	{ -- surround
		"kylechui/nvim-surround",
		keys = {
			{ "ys", desc = "󰅪 Add surround operator" },
			{ "yS", "ys$", desc = "󰅪 Surround to EoL", remap = true },
			{ "ds", desc = "󰅪 Delete surround operator" },
			{ "cs", desc = "󰅪 Change surround operator" },
		},
		opts = {
			move_cursor = false,
			aliases = { c = "}", r = "]", m = "W", q = '"', z = "'", e = "`" },
			keymaps = {
				visual = false,
				normal_line = false,
				normal_cur_line = false,
				visual_line = false,
				insert_line = false,
				insert = false,
			},
			surrounds = {
				invalid_key_behavior = { add = false, find = false, delete = false, change = false },
				[textObjMaps.call] = {
					find = "[%w.:_]+%b()", -- includes `:` for lua-methods/css-pseudoclasses
					delete = "([%w.:_]+%()().*(%))()",
				},
				[textObjMaps.func] = { -- only one-line lua functions
					find = "function ?[%w_]* ?%b().- end",
					delete = "(function ?[%w_]* ?%b() ?)().-( end)()",
				},
				[textObjMaps.condition] = { -- only one-line lua conditionals
					find = "if .- then .- end",
					delete = "(if .- then )().-( end)()",
				},
				[textObjMaps.wikilink] = {
					find = "%[%[.-%]%]",
					add = { "[[", "]]" },
					delete = "(%[%[)().-(%]%])()",
					change = { target = "(%[%[)().-(%]%])()" },
				},
			},
		},
	},
	{ -- Icon Picker
		"nvim-telescope/telescope-symbols.nvim",
		dependencies = "nvim-telescope/telescope.nvim",
		keys = {
			{
				"<C-.>",
				mode = "i",
				function()
					require("telescope.builtin").symbols {
						sources = { "nerd", "math", "emoji" },
						layout_config = { horizontal = { width = 0.35 } },
					}
				end,
				desc = "󰭎 Icon Picker",
			},
		},
	},
	{ -- split-join lines
		"Wansmer/treesj",
		keys = {
			{ "<leader>s", function() require("treesj").toggle() end, desc = "󰗈 Split-join lines" },
			{ "<leader>s", "gw}", ft = "markdown", desc = "󰗈 Reflow rest of paragraph" },
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
								tsj:update_preset({ recursive = false }, "join")
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
				return_statement = {
					join = { enable = false },
					split = {
						enable = function(tsn) return tsn:parent():type() == "if_statement" end,
						format_tree = function(tsj) tsj:wrap { left = "{", right = "}" } end,
					},
				},
			}
			opts.langs = {
				comment = { source = gww, element = gww }, -- comments in any language
				lua = { comment = gww },
				jsdoc = { source = gww, description = gww },
				javascript = joinWithoutCurly,
				typescript = joinWithoutCurly,
			}
			require("treesj").setup(opts)
		end,
	},
	{ -- quickly add log statements
		"chrisgrieser/nvim-chainsaw",
		ft = "lua", -- in lua, load directly for `Chainsaw` global
		init = function() vim.g.whichkeyAddGroup { "<leader>l", group = "󰐪 Log" } end,
		opts = {
			logStatements = {
				variableLog = {
					nvim_lua = "Chainsaw({{var}}) -- {{marker}}",
					lua = 'print("{{marker}} {{var}}: " .. hs.inspect({{var}}))',
				},

				-- not using any marker
				assertLog = { lua = 'assert({{var}}, "")' },

				-- re-purposing `objectLog` for alternative log statements for these
				objectLog = {
					-- Obsidian Notice
					typescript = "new Notice(`{{marker}} {{var}}: ${{{var}}}`, 0)",
					-- AppleScript notification
					zsh = [[osascript -e "display notification \"{{marker}}} ${{var}}\" with title \"{{var}}\""]],
				},

				-- Hammerspoon
				clearLog = { lua = "hs.console.clearConsole() -- {{marker}}" },
				sound = {
					lua = 'hs.sound.getByName("Sosumi"):play() ---@diagnostic disable-line: undefined-field -- 🪚',
				},
			},
		},
		config = function(_, opts)
			require("chainsaw").setup(opts)

			vim.g.lualineAdd("sections", "lualine_x", {
				require("chainsaw.visuals.statusline").countInBuffer,
				color = "lualine_x_diagnostics_info_normal", -- only lualine item has also correct bg-color
				padding = { left = 0, right = 1 },
			})
		end,
		keys = {
			-- stylua: ignore start
			{"<leader>ll", function() require("chainsaw").variableLog() end, mode = { "n", "x" }, desc = "󰀫 variable" },
			{"<leader>lo", function() require("chainsaw").objectLog() end, mode = { "n", "x" }, desc = "⬟ object" },
			{"<leader>la", function() require("chainsaw").assertLog() end, mode = { "n", "x" }, desc = "⁉️ assert" },
			{"<leader>lt", function() require("chainsaw").typeLog() end, mode = { "n", "x" }, desc = "󰜀 type" },
			{"<leader>lm", function() require("chainsaw").messageLog() end, desc = "󰍩 message" },
			{"<leader>le", function() require("chainsaw").emojiLog() end, desc = "󰞅 emoji" },
			{"<leader>ls", function() require("chainsaw").sound() end, desc = "󰂚 sound" },
			{"<leader>lp", function() require("chainsaw").timeLog() end, desc = "󱎫 performance" },
			{"<leader>ld", function() require("chainsaw").debugLog() end, desc = "󰃤 debugger" },
			{"<leader>lS", function() require("chainsaw").stacktraceLog() end, desc = " stacktrace" },
			{"<leader>lc", function() require("chainsaw").clearLog() end, desc = "󰃢 clear console" },
			{"<leader>lr", function() require("chainsaw").removeLogs() end, desc = "󰅗 remove logs" },
			-- stylua: ignore end
		},
	},
}
