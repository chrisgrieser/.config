local u = require("config.utils")
local textobj = require("config.utils").textobjMaps

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
		event = "VimEnter", -- cannot load on keys due to highlights
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
				mode = { "n", "x" }, -- not `o`, since mapped to inner bracket
				desc = "󱇫 Spider b",
			},
		},
	},
	-----------------------------------------------------------------------------
	{ -- treesitter-based textobjs
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = "nvim-treesitter/nvim-treesitter",
		cmd = { -- used in the mappings below
			"TSTextobjectSelect",
			"TSTextobjectGotoNextStart",
			"TSTextobjectGotoPreviousStart",
			"TSTextobjectPeekDefinitionCode",
		},
		keys = {
			{
				"<leader>H",
				function() vim.cmd.TSTextobjectPeekDefinitionCode("@function.outer") end,
				desc = " Hover Peek Function",
			},
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
			{
				"<C-j>",
				"<cmd>TSTextobjectGotoNextStart @function.outer<CR>zv",
				desc = " Goto Next Function",
			},
			{
				"<C-k>",
				"<cmd>TSTextobjectGotoPreviousStart @function.outer<CR>zv",
				desc = " Goto Previous Function",
			},
			-----------------------------------------------------------------------
			-- INFO outer key textobj defined via various textobjs
			-- stylua: ignore start
			{ "ik", "<cmd>TSTextobjectSelect @assignment.lhs<CR>", mode = { "x", "o" }, desc = "󱡔 inner key" },
			{ "a<CR>", "<cmd>TSTextobjectSelect @return.outer<CR>", mode = { "x", "o" }, desc = "󱡔 outer return" },
			{ "i<CR>", "<cmd>TSTextobjectSelect @return.inner<CR>", mode = { "x", "o" }, desc = "󱡔 inner return" },
			{ "a/", "<cmd>TSTextobjectSelect @regex.outer<CR>", mode = { "x", "o" }, desc = "󱡔 outer regex" },
			{ "i/", "<cmd>TSTextobjectSelect @regex.inner<CR>", mode = { "x", "o" }, desc = "󱡔 inner regex" },
			{ "aa", "<cmd>TSTextobjectSelect @parameter.outer<CR>", mode = { "x", "o" }, desc = "󱡔 outer parameter" },
			{ "ia", "<cmd>TSTextobjectSelect @parameter.inner<CR>", mode = { "x", "o" }, desc = "󱡔 inner parameter" },
			{ "iu", "<cmd>TSTextobjectSelect @loop.inner<CR>", mode = { "x", "o" }, desc = "󱡔 inner loop" },
			{ "au", "<cmd>TSTextobjectSelect @loop.outer<CR>", mode = { "x", "o" }, desc = "󱡔 outer loop" },
			{ "a" .. textobj.func, "<cmd>TSTextobjectSelect @function.outer<CR>", mode = {"x","o"},desc = "󱡔 outer function" },
			{ "i" .. textobj.func, "<cmd>TSTextobjectSelect @function.inner<CR>", mode = {"x","o"},desc = "󱡔 inner function" },
			{ "a" .. textobj.cond, "<cmd>TSTextobjectSelect @conditional.outer<CR>", mode = {"x","o"},desc = "󱡔 outer cond." },
			{ "i" .. textobj.cond, "<cmd>TSTextobjectSelect @conditional.inner<CR>", mode = {"x","o"},desc = "󱡔 inner cond." },
			{ "a" .. textobj.call, "<cmd>TSTextobjectSelect @call.outer<CR>", mode = {"x","o"},desc = "󱡔 outer call" },
			{ "i" .. textobj.call, "<cmd>TSTextobjectSelect @call.inner<CR>", mode = {"x","o"},desc = "󱡔 inner call" },
			-- stylua: ignore end
		},
	},
	{ -- pattern-based textobjs
		"chrisgrieser/nvim-various-textobjs",
		init = function()
			-- cannot use lazy.nvim's key-setting since `il` / `al` is also mapped
			-- for the call-textobj PENDING https://github.com/folke/lazy.nvim/issues/1241
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					vim.keymap.set(
						{ "o", "x" },
						"il",
						"<cmd>lua require('various-textobjs').mdlink('inner')<CR>",
						{ desc = "󱡔 inner md link", buffer = true }
					)
					vim.keymap.set(
						{ "o", "x" },
						"al",
						"<cmd>lua require('various-textobjs').mdlink('outer')<CR>",
						{ desc = "󱡔 outer md link", buffer = true }
					)
				end,
			})
		end,
		keys = {
			-- stylua: ignore start
			{ "<Space>", "<cmd>lua require('various-textobjs').subword('inner')<CR>", mode = "o", desc = "󱡔 inner subword" },
			{ "a<Space>", "<cmd>lua require('various-textobjs').subword('outer')<CR>", mode = { "o", "x" }, desc = "󱡔 outer subword" },

			{ "iv", "<cmd>lua require('various-textobjs').value('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner value" },
			{ "av", "<cmd>lua require('various-textobjs').value('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer value" },
			-- INFO `ik` defined via treesitter to exclude `local` and `let`;
			{ "ak", "<cmd>lua require('various-textobjs').key('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer key" },

			{ "gg", "<cmd>lua require('various-textobjs').entireBuffer()<CR>", mode = { "x", "o" }, desc = "󱡔 entire buffer" },

			{ "n", "<cmd>lua require('various-textobjs').nearEoL()<CR>", mode = "o", desc = "󱡔 near EoL" },
			{ "m", "<cmd>lua require('various-textobjs').toNextClosingBracket()<CR>", mode = { "o", "x" }, desc = "󱡔 to next closing bracket" },
			{ "w", "<cmd>lua require('various-textobjs').toNextQuotationMark()<CR>", mode = "o", desc = "󱡔 to next quote", nowait = true },
			{ "b", "<cmd>lua require('various-textobjs').anyBracket('inner')<CR>", mode = "o", desc = "󱡔 inner anyBracket" },
			{ "B", "<cmd>lua require('various-textobjs').anyBracket('outer')<CR>", mode = "o", desc = "󱡔 outer anyBracket" },
			{ "k", "<cmd>lua require('various-textobjs').anyQuote('inner')<CR>", mode = "o", desc = "󱡔 inner anyQuote" },
			{ "K", "<cmd>lua require('various-textobjs').anyQuote('outer')<CR>", mode = "o", desc = "󱡔 outer anyQuote" },
			{ "i" .. textobj.wikilink, "<cmd>lua require('various-textobjs').doubleSquareBrackets('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner wikilink" },
			{ "a" .. textobj.wikilink, "<cmd>lua require('various-textobjs').doubleSquareBrackets('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer wikilink" },

			-- INFO not setting in visual mode, to keep visual block mode replace
			{ "rv", "<cmd>lua require('various-textobjs').restOfWindow()<CR>", mode = "o", desc = "󱡔 rest of viewport" },
			{ "rp", "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", mode = "o", desc = "󱡔 rest of paragraph" },
			{ "ri", "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", mode = "o", desc = "󱡔 rest of indentation" },
			{ "rg", "G", mode = "o", desc = "󱡔 rest of buffer" },

			{ "ge", "<cmd>lua require('various-textobjs').diagnostic()<CR>", mode = { "x", "o" }, desc = "󱡔 diagnostic" },
			{ "L", "<cmd>lua require('various-textobjs').url()<CR>", mode = "o", desc = "󱡔 link" },
			{ "o", "<cmd>lua require('various-textobjs').column()<CR>", mode = "o", desc = "󱡔 column" },
			-- using the textobj from mini.comment
			-- { "u", "<cmd>lua require('various-textobjs').multiCommentedLines()<CR>", mode = "o", desc = "󱡔 multi-line-comment" },
			{ "in", "<cmd>lua require('various-textobjs').number('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner number" },
			{ "an", "<cmd>lua require('various-textobjs').number('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer number" },

			{ "ii", "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner indent" },
			{ "ai", "<cmd>lua require('various-textobjs').indentation('outer', 'outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer indent" },
			{ "aj", "<cmd>lua require('various-textobjs').indentation('outer', 'inner')<CR>", mode = { "x", "o" }, desc = "󱡔 top-border indent" },
			{ "ig", "<cmd>lua require('various-textobjs').greedyOuterIndentation('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner greedy indent" },
			{ "ag", "<cmd>lua require('various-textobjs').greedyOuterIndentation('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer greedy indent" },

			{ "i.", "<cmd>lua require('various-textobjs').chainMember('inner')<CR>", mode = { "x", "o" }, desc = "󱡔 inner indent" },
			{ "a.", "<cmd>lua require('various-textobjs').chainMember('outer')<CR>", mode = { "x", "o" }, desc = "󱡔 outer indent" },

			-- python
			{ "iy", "<cmd>lua require('various-textobjs').pyTripleQuotes('inner')<CR>", ft = "python", mode = { "x", "o" }, desc = "󱡔 inner tripleQuotes" },
			{ "ay", "<cmd>lua require('various-textobjs').pyTripleQuotes('outer')<CR>", ft = "python", mode = { "x", "o" }, desc = "󱡔 outer tripleQuotes" },

			-- markdown
			{ "iE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('inner')<CR>", mode = { "x", "o" }, ft = "markdown", desc = "󱡔 inner CodeBlock" },
			{ "aE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('outer')<CR>", mode = { "x", "o" }, ft = "markdown", desc = "󱡔 outer CodeBlock" },

			-- css
			{ "is", "<cmd>lua require('various-textobjs').cssSelector('inner')<CR>", mode = { "x", "o" }, ft = "css", desc = "󱡔 inner selector" },
			{ "as", "<cmd>lua require('various-textobjs').cssSelector('outer')<CR>", mode = { "x", "o" }, ft = "css", desc = "󱡔 outer selector" },

			-- shell
			{ "pi", "<cmd>lua require('various-textobjs').shellPipe('inner')<CR>", mode = "o", ft = "sh", desc = "󱡔 inner pipe" },
			-- stylua: ignore end

			{ -- delete surrounding indentation
				"dsi",
				function()
					require("various-textobjs").indentation("outer", "outer")
					local indentationFound = vim.fn.mode():find("V")
					if not indentationFound then return end

					u.normal("<") -- dedent indentation
					local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1]
					local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1]
					vim.cmd(tostring(endBorderLn) .. " delete") -- delete end first so line index is not shifted
					vim.cmd(tostring(startBorderLn) .. " delete")
				end,
				desc = " Delete surrounding indent",
			},
			{ -- indent last paste
				"P",
				function()
					require("various-textobjs").lastChange()
					local changeFound = vim.fn.mode():find("v")
					if changeFound then u.normal(">") end
				end,
				desc = " Indent Last Paste",
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
					vim.api.nvim_win_set_cursor(0, startPos) -- restore (= sticky)

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
					local foundURL = vim.fn.mode():find("v")
					if foundURL then
						u.normal('"zy')
						local url = vim.fn.getreg("z")
						vim.fn.system { "open", url }
					else
						-- select from all URLs in buffer. Simplified version of urlview.nvim
						local urlPattern = require("various-textobjs.charwise-textobjs").urlPattern
						local bufText = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
						local urls = {}
						for url in bufText:gmatch(urlPattern) do
							table.insert(urls, url)
						end
						if #urls == 0 then return end

						vim.ui.select(urls, { prompt = "Select URL:" }, function(choice)
							if choice then vim.fn.system { "open", choice } end
						end)
					end
				end,
				desc = "󰌹 Smart URL Opener",
			},
		},
	},
}
