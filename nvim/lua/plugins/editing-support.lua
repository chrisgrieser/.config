return {
	-- EDITING-SUPPORT
	{
		"numToStr/Comment.nvim",
		keys = { "q", "Q", { "q", mode = "x" } }, -- (mnemonic: [q]uiet text)
		config = function()
			require("Comment").setup {
				-- ignore = "^$", -- ignore empty lines
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
			}
		end,
	},
	{
		"danymat/neogen",
		lazy = true,
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function() require("neogen").setup() end,
	},
	{
		"kylechui/nvim-surround",
		event = "BufRead",
		config = function()
			-- HACK define these manually, since for some reason they do not work by default
			vim.keymap.set("n", "yss", "ys_", { remap = true, desc = "surround line" })
			vim.keymap.set("n", "yS", "ys$", { remap = true, desc = "surround till EoL" })

			-- need to be consistent with the text obj mappings
			local functionObjChar = "f"
			local conditionObjChar = "o"
			local callObjChar = "l"
			local doubleSquareBracketObjChar = "R"
			local regexObjChar = "/"

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
				move_cursor = false,
				keymaps = {
					normal_cur = "<Nop>", -- mapped on my own (see above)
					normal_line = "<Nop>", -- mapped on my own (see above)
					normal_cur_line = "<Nop>",
					visual = "s",
				},
				surrounds = {
					[doubleSquareBracketObjChar] = {
						find = "%[%[.-%]%]",
						add = { "[[", "]]" },
						delete = "(%[%[)().-(%]%])()",
						change = {
							target = "(%[%[)().-(%]%])()",
						},
					},
					[regexObjChar] = {
						find = "/.-/",
						add = { "/", "/" },
						delete = "(/)().-(/)()",
						change = {
							target = "(/)().-(/)()",
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
								vim.notify("No function-surround defined for " .. ft, logWarn)
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
								return {
									{ "function ()", "\t" },
									{ "", "end" },
								}
							elseif
								ft == "typescript"
								or ft == "javascript"
								or ft == "bash"
								or ft == "zsh"
								or ft == "sh"
							then
								return {
									{ "function () {", "\t" },
									{ "", "}" },
								}
							end
							vim.notify("No function-surround defined for " .. ft, logWarn)
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
								vim.notify("No conditional-surround defined for " .. ft, logWarn)
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
							vim.notify("No if-surround defined for " .. ft, logWarn)
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

	{ "Darazaki/indent-o-matic" }, -- automatically set right indent for file
	{ "mg979/vim-visual-multi", keys = { "<D-j>", { "<D-j>", mode = "x" } } },
	{ "chrisgrieser/nvim-various-textobjs", dev = true, lazy = true }, -- custom textobjects

	{ "bkad/CamelCaseMotion", event = "BufReadPost" },
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		init = function()
			vim.g.undotree_WindowLayout = 3
			vim.g.undotree_DiffpanelHeight = 8
			vim.g.undotree_ShortIndicators = 1
			vim.g.undotree_SplitWidth = 30
			vim.g.undotree_DiffAutoOpen = 0
			vim.g.undotree_SetFocusWhenToggle = 1
			vim.g.undotree_DiffCommand = "delta"
			vim.g.undotree_HelpLine = 1
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "undotree",
				callback = function()
					vim.keymap.set("n", "<D-w>", ":UndotreeToggle<CR>", { buffer = true })
					vim.opt_local.listchars = "space: "
				end,
			})
		end,
	},

	{
		"mizlan/iswap.nvim", -- swapping of nodes
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function() require("iswap").setup { autoswap = true } end,
		cmd = "ISwapWith",
	},
	{
		"Wansmer/treesj", -- split-join
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function() require("treesj").setup { use_default_keymaps = false } end,
		cmd = "TSJToggle",
	},
	{
		"cshuaimin/ssr.nvim", -- structural search & replace
		lazy = true,
		config = function()
			require("ssr").setup {
				keymaps = { close = "Q" },
			}
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "ssr",
				callback = function() vim.wo.sidescrolloff = 0 end,
			})
		end,
	},
	{
		"ThePrimeagen/refactoring.nvim",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		config = function() require("refactoring").setup() end,
	},
	{
		"nacro90/numb.nvim", -- line previews when ":n"
		config = function() require("numb").setup() end,
		keys = ":",
	},
	{
		"unblevable/quick-scope",
		keys = { "f", "F", "t", "T" },
		init = function()
			vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
			vim.cmd.highlight { "def link QuickScopePrimary CurSearch", bang = true }
			vim.cmd.highlight { "QuickScopePrimary gui=underline", bang = true }
		end,
	},
	{
		"gbprod/substitute.nvim", -- substitution & exchange operator
		lazy = true,
		config = function() require("substitute").setup() end,
	},
	{
		"dkarter/bullets.vim", -- auto-bullets for markdown-like filetypes
		ft = { "markdown", "text", "gitcommit" },
		init = function() vim.g.bullets_delete_last_bullet_if_empty = 1 end,
	},
	{
		"smjonas/duplicate.nvim",
		keys = {
			{"yd", desc = "Duplicate"},
			{ "R", mode = {"n", "x"}, desc = "Duplicate" },
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
}
