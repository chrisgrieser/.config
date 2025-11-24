local bkeymap = require("config.utils").bufKeymap
local optl = vim.opt_local
--------------------------------------------------------------------------------

optl.expandtab = false
optl.tabstop = 4 -- less nesting in md, so we can afford larger tabstop
vim.bo.commentstring = "<!-- %s -->" -- add spaces

-- so two trailing spaces are highlighted, but not a single trailing space
optl.listchars:remove("trail")
optl.listchars:append { multispace = "·" }

-- since markdown has rarely indented lines, and also rarely has overlong lines,
-- move everything a bit more to the right
if vim.bo.buftype == "" then optl.signcolumn = "yes:4" end

--------------------------------------------------------------------------------

-- CYCLE LIST TYPES
bkeymap({ "n", "i" }, "<D-u>", function()
	local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
	local curLine = vim.api.nvim_get_current_line()

	local updated = curLine:gsub("^(%s*)([%p%d x]* )", function(indent, list)
		if list:find("[*+-] ") and not list:find("%- %[") then return indent .. "- [ ] " end -- bullet -> task
		if vim.startswith(list, "- [") then return indent .. "1. " end -- task -> number
		return indent .. "- " -- number/other -> bullet
	end)
	-- none -> bullet
	if updated == curLine then updated = curLine:gsub("^(%s*)(.*)", "%1- %2") end

	vim.api.nvim_set_current_line(updated)
	local diff = #updated - #curLine
	vim.api.nvim_win_set_cursor(0, { lnum, math.max(1, col + diff) })
end, { desc = "󰍔 Cycle list types" })

--------------------------------------------------------------------------------
-- MARKDOWN-SPECIFIC KEYMAPS

-- Tasks
bkeymap("n", "<leader>x", "mzI- [ ] <Esc>`z", { desc = " Add task/checkbox" })

-- Format Table
bkeymap("n", "<leader>rt", "vip:!pandoc --to=gfm<CR>", { desc = " Format table under cursor" })

-- cmd+k: markdown link
bkeymap({ "n", "x", "i" }, "<D-k>", function()
	local mode = vim.fn.mode()
	local title = mode == "n" and vim.fn.expand("<cword>") or ""
	local curLine = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local clipboardUrl = vim.fn.getreg("+"):match([[%l%l%l+://[^%s)%]}"'`>]+]]) or ""
	local insert = ("[%s](%s)"):format(title, clipboardUrl)

	if mode == "n" then
		vim.cmd.normal { '"_ciw' .. insert, bang = true }
		vim.api.nvim_win_set_cursor(0, { row, col })
	elseif mode:find("[Vv]") then
		vim.cmd.normal { '"zy', bang = true }
	elseif mode == "i" then
		local newLine = curLine:sub(1, col) .. insert .. curLine:sub(col + 1)
		vim.api.nvim_set_current_line(newLine)
		vim.api.nvim_win_set_cursor(0, { row, col + 1 })
	end
end, { desc = " Link" })

--------------------------------------------------------------------------------

-- MARKDOWN PREVIEW
bkeymap("n", "<leader>ep", function()
	-- SOURCE https://github.com/sindresorhus/github-markdown-css
	-- (replace `.markdown-body` with `body` and copypaste the first block)
	local css = vim.fn.stdpath("config") .. "/after/ftplugin/github-markdown.css"

	local outputPath = "/tmp/markdown-preview.html"
	vim.cmd("silent! update")

	-- create github-html via pandoc
	-- (alternative: github API https://docs.github.com/en/rest/markdown/markdown)
	vim.system({
		"pandoc",
		"--from=gfm+rebase_relative_paths", -- rebasing, so images are available at output location
		vim.api.nvim_buf_get_name(0),
		"--output=" .. outputPath,
		"--standalone",
		"--css=" .. css,
	}):wait()

	vim.ui.open(outputPath)
end, { desc = " Preview" })
