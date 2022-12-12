require("utils")
--------------------------------------------------------------------------------

-- need to be consistent with treesitter
local functionObjChar = "f"
local conditionObjChar = "o"
local callObjChar = "l"

require("nvim-surround").setup {
	aliases = {-- aliases should match the bindings for text objects
		["b"] = ")",
		["c"] = "}",
		["r"] = "]",
		["q"] = '"',
		["z"] = "'",
		["t"] = "`",
	},
	move_cursor = false,
	keymaps = {
		visual = "s",
	},
	surrounds = {
		[functionObjChar] = {
			find = function()
				return require("nvim-surround.config").get_selection {motion = "a" .. functionObjChar}
			end,
			delete = function()
				local ft = bo.filetype
				local patt
				if ft == "lua" then
					patt = "^(.-function.-%b() ?)().-( ?end)()$"
				elseif ft == "javascript" or ft == "typescript" or ft == "bash" or ft == "zsh" or ft == "sh" then
					patt = "^(.-function.-%b() ?{)().*(})()$"
				else
					vim.notify("No function-surround defined for " .. ft, logWarn)
					patt = "()()()()"
				end
				return require("nvim-surround.config").get_selections {
					char = functionObjChar,
					pattern = patt,
				}
			end,
			add = function()
				local ft = bo.filetype
				if ft == "lua" then
					return {
						{"function ()", "\t"},
						{"", "end"},
					}
				elseif ft == "typescript" or ft == "javascript" or ft == "bash" or ft == "zsh" or ft == "sh" then
					return {
						{"function () {", "\t"},
						{"", "}"},
					}
				end
				vim.notify("No function-surround defined for " .. ft, logWarn)
				return {{""}, {""}}
			end,
		},
		[callObjChar] = {
			find = function()
				return require("nvim-surround.config").get_selection {motion = "a" .. callObjChar}
			end,
			delete = "^([^=%s]+%()().-(%))()$",
		},
		[conditionObjChar] = {
			find = function()
				return require("nvim-surround.config").get_selection {motion = "a" .. callObjChar}
			end,
			delete = function()
				local ft = bo.filetype
				local patt
				if ft == "lua" then
					patt = "^(if .- then)().-( ?end)()$"
				elseif ft == "javascript" or ft == "typescript" then
					patt = "^(if %b() ?{?)().-( ?}?)()$"
				else
					vim.notify("No conditional-surround defined for " .. ft, logWarn)
					patt = "()()()()"
				end
				return require("nvim-surround.config").get_selections {
					char = conditionObjChar,
					pattern = patt,
				}
			end,
			add = function()
				local ft = bo.filetype
				if ft == "lua" then
					return {
						{"if true then", "\t"},
						{"", "end"},
					}
				elseif ft == "typescript" or ft == "javascript" then
					return {
						{"if (true) {", "\t"},
						{"", "}"},
					}
				end
				vim.notify("No if-surround defined for " .. ft, logWarn)
				return {{""}, {""}}
			end,
		}
	}
}

-- surround current line or till end of line
keymap("n", "yss", "ys_", {remap = true})
keymap("n", "yS", "ys$", {remap = true})
