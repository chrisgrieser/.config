local textObj = require("config.utils").extraTextobjMaps
--------------------------------------------------------------------------------

return {
	{ -- smarter `w` `e` `b` motions
		"chrisgrieser/nvim-spider",
		keys = {
			{
				"e",
				"<cmd>lua require('spider').motion('e')<CR>",
				mode = { "n", "x", "o" },
				desc = "󱇫 end of subword",
			},
			{
				"b",
				"<cmd>lua require('spider').motion('b')<CR>",
				mode = { "n", "x" }, -- not `o`, since mapped as textobj
				desc = "󱇫 beginning of subword",
			},
		},
	},
	{ -- treesitter-based textobjs
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = "nvim-treesitter/nvim-treesitter",
		cmd = {
			"TSTextobjectSelect",
			"TSTextobjectSwapNext",
			"TSTextobjectSwapPrevious",
			"TSTextobjectGotoNextStart",
			"TSTextobjectGotoPreviousStart",
			"TSTextobjectPeekDefinitionCode",
		},
		-- INFO yes, configured via treesitter, not this plugin. Also, calling
		-- treesitter's `setup` a second time is apparently not a problem.
		main = "nvim-treesitter.configs",
		opts = {
			textobjects = {
				select = {
					lookahead = true,
					include_surrounding_whitespace = false, -- `true` breaks my comment textobj mappings
				},
				-- for `:TSTextobjectPeekDefinitionCode` (used in overwritten handler for LSP hover)
				lsp_interop = {
					border = vim.g.borderStyle,
					floating_preview_opts = {
						title = "  Peek ",
						max_width = 75,
					},
				},
			},
		},
		keys = {
			-- COMMENT OPERATIONS
			{
				"q",
				function() vim.cmd.TSTextobjectSelect("@comment.outer") end,
				mode = "o", -- only operator-pending to not conflict with selection-commenting
				desc = "󰆈 Single comment",
			},
			{
				"dq",
				function()
					local prevCursor = vim.api.nvim_win_get_cursor(0)
					vim.cmd.TSTextobjectSelect("@comment.outer")
					vim.cmd.normal { "d", bang = true }
					local trimmedLine = vim.api.nvim_get_current_line():gsub("%s+$", "")
					vim.api.nvim_set_current_line(trimmedLine)
					vim.api.nvim_win_set_cursor(0, prevCursor)
				end,
				desc = "󰆈 Sticky delete comment",
			},
			{
				"cq",
				function()
					vim.cmd.TSTextobjectSelect("@comment.outer")
					vim.cmd.normal { "d", bang = true }
					local comStr = vim.trim(vim.bo.commentstring:format(""))
					local line = vim.api.nvim_get_current_line():gsub("%s+$", "")
					vim.api.nvim_set_current_line(line .. " " .. comStr .. " ")
					vim.cmd.startinsert { bang = true }
				end,
				desc = "󰆈 Change comment",
			},

			-- MOVE & SWAP
			-- stylua: ignore start
			{ "<C-j>", "<cmd>TSTextobjectGotoNextStart @function.outer<CR>", desc = " Goto next function" },
			{ "<C-k>", "<cmd>TSTextobjectGotoPreviousStart @function.outer<CR>", desc = " Goto prev function" },
			{ "ä", "<cmd>TSTextobjectSwapNext @parameter.inner<CR>", desc = " Swap next arg" },
			{ "Ä", "<cmd>TSTextobjectSwapPrevious @parameter.inner<CR>", desc = " Swap prev arg" },
			-- stylua: ignore end

			-- TEXT OBJECTS
			-- stylua: ignore start
			{ "a<CR>", "<cmd>TSTextobjectSelect @return.outer<CR>", mode = {"x","o"}, desc = "↩ outer return" },
			{ "i<CR>", "<cmd>TSTextobjectSelect @return.inner<CR>", mode = "o", desc = "↩ inner return" },
			{ "a/", "<cmd>TSTextobjectSelect @regex.outer<CR>", mode = {"x","o"}, desc = " outer regex" },
			{ "i/", "<cmd>TSTextobjectSelect @regex.inner<CR>", mode = {"x","o"}, desc = " inner regex" },
			{ "aa", "<cmd>TSTextobjectSelect @parameter.outer<CR>", mode = {"x","o"}, desc = "󰏪 outer arg" },
			{ "ia", "<cmd>TSTextobjectSelect @parameter.inner<CR>", mode = {"x","o"}, desc = "󰏪 inner arg" },
			{ "iu", "<cmd>TSTextobjectSelect @loop.inner<CR>", mode = {"x","o"}, desc = "󰛤 inner loop" },
			{ "au", "<cmd>TSTextobjectSelect @loop.outer<CR>", mode = {"x","o"}, desc = "󰛤 outer loop" },
			{ "a" .. textObj.func, "<cmd>TSTextobjectSelect @function.outer<CR>", mode = {"x","o"},desc = " outer function" },
			{ "i" .. textObj.func, "<cmd>TSTextobjectSelect @function.inner<CR>", mode = {"x","o"},desc = " inner function" },
			{ "a" .. textObj.condition, "<cmd>TSTextobjectSelect @conditional.outer<CR>", mode = {"x","o"},desc = "󱕆 outer c[o]ndition" },
			{ "i" .. textObj.condition, "<cmd>TSTextobjectSelect @conditional.inner<CR>", mode = {"x","o"},desc = "󱕆 inner c[o]ndition" },
			{ "a" .. textObj.call, "<cmd>TSTextobjectSelect @call.outer<CR>", mode = {"x","o"},desc = "󰡱 outer ca[l]l" },
			{ "i" .. textObj.call, "<cmd>TSTextobjectSelect @call.inner<CR>", mode = {"x","o"},desc = "󰡱 inner ca[l]l" },
			-- stylua: ignore end
		},
	},
	{ -- pattern-based textobjs
		"chrisgrieser/nvim-various-textobjs",
		keys = {
			{
				"<Space>",
				function()
					-- for deletions use the outer subword, otherwise the inner
					local scope = vim.v.operator == "d" and "outer" or "inner"
					require("various-textobjs").subword(scope)
				end,
				mode = "o",
				desc = "󰬞 subword",
			},

			-- stylua: ignore start
			{ "iv", "<cmd>lua require('various-textobjs').value('inner')<CR>", mode = {"x","o"}, desc = " inner value" },
			{ "av", "<cmd>lua require('various-textobjs').value('outer')<CR>", mode = {"x","o"}, desc = " outer value" },
			{ "ak", "<cmd>lua require('various-textobjs').key('outer')<CR>", mode = {"x","o"}, desc = "󰌆 outer key" },
			{ "ik", "<cmd>lua require('various-textobjs').key('inner')<CR>", mode = {"x","o"}, desc = "󰌆 inner key" },

			{ "gg", "<cmd>lua require('various-textobjs').entireBuffer()<CR>", mode = {"x","o"}, desc = " entire buffer" },

			{ "n", "<cmd>lua require('various-textobjs').nearEoL()<CR>", mode = "o", desc = "󰑀 near EoL" },
			{ "b", "<cmd>lua require('various-textobjs').toNextClosingBracket()<CR>", mode = "o", desc = "󰅪 to next bracket" },
			{ "w", "<cmd>lua require('various-textobjs').toNextQuotationMark()<CR>", mode = "o", desc = " to next quote" },
			{ "k", "<cmd>lua require('various-textobjs').anyQuote('inner')<CR>", mode = "o", desc = " inner quote (any)" },
			{ "K", "<cmd>lua require('various-textobjs').anyQuote('outer')<CR>", mode = "o", desc = " outer quote (any)" },

			-- INFO not setting these in visual mode, to keep visual block mode replace
			{ "rp", "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", mode = "o", desc = "¶ rest of paragraph" },
			{ "ri", "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", mode = "o", desc = "󰉶 rest of indentation" },
			{ "rg", "G", mode = "o", desc = " rest of buffer" },

			{ "ge", "<cmd>lua require('various-textobjs').diagnostic()<CR>", mode = {"x","o"}, desc = " diagnostic" },
			{ "L", "<cmd>lua require('various-textobjs').url()<CR>", mode = "o", desc = " URL" },
			{ "o", "<cmd>lua require('various-textobjs').column()<CR>", mode = "o", desc = "ﴳ column" },
			{ "#", "<cmd>lua require('various-textobjs').cssColor('outer')<CR>", mode = {"x","o"}, desc = " outer color" },

			{ "in", "<cmd>lua require('various-textobjs').number('inner')<CR>", mode = {"x","o"}, desc = " inner number" },
			{ "an", "<cmd>lua require('various-textobjs').number('outer')<CR>", mode = {"x","o"}, desc = " outer number" },

			{ "ii", "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>", mode = {"x","o"}, desc = "󰉶 inner indent" },
			{ "ai", "<cmd>lua require('various-textobjs').indentation('outer', 'outer')<CR>", mode = {"x","o"}, desc = "󰉶 outer indent" },
			{ "aj", "<cmd>lua require('various-textobjs').indentation('outer', 'inner')<CR>", mode = {"x","o"}, desc = "󰉶 top-border indent" },
			{ "ig", "<cmd>lua require('various-textobjs').greedyOuterIndentation('inner')<CR>", mode = {"x","o"}, desc = "󰉶 inner greedy indent" },
			{ "ag", "<cmd>lua require('various-textobjs').greedyOuterIndentation('outer')<CR>", mode = {"x","o"}, desc = "󰉶 outer greedy indent" },

			{ "i.", "<cmd>lua require('various-textobjs').chainMember('inner')<CR>", mode = {"x","o"}, desc = "󰌷 inner chainMember" },
			{ "a.", "<cmd>lua require('various-textobjs').chainMember('outer')<CR>", mode = {"x","o"}, desc = "󰌷 outer chainMember" },
			{ "i" .. textObj.wikilink, "<cmd>lua require('various-textobjs').doubleSquareBrackets('inner')<CR>", mode = {"x","o"}, desc = "󰖬 inner wikilink" },
			{ "a" .. textObj.wikilink, "<cmd>lua require('various-textobjs').doubleSquareBrackets('outer')<CR>", mode = {"x","o"}, desc = "󰖬 outer wikilink" },

			-- python
			{ "iy", "<cmd>lua require('various-textobjs').pyTripleQuotes('inner')<CR>", ft = "python", mode = {"x","o"}, desc = " inner tripleQuotes" },
			{ "ay", "<cmd>lua require('various-textobjs').pyTripleQuotes('outer')<CR>", ft = "python", mode = {"x","o"}, desc = " outer tripleQuotes" },

			-- markdown
			{ "iE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('inner')<CR>", mode = {"x","o"}, ft = "markdown", desc = " inner CodeBlock" },
			{ "aE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('outer')<CR>", mode = {"x","o"}, ft = "markdown", desc = " outer CodeBlock" },
			{ "il", "<cmd>lua require('various-textobjs').mdLink('inner')<CR>", mode = {"x","o"}, ft = "markdown", desc = " inner md-link" },
			{ "al", "<cmd>lua require('various-textobjs').mdLink('outer')<CR>", mode = {"x","o"}, ft = "markdown", desc = " outer md-link" },

			-- css
			{ "is", "<cmd>lua require('various-textobjs').cssSelector('inner')<CR>", mode = {"x","o"}, ft = "css", desc = " inner selector" },
			{ "as", "<cmd>lua require('various-textobjs').cssSelector('outer')<CR>", mode = {"x","o"}, ft = "css", desc = " outer selector" },

			-- shell
			{ "iP", "<cmd>lua require('various-textobjs').shellPipe('inner')<CR>", mode = "o", ft = "sh", desc = "󰟥 inner pipe" },
			{ "aP", "<cmd>lua require('various-textobjs').shellPipe('outer')<CR>", mode = "o", ft = "sh", desc = "󰟥 outer pipe" },
			-- stylua: ignore end

			{ -- indent last paste
				"^",
				function()
					require("various-textobjs").lastChange()
					local changeFound = vim.fn.mode() == "v"
					if changeFound then vim.cmd.normal { ">", bang = true } end
				end,
				desc = "󰉶 Indent last paste",
			},
			{ -- indent last paste
				"\\", -- shift-^ on my keyboard
				function()
					require("various-textobjs").lastChange()
					local changeFound = vim.fn.mode() == "v"
					if changeFound then vim.cmd.normal { "<", bang = true } end
				end,
				desc = "󰉵 Dedent last paste",
			},
			{ -- delete surrounding indentation
				"dsi",
				function()
					require("various-textobjs").indentation("outer", "outer")
					local indentationFound = vim.fn.mode() == "V"
					if not indentationFound then return end

					vim.cmd.normal { "<", bang = true } -- dedent indentation
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
					local indentationFound = vim.fn.mode() == "V"
					if not indentationFound then return end
					vim.cmd.normal { "V", bang = true } -- leave visual mode so <> marks are set
					vim.api.nvim_win_set_cursor(0, startPos) -- restore (= sticky yank)

					-- copy them into the + register
					local startLn = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
					local endLn = vim.api.nvim_buf_get_mark(0, ">")[1] - 1
					local startLine = vim.api.nvim_buf_get_lines(0, startLn, startLn + 1, false)[1]
					local endLine = vim.api.nvim_buf_get_lines(0, endLn, endLn + 1, false)[1]
					vim.fn.setreg("+", startLine .. "\n" .. endLine .. "\n")

					-- highlight yanked text
					local duration = 1000
					local ns = vim.api.nvim_create_namespace("ysii")
					vim.api.nvim_buf_add_highlight(0, ns, "IncSearch", startLn, 0, -1)
					vim.api.nvim_buf_add_highlight(0, ns, "IncSearch", endLn, 0, -1)
					vim.defer_fn(function() vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) end, duration)
				end,
				desc = "󰅍 Yank surrounding indent",
			},
			{ -- open URL (forward seeking)
				"gx",
				function()
					require("various-textobjs").url()
					local foundURL = vim.fn.mode() == "v"
					if foundURL then
						vim.cmd.normal { '"zy', bang = true }
						local url = vim.fn.getreg("z")
						vim.ui.open(url)
					end
				end,
				desc = " Open next URL",
			},
			{ -- open URL (forward seeking)
				"N",
				mode = "o",
				function()
					local charwise = require("various-textobjs.textobjs.charwise")
					local pattern = "().(%S+%s*)$"
					local row, _, endCol = charwise.getTextobjPos(pattern, "inner", 0)
					charwise.selectFromCursorTo({ row, endCol }, 0)
				end,
				desc = "󰬞 up to last WORD",
			},
		},
	},
}
