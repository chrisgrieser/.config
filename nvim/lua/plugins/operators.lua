return {
	{
		"numToStr/Comment.nvim",
		keys = { -- mnemonic: [q]uiet text
			{ "Q", desc = "Append Comment at EoL" },
			{ "q", mode = { "n", "x" }, desc = "Comment" },
		},
		config = function()
			require("Comment").setup {
				opleader = {
					line = "q",
					block = nil,
				},
				toggler = {
					line = "qq",
					block = nil,
				},
				extra = {
					eol = "Q",
					above = "qO",
					below = "qo",
				},
			}
		end,
	},
	{ -- annotation comments
		"danymat/neogen",
		lazy = true,
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function() require("neogen").setup() end,
	},
	{
		"gbprod/substitute.nvim",
		lazy = true,
		config = function() require("substitute").setup() end,
	},
	{
		"smjonas/duplicate.nvim",
		keys = {
			{ "yd", desc = "Duplicate" },
			{ "R", mode = { "n", "x" }, desc = "Duplicate" },
		},
		config = function()
			require("duplicate").setup {
				operator = {
					normal_mode = "yd",
					visual_mode = "R",
					line = "R",
				},
				-- selene: allow(high_cyclomatic_complexity)
				transform = function(lines)
					-- transformations only for single line duplication
					if #lines > 1 then return lines end

					local line = lines[1]
					local ft = vim.bo.filetype

					-- smart switching of conditionals
					if ft == "lua" and line:find("^%s*if.+then$") then
						line = line:gsub("^(%s*)if", "%1elseif")
					elseif (ft == "bash" or ft == "zsh" or ft == "sh") and line:find("^%s*if.+then$") then
						line = line:gsub("^(%s*)if", "%1elif")
					elseif (ft == "javascript" or ft == "typescript") and line:find("^%s*if.+{$") then
						line = line:gsub("^(%s*)if", "%1} else if")
					-- smart switching of css words
					elseif ft == "css" then
						if line:find("top") then
							line = line:gsub("top", "bottom")
						elseif line:find("bottom") then
							line = line:gsub("bottom", "top")
						elseif line:find("right") then
							line = line:gsub("right", "left")
						elseif line:find("left") then
							line = line:gsub("left", "right")
						elseif line:find("%sheight") then -- %s condition to avoid matching line-height etc
							line = line:gsub("(%s)height", "%1width")
						elseif line:find("%swidth") then -- %s condition to avoid matching border-width etc
							line = line:gsub("(%s)width", "%1height")
						elseif line:find("dark") then
							line = line:gsub("dark", "light")
						elseif line:find("light") then
							line = line:gsub("light", "dark")
						end
					end

					-- increment numbered vars
					local lineHasNumberedVarAssignment, _, num = line:find("(%d+).*=")
					if lineHasNumberedVarAssignment then
						local nextNum = tostring(tonumber(num) + 1)
						line = line:gsub("%d+(.*=)", nextNum .. "%1")
					end

					-- move cursor position
					local lineNum, colNum = unpack(vim.api.nvim_win_get_cursor(0))
					local keyPos, valuePos = line:find(".%w+ ?[:=] ?")
					if valuePos and not (ft == "css") then
						colNum = valuePos
					elseif keyPos and ft == "css" then
						colNum = keyPos
					end
					vim.api.nvim_win_set_cursor(0, { lineNum, colNum })

					return { line } -- return as array, since that's what the plugin expects
				end,
			}
		end,
	},
	{
		"kylechui/nvim-surround",
		event = "BufRead",
		config = function()
			-- need to be consistent with the text obj mappings
			local functionObjChar = "f"
			local conditionObjChar = "o"
			local callObjChar = "l"
			local doubleSquareBracketObjChar = "R"

			-- requires unmapping yS in the keymaps below
			vim.keymap.set("n", "yS", "ys$", { desc = "surround to EoL", remap = true })

			-- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt#L483
			local config = require("nvim-surround.config")
			require("nvim-surround").setup {
				aliases = { -- aliases should match the bindings for text objects
					["b"] = ")",
					["c"] = "}",
					["r"] = "]",
					["q"] = '"',
					["z"] = "'",
					["e"] = "`",
				},
				keymaps = {
					visual = "s",
					normal_line = false,
					normal_cur_line = false,
					visual_line = false,
					insert_line = false,
					insert = false,
				},
				move_cursor = false,
				surrounds = {
					[doubleSquareBracketObjChar] = {
						find = "%[%[.-%]%]",
						add = { "[[", "]]" },
						delete = "(%[%[)().-(%]%])()",
						change = {
							target = "(%[%[)().-(%]%])()",
						},
					},
					[functionObjChar] = {
						find = function() return config.get_selection { motion = "a" .. functionObjChar } end,
						delete = function()
							local ft = bo.filetype
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
								vim.notify("No function-surround defined for " .. ft, LogWarn)
								patt = "()()()()"
							end
							return config.get_selections {
								char = functionObjChar,
								pattern = patt,
							}
						end,
						add = function()
							local ft = bo.filetype
							if ft == "lua" then
								-- function as one line
								return { { "function () " }, { " end" } }
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
							vim.notify("No function-surround defined for " .. ft, LogWarn)
							return { { "" }, { "" } }
						end,
					},
					[callObjChar] = {
						find = function() return config.get_selection { motion = "a" .. callObjChar } end,
						delete = "^([^=%s]+%()().-(%))()$", -- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt#L357
					},
					[conditionObjChar] = {
						find = function() return config.get_selection { motion = "a" .. conditionObjChar } end,
						delete = function()
							local ft = bo.filetype
							local patt
							if ft == "lua" then
								patt = "^(if .- then)().-( ?end)()$"
							elseif ft == "javascript" or ft == "typescript" then
								patt = "^(if %b() ?{?)().-( ?}?)()$"
							else
								vim.notify("No conditional-surround defined for " .. ft, LogWarn)
								patt = "()()()()"
							end
							return config.get_selections {
								char = conditionObjChar,
								pattern = patt,
							}
						end,
						add = function()
							local ft = bo.filetype
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
							vim.notify("No if-surround defined for " .. ft, LogWarn)
							return { { "" }, { "" } }
						end,
					},
					invalid_key_behavior = {
						add = false,
						find = false,
						delete = false,
						change = false,
					},
				},
			}
		end,
	},
}
