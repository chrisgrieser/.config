return {
	"chrisgrieser/nvim-various-textobjs",
	opts = { debug = false },
	keys = {
		{ -- subword
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
		{ ".", "<cmd>lua require('various-textobjs').emoji()<CR>", mode = {"x","o"}, desc = " emoji" },

		{ "a-", "<cmd>lua require('various-textobjs').filepath('outer')<CR>", mode = {"x","o"}, desc = " outer filepath" },
		{ "i-", "<cmd>lua require('various-textobjs').filepath('inner')<CR>", mode = {"x","o"}, desc = " inner filepath" },

		{ "a,", "<cmd>lua require('various-textobjs').argument('outer')<CR>", mode = {"x","o"}, desc = "󰏪 outer argument" },
		{ "i,", "<cmd>lua require('various-textobjs').argument('inner')<CR>", mode = {"x","o"}, desc = "󰏪 inner argument" },

		{ "iv", "<cmd>lua require('various-textobjs').value('inner')<CR>", mode = {"x","o"}, desc = " inner value" },
		{ "av", "<cmd>lua require('various-textobjs').value('outer')<CR>", mode = {"x","o"}, desc = " outer value" },
		{ "ak", "<cmd>lua require('various-textobjs').key('outer')<CR>", mode = {"x","o"}, desc = "󰌆 outer key" },
		{ "ik", "<cmd>lua require('various-textobjs').key('inner')<CR>", mode = {"x","o"}, desc = "󰌆 inner key" },

		{ "gg", "<cmd>lua require('various-textobjs').entireBuffer()<CR>", mode = {"x","o"}, desc = " entire buffer" },

		{ "n", "<cmd>lua require('various-textobjs').nearEoL()<CR>", mode = "o", desc = "󰑀 near EoL" },
		{ "w", "<cmd>lua require('various-textobjs').toNextQuotationMark()<CR>", mode = "o", desc = " to next quote" },
		{ "m", "<cmd>lua require('various-textobjs').toNextClosingBracket()<CR>", mode = "o", desc = "⦈ to closing bracket" },
		{ "k", "<cmd>lua require('various-textobjs').anyQuote('inner')<CR>", mode = "o", desc = " inner-quote (any)" },
		{ "K", "<cmd>lua require('various-textobjs').anyQuote('outer')<CR>", mode = "o", desc = " outer-quote (any)" },
		{ "b", "<cmd>lua require('various-textobjs').anyBracket('inner')<CR>", mode = "o", desc = "⦈ inner-bracket (any)" },
		{ "B", "<cmd>lua require('various-textobjs').anyBracket('outer')<CR>", mode = "o", desc = "⦈ outer-bracket (any)" },

		-- not setting these in visual mode, to keep visual block mode replace
		{ "rp", "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", mode = "o", desc = "¶ rest of paragraph" },
		{ "ri", "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", mode = "o", desc = "󰉶 rest of indentation" },
		{ "rg", "G", mode = "o", desc = " rest of buffer" },

		{ "ge", "<cmd>lua require('various-textobjs').diagnostic()<CR>", mode = {"x","o"}, desc = " diagnostic" },
		{ "L", "<cmd>lua require('various-textobjs').url()<CR>", mode = "o", desc = " URL" },
		{ "C", "<cmd>lua require('various-textobjs').column()<CR>", mode = {"x","o"}, desc = "ﴳ column" },
		{ "#", "<cmd>lua require('various-textobjs').color('outer')<CR>", mode = {"x","o"}, desc = " outer color" },

		{ "in", "<cmd>lua require('various-textobjs').number('inner')<CR>", mode = {"x","o"}, desc = " inner number" },
		{ "an", "<cmd>lua require('various-textobjs').number('outer')<CR>", mode = {"x","o"}, desc = " outer number" },

		{ "ii", "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>", mode = {"x","o"}, desc = "󰉶 inner indent" },
		{ "ai", "<cmd>lua require('various-textobjs').indentation('outer', 'outer')<CR>", mode = {"x","o"}, desc = "󰉶 outer indent" },
		{ "aj", "<cmd>lua require('various-textobjs').indentation('outer', 'inner')<CR>", mode = {"x","o"}, desc = "󰉶 top-border indent" },
		{ "ig", "<cmd>lua require('various-textobjs').greedyOuterIndentation('inner')<CR>", mode = {"x","o"}, desc = "󰉶 inner greedy indent" },
		{ "ag", "<cmd>lua require('various-textobjs').greedyOuterIndentation('outer')<CR>", mode = {"x","o"}, desc = "󰉶 outer greedy indent" },

		{ "i.", "<cmd>lua require('various-textobjs').chainMember('inner')<CR>", mode = {"x","o"}, desc = "󰌷 inner chainMember" },
		{ "a.", "<cmd>lua require('various-textobjs').chainMember('outer')<CR>", mode = {"x","o"}, desc = "󰌷 outer chainMember" },
		{ "iR", "<cmd>lua require('various-textobjs').doubleSquareBrackets('inner')<CR>", mode = {"x","o"}, desc = "󰖬 inner wikilink" },
		{ "aR", "<cmd>lua require('various-textobjs').doubleSquareBrackets('outer')<CR>", mode = {"x","o"}, desc = "󰖬 outer wikilink" },

		-- markdown
		{ "iE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('inner')<CR>", mode = {"x","o"}, ft = "markdown", desc = " inner CodeBlock" },
		{ "aE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('outer')<CR>", mode = {"x","o"}, ft = "markdown", desc = " outer CodeBlock" },
		{ "il", "<cmd>lua require('various-textobjs').mdLink('inner')<CR>", mode = {"x","o"}, ft = "markdown", desc = " inner md-link" },
		{ "al", "<cmd>lua require('various-textobjs').mdLink('outer')<CR>", mode = {"x","o"}, ft = "markdown", desc = " outer md-link" },

		-- css
		{ "is", "<cmd>lua require('various-textobjs').cssSelector('inner')<CR>", mode = {"x","o"}, ft = "css", desc = " inner selector" },
		{ "as", "<cmd>lua require('various-textobjs').cssSelector('outer')<CR>", mode = {"x","o"}, ft = "css", desc = " outer selector" },

		-- shell
		{ "ix", "<cmd>lua require('various-textobjs').shellPipe('inner')<CR>", mode = "o", ft = {"bash", "zsh"}, desc = "󰟥 inner pipe" },
		{ "ax", "<cmd>lua require('various-textobjs').shellPipe('outer')<CR>", mode = "o", ft = {"bash", "zsh"}, desc = "󰟥 outer pipe" },
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
			"ysii", -- `ysi` would conflict with `ysib` and other textobjs, thus 2nd `i`
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
				local dur = 1500 -- CONFIG
				local ns = vim.api.nvim_create_namespace("ysii")
				local bufnr = vim.api.nvim_get_current_buf()
				vim.hl.range(bufnr, ns, "IncSearch", { startLn, 0 }, { startLn, -1 }, { timeout = dur })
				vim.hl.range(bufnr, ns, "IncSearch", { endLn, 0 }, { endLn, -1 }, { timeout = dur })
			end,
			desc = "󰅍 Yank surrounding indent",
		},
		{ -- open URL (forward seeking)
			"gx",
			function()
				require("various-textobjs").url() -- select URL
				local foundURL = vim.fn.mode() == "v" -- only switches to visual mode when textobj found
				if not foundURL then return end

				local url = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = "v" })[1]
				vim.ui.open(url) -- requires nvim 0.10
				vim.cmd.normal { "v", bang = true } -- leave visual mode
			end,
			desc = " Open next URL",
		},
		{
			"g-",
			function()
				require("various-textobjs").filepath("outer")

				local foundPath = vim.fn.mode() == "v" -- only switches to visual mode when textobj found
				if not foundPath then return end

				local path = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = "v" })[1]
				vim.cmd.normal { "v", bang = true } -- leave visual mode

				local exists = vim.uv.fs_stat(vim.fs.normalize(path)) ~= nil
				if exists then
					vim.ui.open(path)
				else
					vim.notify("Path does not exist.", vim.log.levels.WARN)
				end
			end,
			desc = " Open next path",
		},
	},
}
