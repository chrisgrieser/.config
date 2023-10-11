local function surroundConfig()
	local u = require("config.utils")
	local textobjectRemaps = require("config.utils").textobjRemaps
	local maps = require("config.utils").textobjMaps

	-- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt#L483
	local config = require("nvim-surround.config")
	require("nvim-surround").setup {
		move_cursor = false,
		aliases = textobjectRemaps,
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
			[maps.wikilink] = {
				find = "%[%[.-%]%]",
				add = { "[[", "]]" },
				delete = "(%[%[)().-(%]%])()",
				change = {
					target = "(%[%[)().-(%]%])()",
				},
			},
			["/"] = {
				find = "/.-/",
				add = { "/", "/" },
				delete = "(/)().-(/)()",
				change = {
					target = "(/)().-(/)()",
				},
			},
			[maps.func] = {
				find = function()
					return config.get_selection { motion = "a" .. maps["function"] }
				end,
				delete = function()
					local ft = vim.bo.filetype
					local patt
					if ft == "lua" then
						patt = "^(.-function.-%b() ?)().-( ?end)()$"
					elseif
						ft == "javascript"
						or ft == "typescript"
						or ft == "bash"
						or ft == "zsh"
						or ft == "sh"
					then
						patt = "^(.-function.-%b() ?{)().*(})()$"
					else
						u.notify("Surround", "No function-surround defined for " .. ft)
						patt = "()()()()"
					end
					return config.get_selections {
						char = maps["function"],
						pattern = patt,
					}
				end,
				add = function()
					local ft = vim.bo.filetype
					if ft == "lua" then
						-- function as one line
						return { { "function() " }, { " end" } }
					elseif
						ft == "typescript"
						or ft == "javascript"
						or ft == "bash"
						or ft == "zsh"
						or ft == "sh"
					then
						-- function on surrounding lines
						return {
							{ "function () {", "\t" },
							{ "", "}" },
						}
					end
					u.notify("Surround", "No function-surround defined for " .. ft)
					return { { "" }, { "" } }
				end,
			},
			[maps.call] = {
				find = function() return config.get_selection { motion = "a" .. maps["call"] } end,
				delete = "^([^=%s]+%()().-(%))()$", -- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt#L357
			},
			[maps.cond] = {
				find = function()
					return config.get_selection { motion = "a" .. maps["conditional"] }
				end,
				delete = function()
					local ft = vim.bo.filetype
					local patt
					if ft == "lua" then
						patt = "^(if .- then)().-( ?end)()$"
					elseif ft == "javascript" or ft == "typescript" then
						patt = "^(if %b() ?{?)().-( ?}?)()$"
					else
						u.notify("Surround", "No conditional-surround defined for " .. ft)
						patt = "()()()()"
					end
					return config.get_selections {
						char = maps["conditional"],
						pattern = patt,
					}
				end,
				add = function()
					local ft = vim.bo.filetype
					if ft == "lua" then
						return {
							{ "if true then", "\t" },
							{ "", "end" },
						}
					elseif ft == "typescript" or ft == "javascript" then
						return {
							{ "if (true) {", "\t" },
							{ "", "}" },
						}
					end
					u.notify("Surround", "No if-surround defined for " .. ft)
					return { { "" }, { "" } }
				end,
			},
		},
	}
end

--------------------------------------------------------------------------------

return {
	{ -- surround
		"kylechui/nvim-surround",
		keys = {
			{ "ys", desc = "󰅪 Add Surround Operator" },
			{ "s", mode = "x", desc = "󰅪 Add Surround Operator" },
			{ "yS", "ys$", desc = "󰅪 Surround to EoL", remap = true },
			{ "ds", desc = "󰅪 Delete Surround Operator" },
			{ "cs", desc = "󰅪 Change Surround Operator" },
		},
		config = surroundConfig,
	},
}
