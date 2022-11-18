local M = {}

function M.surroundSetup()
	require("nvim-surround").setup {
		aliases = {-- aliases should match the bindings above
			["b"] = ")",
			["c"] = "}",
			["r"] = "]",
			["q"] = '"',
			["z"] = "'",
		},
		move_cursor = false,
		keymaps = {
			visual = "s",
			visual_line = "S",
		},
		surrounds = {
			["f"] = {
				find = function()
					return require("nvim-surround.config").get_selection {motion = "af"}
				end,
				delete = function()
					local ft = bo.filetype
					local patt
					if ft == "lua" then
						patt = "^(.-function.-%b() ?)().-( ?end)()$"
					elseif ft == "js" or ft == "ts" or ft == "bash" or ft == "zsh" then
						patt = "^(.-function.-%b() ?{)().*(})()$"
					else
						vim.notify("No function-surround defined for " .. ft)
						patt = "()()()()"
					end
					return require("nvim-surround.config").get_selections {
						char = "f",
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
					elseif ft == "js" or ft == "ts" or ft == "bash" or ft == "zsh" then
						return {
							{"function () {", "\t"},
							{"", "}"},
						}
					end
					vim.notify("No function-surround defined for " .. ft)
					return {{""}, {""}}
				end,
			},
		}
	}
end

return M
