local u = require("config.utils")

--------------------------------------------------------------------------------

return {
	{ -- highlights for ftFT
		"jinh0/eyeliner.nvim",
		keys = { "f", "F", "t", "T" },
		opts = { highlight_on_key = true, dim = false },
		init = function()
			u.colorschemeMod("EyelinerPrimary", { reverse = true })
			u.colorschemeMod("EyelinerSecondary", { underline = true })
		end,
	},
	{ -- better % (highlighting, matches across lines, match quotes)
		"andymass/vim-matchup",
		event = "UIEnter", -- cannot load on key due to highlights
		keys = {
			{ "m", "<Plug>(matchup-%)", desc = "Goto Matching Bracket" },
			{ "k", "<Plug>(matchup-i%)", mode = "o", desc = "󱡔 Any Inner Block textobj" },
			{ "K", "<Plug>(matchup-a%)", mode = "o", desc = "󱡔 Any Outer Block textobj" },
		},
		dependencies = "nvim-treesitter/nvim-treesitter",
		init = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" } -- empty list to disable
		end,
	},
	{ -- display line numbers when using `:` to go to a line with
		"nacro90/numb.nvim",
		keys = ":",
		opts = true,
	},
	{ -- CamelCase Motion plus
		"chrisgrieser/nvim-spider",
		opts = { skipInsignificantPunctuation = true },
		keys = {
			-- stylua: ignore,
			{
				"e",
				function() require("spider").motion("e") end,
				mode = { "n", "o", "x" },
				desc = "󱇫 Spider e",
			},
			-- stylua: ignore,
			{
				"b",
				function() require("spider").motion("b") end,
				mode = { "n", "o", "x" },
				desc = "󱇫 Spider b",
			},
		},
	},
	-----------------------------------------------------------------------------
	{ -- tons of text objects
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = "BufReadPre", -- not later to ensure it loads in time properly
		dependencies = "nvim-treesitter/nvim-treesitter",
		-- HACK avoid conflict with visual mode comment from Comments.nvim
		keys = {
			{ "q", "&&&", mode = "o", desc = "󱡔 comment textobj", remap = true },
			{ -- sticky deleting comment
				"dq",
				function()
					local prevCursor = vim.api.nvim_win_get_cursor(0)
					vim.cmd.normal { "d&&&" } -- without bang for remapping
					vim.api.nvim_win_set_cursor(0, prevCursor)
				end,
				remap = true,
				desc = " Delete Comment",
			},
			{ -- change inner comment (HACK, since only outer comments are supported rn)
				"cq",
				"d&&&xQ",
				remap = true,
				desc = " Delete Comment",
			},
		},
	},
	{ -- tons of text objects
		"chrisgrieser/nvim-various-textobjs",
		keys = {
			-- stylua: ignore start
			{ "<Space>", "<cmd>lua require('various-textobjs').subword('inner')<CR>", mode = "o", desc = "󱡔 inner subword textobj" },
			{ "i<Space>", "<cmd>lua require('various-textobjs').subword('inner')<CR>", mode = { "o", "x" }, desc = "󱡔 inner subword textobj" },
			{ "a<Space>", "<cmd>lua require('various-textobjs').subword('outer')<CR>", mode = { "o", "x" }, desc = "󱡔 outer subword textobj" },

			{ "iv", "<cmd>lua require('various-textobjs').value('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner value textobj" },
			{ "av", "<cmd>lua require('various-textobjs').value('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer value textobj" },
			-- INFO `ik` defined via treesitter to exclude `local` and `let`; mapping the *inner* obj to `ak`, since it includes `local` and `let`
			{ "ak", "<cmd>lua require('various-textobjs').key('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 outer key textobj" },
			{ "n", "<cmd>lua require('various-textobjs').nearEoL()<CR>", mode = { "o", "x" }, desc = "󱡔 near EoL textobj" },
			{ "m", "<cmd>lua require('various-textobjs').toNextClosingBracket()<CR>", mode = { "o", "x" }, desc = "󱡔 to next closing bracket textobj" },
			{ "w", "<cmd>lua require('various-textobjs').toNextQuotationMark()<CR>", mode = "o", desc = "󱡔 to next quote textobj", nowait = true },
			{ "in", "<cmd>lua require('various-textobjs').number('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner number textobj" },
			{ "an", "<cmd>lua require('various-textobjs').number('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer number textobj" },
			{ "i" .. u.textobjMaps["doubleSquareBracket"], "<cmd>lua require('various-textobjs').doubleSquareBrackets('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner double square bracket" },
			{ "a" .. u.textobjMaps["doubleSquareBracket"], "<cmd>lua require('various-textobjs').doubleSquareBrackets('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer double square bracket" },

			-- INFO not setting in visual mode, to keep visual block mode replace
			{ "rv", "<cmd>lua require('various-textobjs').restOfWindow()<CR>", mode = "o", desc = "󱡔 rest of viewport textobj" },
			{ "rp", "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", mode = "o", desc = "󱡔 rest of paragraph textobj" },
			{ "ri", "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", mode = "o", desc = "󱡔 rest of indentation textobj" },
			{ "rg", "G", mode = "o", desc = "󱡔 rest of buffer textobj" },
			{ "gg", "<cmd>lua require('various-textobjs').entireBuffer()<CR>", mode = { "x", "o" }, desc = "󱡔 entire buffer textobj" },

			{ "ge", "<cmd>lua require('various-textobjs').diagnostic()<CR>", mode = { "x", "o" }, desc = "󱡔 diagnostic textobj" },
			{ "L", "<cmd>lua require('various-textobjs').url()<CR>", mode = "o", desc = "󱡔 link textobj" },
			{ "o", "<cmd>lua require('various-textobjs').column()<CR>", mode = "o", desc = "󱡔 column textobj" },

			{ "ii", "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner indent textobj" },
			{ "ai", "<cmd>lua require('various-textobjs').indentation('outer', 'outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer indent textobj" },
			{ "ij", "<cmd>lua require('various-textobjs').indentation('outer', 'inner')<CR>", mode = { "x", "o" }, desc = "󱡔 top-border indent textobj" },
			{ "aj", "<cmd>lua require('various-textobjs').indentation('outer', 'inner')<CR>", mode = { "x", "o" }, desc = "󱡔 top-border indent textobj" },
			{ "ig", "<cmd>lua require('various-textobjs').greedyOuterIndentation('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner greedy indent" },
			{ "ag", "<cmd>lua require('various-textobjs').greedyOuterIndentation('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer greedy indent" },

			{ "i.", "<cmd>lua require('various-textobjs').chainMember('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner indent textobj" },
			{ "a.", "<cmd>lua require('various-textobjs').chainMember('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer indent textobj" },

			{ "il", "<cmd>lua require('various-textobjs').mdlink('inner')<CR>", ft = "markdown", desc = "󱡔 inner md link" },
			{ "al", "<cmd>lua require('various-textobjs').mdlink('outer')<CR>", ft = "markdown", desc = "󱡔 outer md link" },
			{ "iE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('inner')<CR>", ft = "markdown", desc = "󱡔 inner CodeBlock" },
			{ "aE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('outer')<CR>", ft = "markdown", desc = "󱡔 outer CodeBlock" },
			-- stylua: ignore end

			{ -- delete surrounding indentation
				"dsi",
				function()
					require("various-textobjs").indentation(true, true)
					local notOnIndentedLine = vim.fn.mode():find("V") == nil -- when textobj is found, will switch to visual line mode
					if notOnIndentedLine then return end
					u.normal("<") -- dedent indentation
					local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1] + 1
					local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
					vim.cmd(tostring(endBorderLn) .. " delete") -- delete end first so line index is not shifted
					vim.cmd(tostring(startBorderLn) .. " delete")
				end,
				desc = "Delete surrounding indentation",
			},
			{ -- open URL (forward seeking)
				"gx",
				function()
					require("various-textobjs").url()
					local foundURL = vim.fn.mode():find("v") -- when textobj is found, will switch to visual line mode
					if foundURL then
						u.normal('"zy')
						local url = vim.fn.getreg("z")
						vim.fn.system { "open", url }
					end
				end,
				desc = "󰌹 Smart URL Opener",
			},
		},
		init = function()
			-- stylua: ignore start
			u.ftKeymap("sh", {"o", "x"}, "a|", "<cmd>lua require('various-textobjs').shellPipe('inner')<CR>", { desc = "󱡔 inner shellPipe textobj"})
			u.ftKeymap("sh", {"o", "x"}, "i|", "<cmd>lua require('various-textobjs').shellPipe('outer')<CR>", { desc = "󱡔 outer shellPipe textobj"})

			u.ftKeymap("css", { "o", "x" }, "is", "<cmd>lua require('various-textobjs').cssSelector('inner')<CR>", { desc = "󱡔 inner CSS Selector textobj" })
			u.ftKeymap("css", { "o", "x" }, "as", "<cmd>lua require('various-textobjs').cssSelector('outer')<CR>", { desc = "󱡔 outer CSS Selector textobj" })
			u.ftKeymap("css", { "o", "x" }, "ix", "<cmd>lua require('various-textobjs').htmlAttribute('inner')<CR>", { desc = "󱡔 inner HTML Attribute textobj" })
			u.ftKeymap("css", { "o", "x" }, "ax", "<cmd>lua require('various-textobjs').htmlAttribute('outer')<CR>", { desc = "󱡔 outer HTML Attribute textobj" })
			-- stylua: ignore end
		end,
	},
}
