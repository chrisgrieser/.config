local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------

-- OPTIONS
vim.opt.clipboard = "unnamedplus"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "User: Highlighted Yank",
	callback = function() vim.highlight.on_yank { timeout = 1000 } end,
})

-- STICKY YANK
local cursorPreYank
keymap({ "n", "x" }, "y", function()
	cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y"
end, { desc = "Sticky yank", expr = true })
keymap("n", "Y", function()
	cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y$"
end, { desc = "󰅍 Sticky yank", expr = true, unique = false })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "User: Sticky yank",
	callback = function()
		if vim.v.event.regname == "z" then return end -- used as temp register for keymaps
		if vim.v.event.operator == "y" then vim.api.nvim_win_set_cursor(0, cursorPreYank) end
	end,
})

-- KEEP THE REGISTER CLEAN
keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P", { desc = " Paste w/o switching with register" })
keymap("n", "dd", function()
	if vim.api.nvim_get_current_line():find("^%s*$") then return '"_dd' end
	return "dd"
end, { expr = true, desc = "dd" })

-- PASTING
keymap("n", "P", function()
	local curLine = vim.api.nvim_get_current_line():gsub("%s*$", "")
	local reg = vim.fn.getreg("+"):gsub("^ *", "")
	vim.api.nvim_set_current_line(curLine .. " " .. reg)
end, { desc = " Sticky paste at EoL" })

keymap("i", "<D-v>", function()
	local reg = vim.trim(vim.fn.getreg("+")):gsub("\n%s*$", "\n") -- remove indentation if multi-line
	vim.fn.setreg("+", reg, "v")
	return "<C-g>u<C-r><C-o>+" -- `<C-g>u` adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

-- for compatibility with macOS clipboard managers
keymap("n", "<D-v>", "p", { desc = " Paste" })

--------------------------------------------------------------------------------
-- SPECIAL YANKING OPERATIONS

keymap("n", "<leader>yl", function()
	-- not using `:glocal // yank` because it yanks lines one after the other
	vim.ui.input({ prompt = "󰅍 Yank lines matching:" }, function(input)
		if not input then return end
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local matchLines = vim.tbl_filter(function(line) return line:find(input, 1, true) end, lines)
		vim.fn.setreg("+", table.concat(matchLines, "\n"))
		local pluralS = #matchLines == 1 and "" or "s"
		local msg = ("%d line%s"):format(#matchLines, pluralS)
		vim.notify(msg, nil, { title = "Copied", icon = "󰅍" })
	end)
end, { desc = "󰅍 Matching lines" })

keymap("n", "<leader>yb", function()
	local codeContext = require("nvim-treesitter").statusline {
		indicator_size = math.huge, -- disable shortening
		type_patterns = { "class", "function", "method", "field", "pair" }, -- `pair` for yaml/json
		separator = ".",
	}
	if codeContext and codeContext ~= "" then
		codeContext = codeContext:gsub(" ?[:=][^:=]-$", ""):gsub(" ?= ?", "")
		vim.fn.setreg("+", codeContext)
		vim.notify(codeContext, nil, { title = "Copied", icon = "󰅍", ft = vim.bo.ft })
	else
		vim.notify("No code context.", vim.log.levels.WARN)
	end
end, { desc = "󰅍 Breadcrumbs" })

-- requires a `nvim-scissors` util function
-- (which I use as dependency since it's my own plugin)
keymap("x", "<leader>yc", function()
	local mode = vim.fn.mode()
	if not mode:find("[Vv]") then
		vim.notify("Must be in visual line mode.", vim.log.levels.WARN)
		return
	end

	vim.cmd.normal { mode, bang = true } -- leave visual mode, so marks are set
	local start = vim.api.nvim_buf_get_mark(0, "<")[1]
	local _end = vim.api.nvim_buf_get_mark(0, ">")[1]
	local lines = vim.api.nvim_buf_get_lines(0, start - 1, _end, false)

	lines = require("scissors.utils").dedentAndTrimBlanks(lines)
	table.insert(lines, 1, "```" .. vim.bo.filetype)
	table.insert(lines, "```")

	vim.fn.setreg("+", table.concat(lines, "\n"))
	local pluralS = #lines == 1 and "" or "s"
	local msg = ("%d line%s"):format(#lines - 2, pluralS)
	vim.notify(msg, nil, { title = "Copied", icon = "󰅍" })
end, { desc = "󰅍 codeblock (markdown)" })
