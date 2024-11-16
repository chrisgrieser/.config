local textObjMaps = require("config.utils").extraTextobjMaps
--------------------------------------------------------------------------------

return {
	{ -- auto-pair
		-- EXAMPLE config of the plugin: https://github.com/Bekaboo/nvim/blob/master/lua/configs/ultimate-autopair.lua
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
			{ "sX", "sx$", desc = "󰅪 Exchange to EoL", remap = true },
		},
		opts = {
			evaluate = { prefix = "" }, -- disable
			replace = { prefix = "s", reindent_linewise = true },
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

					-- MOVE CURSOR TO VALUE
					-- HACK needs to work with `defer_fn`, since the transformer function is
					-- called only *before* multiplication
					local rowBefore = vim.api.nvim_win_get_cursor(0)[1]
					vim.defer_fn(function()
						local rowAfter = vim.api.nvim_win_get_cursor(0)[1]
						local line = vim.api.nvim_get_current_line()
						local _, valuePos = line:find("[:=] %S") -- find value
						local _, _, fieldPos = line:find("@.-()%w+$") -- luadoc
						local col = fieldPos or valuePos
						if rowBefore ~= rowAfter and col then
							vim.api.nvim_win_set_cursor(0, { rowAfter, col - 1 })
						end
					end, 1)

					return content.lines
				end,
			},
		},
	},
	{ -- surround
		"kylechui/nvim-surround",
		keys = {
			{ "ys", desc = "󰅪 Add Surround Op." },
			{ "yS", "ys$", desc = "󰅪 Surround to EoL", remap = true },
			{ "ds", desc = "󰅪 Delete Surround Op." },
			{ "cs", desc = "󰅪 Change Surround Op." },
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
					find = "[%w.:_]+%b()", -- includes `:` for LUA-methods/CSS-pseudoclasses
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
		init = function() vim.g.whichkeyAddGroup("<leader>l", "󰐪 Log") end,
		cmd = "ChainSaw",
		opts = {
			marker = "🖨️",
			logStatements = {
				objectLog = {
					lua = 'print("%s %s: " .. hs.inspect(%s))', -- Hammerspoon
					typescript = "new Notice(`%s %s: ${%s}`, 0)", -- Obsidian
					-- re-purposing `objectLog` for debugging via AppleScript notification
					zsh = [[osascript -e "display notification \"%s $%s\" with title \"%s\""]],
				},
				clearLog = {
					lua = "hs.console.clearConsole() -- %s", -- Hammerspoon
				},
				sound = {
					lua = 'hs.sound.getByName("Sosumi"):play() -- %s', -- Hammerspoon
					nvim_lua = 'vim.system({"osascript", "-e", "beep"}) -- %s', -- macOS only
				},
			},
		},
		keys = {
			-- stylua: ignore start
			{"<leader>ll", function() require("chainsaw").variableLog() end, mode = {"n", "x"}, desc = "󰀫 variable" },
			{"<leader>lo", function() require("chainsaw").objectLog() end, mode = {"n", "x"}, desc = "⬟ object" },
			{"<leader>la", function() require("chainsaw").assertLog() end, mode = {"n", "x"}, desc = "⁉️ assert" },
			{"<leader>lt", function() require("chainsaw").typeLog() end, mode = {"n", "x"}, desc = "󰜀 type" },
			{"<leader>lm", function() require("chainsaw").messageLog() end, desc = "󰦨 message" },
			{"<leader>le", function() require("chainsaw").emojiLog() end, desc = "󰞅 emoji" },
			{"<leader>ls", function() require("chainsaw").sound() end, desc = "󰂚 sound" },
			{"<leader>lp", function() require("chainsaw").timeLog() end, desc = "󱎫 performance" },
			{"<leader>ld", function() require("chainsaw").debugLog() end, desc = "󰃤 debugger" },
			{"<leader>l<down>", function() require("chainsaw").stacktraceLog() end, desc = " stacktrace" },
			{"<leader>lk", function() require("chainsaw").clearLog() end, desc = "󰃢 clear console" },
			{"<leader>lr", function() require("chainsaw").removeLogs() end, desc = "󰅗 remove logs" },
			-- stylua: ignore end
		},
	},
}
