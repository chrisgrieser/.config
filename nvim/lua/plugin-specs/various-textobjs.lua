local textObj = require("config.utils").extraTextobjMaps
--------------------------------------------------------------------------------

return {
	"chrisgrieser/nvim-various-textobjs",
	opts = { debug = vim.uv.fs_stat(vim.g.localRepos .. "/nvim-various-textobjs") },
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
		{ "b", "<cmd>lua require('various-textobjs').toNextClosingBracket()<CR>", mode = "o", desc = "⦈ to closing bracket" },
		{ "w", "<cmd>lua require('various-textobjs').toNextQuotationMark()<CR>", mode = "o", desc = " to next quote" },
		{ "k", "<cmd>lua require('various-textobjs').anyQuote('inner')<CR>", mode = "o", desc = " inner-quote (any)" },
		{ "K", "<cmd>lua require('various-textobjs').anyQuote('outer')<CR>", mode = "o", desc = " outer-quote (any)" },

		-- not setting these in visual mode, to keep visual block mode replace
		{ "rp", "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", mode = "o", desc = "¶ rest of paragraph" },
		{ "ri", "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", mode = "o", desc = "󰉶 rest of indentation" },
		{ "rg", "G", mode = "o", desc = " rest of buffer" },

		{ "ge", "<cmd>lua require('various-textobjs').diagnostic()<CR>", mode = {"x","o"}, desc = " diagnostic" },
		{ "L", "<cmd>lua require('various-textobjs').url()<CR>", mode = "o", desc = " URL" },
		{ "o", "<cmd>lua require('various-textobjs').column()<CR>", mode = "o", desc = "ﴳ column" },
		{ "#", "<cmd>lua require('various-textobjs').cssColor('outer')<CR>", mode = {"x","o"}, desc = " outer color" },

		{ "in", "<cmd>lua require('various-textobjs').number('inner')<CR>", mode = {"x","o"}, desc = " inner number" },
		{ "an", "<cmd>lua require('various-textobjs').number('outer')<CR>", mode = {"x","o"}, desc = " outer number" },

		{ "a_", "<cmd>lua require('various-textobjs').lineCharacterwise('outer')<CR>", mode = {"x","o"}, desc = "outer line" },
		{ "i_", "<cmd>lua require('various-textobjs').lineCharacterwise('inner')<CR>", mode = {"x","o"}, desc = "inner line" },

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
		{ "iS", "<cmd>lua require('various-textobjs').pyTripleQuotes('inner')<CR>", ft = "python", mode = {"x","o"}, desc = " inner tripleQuotes" },
		{ "aS", "<cmd>lua require('various-textobjs').pyTripleQuotes('outer')<CR>", ft = "python", mode = {"x","o"}, desc = " outer tripleQuotes" },

		-- markdown
		{ "iE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('inner')<CR>", mode = {"x","o"}, ft = "markdown", desc = " inner CodeBlock" },
		{ "aE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('outer')<CR>", mode = {"x","o"}, ft = "markdown", desc = " outer CodeBlock" },
		{ "il", "<cmd>lua require('various-textobjs').mdLink('inner')<CR>", mode = {"x","o"}, ft = "markdown", desc = " inner md-link" },
		{ "al", "<cmd>lua require('various-textobjs').mdLink('outer')<CR>", mode = {"x","o"}, ft = "markdown", desc = " outer md-link" },

		-- css
		{ "is", "<cmd>lua require('various-textobjs').cssSelector('inner')<CR>", mode = {"x","o"}, ft = "css", desc = " inner selector" },
		{ "as", "<cmd>lua require('various-textobjs').cssSelector('outer')<CR>", mode = {"x","o"}, ft = "css", desc = " outer selector" },

		-- shell
		{ "ix", "<cmd>lua require('various-textobjs').shellPipe('inner')<CR>", mode = "o", ft = "sh", desc = "󰟥 inner pipe" },
		{ "ax", "<cmd>lua require('various-textobjs').shellPipe('outer')<CR>", mode = "o", ft = "sh", desc = "󰟥 outer pipe" },
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
		{ -- dedent last paste (if showing up falsely in whichkey, disable `maplocalleader`)
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
				local cursorBefore = vim.api.nvim_win_get_cursor(0)

				require("various-textobjs").indentation("outer", "outer")
				local indentationFound = vim.fn.mode() == "V"
				if not indentationFound then return end

				vim.cmd.normal { "<", bang = true } -- dedent indentation
				local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1]
				local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1]
				vim.cmd(endBorderLn .. " delete") -- delete end first so line index is not shifted
				vim.cmd(startBorderLn .. " delete")

				-- defer to due race condition with sticky deletion
				vim.defer_fn(function() vim.api.nvim_win_set_cursor(0, cursorBefore) end, 1)
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

				-- copy them into the `+` register
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
				local cursorBefore = vim.api.nvim_win_get_cursor(0)

				require("various-textobjs").url()
				local foundURL = vim.fn.mode() == "v"
				if not foundURL then return end

				vim.cmd.normal { '"zy', bang = true }
				local url = vim.fn.getreg("z")
				vim.ui.open(url)
				vim.api.nvim_win_set_cursor(0, cursorBefore)
			end,
			desc = " Open next URL",
		},
		{ -- to next `then` in lua
			"N",
			mode = "o",
			function()
				local charwise = require("various-textobjs.textobjs.charwise.core")
				local pattern = "().( then)"
				local row, _, endCol = charwise.getTextobjPos(pattern, "inner", 5)
				charwise.selectFromCursorTo({ row, endCol }, 5)
			end,
			ft = "lua",
			desc = "󰬞 to next `then`",
		},
		{ -- path textobj
			"a-",
			mode = "o",
			function()
				local charwise = require("various-textobjs.textobjs.charwise.core")
				local pattern = "(%.?/[%w_%-./]+/)[%w_%-.]+()"
				charwise.selectClosestTextobj(pattern, "outer", 5)
			end,
			desc = " outer path",
		},
		{
			"i-",
			mode = "o",
			function()
				local charwise = require("various-textobjs.textobjs.charwise.core")
				local pattern = "(%.?/[%w_%-./]+/)[%w_%-.]+()"
				charwise.selectClosestTextobj(pattern, "inner", 5)
			end,
			desc = " inner path",
		},
	},
}
