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
		event = "VimEnter", -- cannot load on key due to highlights
		keys = {
			{ "m", "<Plug>(matchup-%)", desc = "Goto Matching Bracket" },
		},
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- CamelCase Motion plus
		"chrisgrieser/nvim-spider",
		keys = {
			{
				"e",
				"<cmd>lua require('spider').motion('e')<CR>",
				mode = { "n", "o", "x" },
				desc = "󱇫 Spider e",
			},
			{
				"b",
				"<cmd>lua require('spider').motion('b')<CR>",
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
		keys = {
			{
				"q",
				function() vim.cmd.TSTextobjectSelect("@comment.outer") end,
				mode = "o", -- mapped manually to only set operator pending mode
				desc = "󱡔  comment textobj",
			},
			{
				"dq",
				"mzd<cmd>TSTextobjectSelect @comment.outer<CR>`z",
				desc = " Sticky Delete Comment",
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

			{ "n", "<cmd>lua require('various-textobjs').nearEoL()<CR>", mode = "o", desc = "󱡔 near EoL textobj" },
			{ "m", "<cmd>lua require('various-textobjs').toNextClosingBracket()<CR>", mode = { "o", "x" }, desc = "󱡔 to next closing bracket textobj" },
			{ "w", "<cmd>lua require('various-textobjs').toNextQuotationMark()<CR>", mode = "o", desc = "󱡔 to next quote textobj", nowait = true },
			{ "k", "<cmd>lua require('various-textobjs').anyQuote('inner')<CR>", mode = "o", desc = "󱡔 inner anyquote textobj" },
			{ "K", "<cmd>lua require('various-textobjs').anyQuote('outer')<CR>", mode = "o", desc = "󱡔 outer anyquote textobj" },
			{ "i" .. u.textobjMaps.wikilink, "<cmd>lua require('various-textobjs').doubleSquareBrackets('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner wikilink" },
			{ "a" .. u.textobjMaps.wikilink, "<cmd>lua require('various-textobjs').doubleSquareBrackets('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer wikilink" },

			-- INFO not setting in visual mode, to keep visual block mode replace
			{ "rv", "<cmd>lua require('various-textobjs').restOfWindow()<CR>", mode = "o", desc = "󱡔 rest of viewport textobj" },
			{ "rp", "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", mode = "o", desc = "󱡔 rest of paragraph textobj" },
			{ "ri", "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", mode = "o", desc = "󱡔 rest of indentation textobj" },
			{ "rg", "G", mode = "o", desc = "󱡔 rest of buffer textobj" },
			{ "gg", "<cmd>lua require('various-textobjs').entireBuffer()<CR>", mode = { "x", "o" }, desc = "󱡔 entire buffer textobj" },

			{ "ge", "<cmd>lua require('various-textobjs').diagnostic()<CR>", mode = { "x", "o" }, desc = "󱡔 diagnostic textobj" },
			{ "L", "<cmd>lua require('various-textobjs').url()<CR>", mode = "o", desc = "󱡔 link textobj" },
			{ "o", "<cmd>lua require('various-textobjs').column()<CR>", mode = "o", desc = "󱡔 column textobj" },
			{ "u", "<cmd>lua require('various-textobjs').multiCommentedLines()<CR>", mode = "o", desc = "󱡔 multi-line-comment textobj" },
			{ "in", "<cmd>lua require('various-textobjs').notebookCell('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner cell textobj" },
			{ "an", "<cmd>lua require('various-textobjs').notebookCell('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer cell textobj" },

			{ "ii", "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner indent textobj" },
			{ "ai", "<cmd>lua require('various-textobjs').indentation('outer', 'outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer indent textobj" },
			{ "aj", "<cmd>lua require('various-textobjs').indentation('outer', 'inner')<CR>", mode = { "x", "o" }, desc = "󱡔 top-border indent textobj" },
			{ "ig", "<cmd>lua require('various-textobjs').greedyOuterIndentation('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner greedy indent" },
			{ "ag", "<cmd>lua require('various-textobjs').greedyOuterIndentation('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer greedy indent" },

			{ "i.", "<cmd>lua require('various-textobjs').chainMember('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner indent textobj" },
			{ "a.", "<cmd>lua require('various-textobjs').chainMember('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer indent textobj" },

			-- python
			{ "iy", "<cmd>lua require('various-textobjs').pyTripleQuotes('inner')<CR>", ft = "python", mode = { "x", "o" }, desc = "󱡔 inner tripleQuotes textobj" },
			{ "ay", "<cmd>lua require('various-textobjs').pyTripleQuotes('outer')<CR>", ft = "python", mode = { "x", "o" }, desc = "󱡔 outer tripleQuotes textobj" },

			-- markdown
			{ "il", "<cmd>lua require('various-textobjs').mdlink('inner')<CR>", mode = { "x", "o" }, ft = "markdown", desc = "󱡔 inner md link" },
			{ "al", "<cmd>lua require('various-textobjs').mdlink('outer')<CR>", mode = { "x", "o" }, ft = "markdown", desc = "󱡔 outer md link" },
			{ "iE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('inner')<CR>", mode = { "x", "o" }, ft = "markdown", desc = "󱡔 inner CodeBlock" },
			{ "aE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('outer')<CR>", mode = { "x", "o" }, ft = "markdown", desc = "󱡔 outer CodeBlock" },

			-- css
			{ "is", "<cmd>lua require('various-textobjs').cssSelector('inner')<CR>", mode = { "x", "o" }, ft = "css", desc = "󱡔 inner selector" },
			{ "as", "<cmd>lua require('various-textobjs').cssSelector('outer')<CR>", mode = { "x", "o" }, ft = "css", desc = "󱡔 outer selector" },
			{ "ix", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('inner')<CR>", mode = { "x", "o" }, ft = "css", desc = "󱡔 inner attribute" },
			{ "ax", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('outer')<CR>", mode = { "x", "o" }, ft = "css", desc = "󱡔 outer attribute" },

			-- shell
			{ "i|", "<cmd>lua require('various-textobjs').shellPipe('inner')<CR>", mode = { "x", "o" }, ft = "sh", desc = "󱡔 inner pipe" },
			{ "a|", "<cmd>lua require('various-textobjs').shellPipe('outer')<CR>", mode = { "x", "o" }, ft = "sh", desc = "󱡔 outer pipe" },
			-- stylua: ignore end

			{ -- delete surrounding indentation
				"dsi",
				function()
					require("various-textobjs").indentation("outer", "outer")
					local indentationFound = vim.fn.mode():find("V") -- when textobj is found, will switch to visual line mode
					if not indentationFound then return end

					u.normal("<") -- dedent indentation
					local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1]
					local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1]
					vim.cmd(tostring(endBorderLn) .. " delete") -- delete end first so line index is not shifted
					vim.cmd(tostring(startBorderLn) .. " delete")
				end,
				desc = " Delete surrounding indent",
			},
			{ -- yank surrounding inner indentation
				"ysii", -- `ysi` would conflict with `ysib` and other textobs
				function()
					-- identify start- and end-border
					local startPos = vim.api.nvim_win_get_cursor(0)
					require("various-textobjs").indentation("outer", "outer")
					local indentationFound = vim.fn.mode():find("V")
					if not indentationFound then return end
					u.normal("V") -- leave visual mode so <> marks are set
					vim.api.nvim_win_set_cursor(0, startPos) -- restore cursor position

					-- copy them into the + register
					local startLn = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
					local endLn = vim.api.nvim_buf_get_mark(0, ">")[1] - 1
					local startLine = vim.api.nvim_buf_get_lines(0, startLn, startLn + 1, false)[1]
					local endLine = vim.api.nvim_buf_get_lines(0, endLn, endLn + 1, false)[1]
					vim.fn.setreg("+", startLine .. "\n" .. endLine .. "\n")

					-- highlight yanked text
					local ns = vim.api.nvim_create_namespace("ysi")
					vim.highlight.range(0, ns, "IncSearch", { startLn, 0 }, { startLn, -1 })
					vim.highlight.range(0, ns, "IncSearch", { endLn, 0 }, { endLn, -1 })
					vim.defer_fn(function() vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) end, 1000)
				end,
				desc = "󰅍 Yank surrounding indent",
			},
			{ -- open URL (forward seeking)
				"gx",
				function()
					require("various-textobjs").url()
					local foundURL = vim.fn.mode():find("v") -- when textobj is found, will switch to visual line mode
					if not foundURL then return end

					u.normal('"zy')
					local url = vim.fn.getreg("z")
					vim.fn.system { "open", url }
				end,
				desc = "󰌹 Smart URL Opener",
			},
		},
	},
}
