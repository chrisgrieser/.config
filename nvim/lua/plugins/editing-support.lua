return {
	-- EDITING-SUPPORT
	{ "numToStr/Comment.nvim" }, -- comment operator
	{ "kylechui/nvim-surround" },

	{ "mg979/vim-visual-multi", keys = { "<D-j>", { "<D-j>", mode = "x" } } },
	{ "chrisgrieser/nvim-various-textobjs", dev = true, lazy = true }, -- custom textobjects

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
	-- TODO checkout later if they added support for more filetypes
	-- {
	-- 	"ckolkey/ts-node-action",
	-- 	dependencies = { "nvim-treesitter" },
	-- 	lazy = true,
	-- 	config = function() require("ts-node-action").setup() end,
	-- },
	{
		"cshuaimin/ssr.nvim", -- structural search & replace
		lazy = true,
		config = function()
			require("ssr").setup {
				keymaps = { close = "Q" },
			}
		end,
	},
	{
		"andymass/vim-matchup",
		init = function()
			vim.g.matchup_text_obj_enabled = 0
			vim.g.matchup_matchparen_enabled = 1 -- highlight
		end,
		event = "BufReadPost", -- other lazyloading methods do not seem to work
	},
	{
		"nacro90/numb.nvim", -- line previews when ":n"
		config = function() require("numb").setup() end,
		keys = ":",
	},
	{
		"ThePrimeagen/refactoring.nvim",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		config = function() require("refactoring").setup() end,
	},
	{ "ggandor/leap.nvim", event = "VeryLazy" },
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
		"smjonas/duplicate.nvim",
		keys = { "yd", "R", { "R", mode = "x" } },
		config = function()
			require("duplicate").setup {
				operator = {
					normal_mode = "yd",
					visual_mode = "R",
					line = "R",
				},
				-- selene: allow(high_cyclomatic_complexity)
				transform = function(lines)
					-- only work with single line duplication
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

					return {line} -- return as array, since that's what the plugin expects
				end,
			}
		end,
	},
}
