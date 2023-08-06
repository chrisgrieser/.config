return {
	{ -- comment
		"numToStr/Comment.nvim",
		keys = {
			-- mnemonic: [q]uiet text
			{ "Q", desc = " Append Comment at EoL" },
			{ "q", mode = { "n", "x" }, desc = " Comment Operator" },
			{ "qo", desc = " Comment below" },
			{ "qO", desc = " Comment above" },
		},
		opts = {
			opleader = {
				line = "q",
				block = "<Nop>",
			},
			toggler = {
				line = "qq",
				block = "<Nop>",
			},
			extra = {
				eol = "Q",
				above = "qO",
				below = "qo",
			},
		},
	},
	{
		"danymat/neogen",
		keys = {
			{ "qf", function() require("neogen").generate() end, desc = " Comment Function" },
		},
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = true,
	},
	{ -- substitute
		"gbprod/substitute.nvim",
		keys = {
			{ "s", function() require("substitute").operator() end, desc = "Substitute operator" },
			{ "ss", function() require("substitute").line() end, desc = "Substitute line" },
			{ "S", function() require("substitute").eol() end, desc = "Substitute to EoL" },
			{ "sy", function() require("substitute.exchange").operator() end, desc = "Exchange operator" },
			{ "sY", "sy$", remap = true, desc = "Exchange to EoL" },
			{ "syy", function() require("substitute.exchange").line() end, desc = "Exchange line" },
		},
		opts = { on_substitute = require("yanky.integration").substitute() },
	},
	{ -- duplicate
		"smjonas/duplicate.nvim",
		keys = {
			{ "w", mode = { "n", "x" }, desc = "󰆑 Duplicate Operator" },
		},
		init = function() vim.keymap.set("n", "W", "w$", { remap = true, desc = "󰆑 Duplicate to EoL" }) end,
		opts = {
			operator = {
				normal_mode = "w",
				visual_mode = "w",
				line = "ww",
			},
			-- selene: allow(high_cyclomatic_complexity)
			transform = function(lines)
				-- transformations only for single line duplication
				if #lines > 1 then return lines end

				local line = lines[1]
				local ft = vim.bo.filetype

				-- smart switching of conditionals
				if ft == "lua" and line:find("^%s*if.+then%s*$") then
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

				-- move cursor position to value
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
		},
	},
	{ -- surround
		"kylechui/nvim-surround",
		keys = {
			{ "ys", desc = "󰅪 Add Surround Operator" },
			{ "yS", desc = "󰅪 Surround to EoL" },
			{ "ds", desc = "󰅪 Delete Surround Operator" },
			{ "cs", desc = "󰅪 Change Surround Operator" },
			{ "s", mode = "x", desc = "󰅪 Add Surround Operator" },
		},
		config = function()
			local u = require("config.utils")

			local textobjRemaps = vim.deepcopy(require("config.utils").textobjectRemaps)
			textobjRemaps.a = "*" -- markdown italics
			textobjRemaps.u = "__" -- markdown bold

			-- requires unmapping yS from normal_line below
			vim.keymap.set("n", "yS", "ys$", { desc = "󰅪 Surround to EoL", remap = true })

			-- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt#L483
			local config = require("nvim-surround.config")
			require("nvim-surround").setup {
				move_cursor = false,
				aliases = textobjRemaps,
				keymaps = {
					visual = "s",
					normal_line = false,
					normal_cur_line = false,
					visual_line = false,
					insert_line = false,
					insert = false,
				},
				surrounds = {
					[u.textobjectMaps.doubleSquareBracket] = {
						find = "%[%[.-%]%]",
						add = { "[[", "]]" },
						delete = "(%[%[)().-(%]%])()",
						change = {
							target = "(%[%[)().-(%]%])()",
						},
					},
					["__"] = {
						find = "__.-__",
						add = { "__", "__" },
						delete = "(__)().-(__)()",
						change = {
							target = "(__)().-(__)()",
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
					["*"] = {
						find = "%*.-%*",
						add = { "*", "*" },
						delete = "(%*)().-(%*)()",
						change = {
							target = "(%*)().-(%*)()",
						},
					},
					[u.textobjectMaps["function"]] = {
						find = function()
							return config.get_selection { motion = "a" .. u.textobjectMaps["function"] }
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
								vim.notify("No function-surround defined for " .. ft, u.warn)
								patt = "()()()()"
							end
							return config.get_selections {
								char = u.textobjectMaps["function"],
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
							vim.notify("No function-surround defined for " .. ft, u.warn)
							return { { "" }, { "" } }
						end,
					},
					[u.textobjectMaps["call"]] = {
						find = function()
							return config.get_selection { motion = "a" .. u.textobjectMaps["call"] }
						end,
						delete = "^([^=%s]+%()().-(%))()$", -- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt#L357
					},
					[u.textobjectMaps["conditional"]] = {
						find = function()
							return config.get_selection { motion = "a" .. u.textobjectMaps["conditional"] }
						end,
						delete = function()
							local ft = vim.bo.filetype
							local patt
							if ft == "lua" then
								patt = "^(if .- then)().-( ?end)()$"
							elseif ft == "javascript" or ft == "typescript" then
								patt = "^(if %b() ?{?)().-( ?}?)()$"
							else
								vim.notify("No conditional-surround defined for " .. ft, u.warn)
								patt = "()()()()"
							end
							return config.get_selections {
								char = u.textobjectMaps["conditional"],
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
							vim.notify("No if-surround defined for " .. ft, u.warn)
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
