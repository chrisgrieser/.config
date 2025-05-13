local bkeymap = require("config.utils").bufKeymap
local optl = vim.opt_local
--------------------------------------------------------------------------------

optl.expandtab = false
optl.tabstop = 4 -- less nesting in md, so we can afford larger tabstop
vim.bo.commentstring = "<!-- %s -->" -- add spaces

-- so two trailing spaces highlighted, but not a single trailing space
optl.listchars:remove("trail")
optl.listchars:append { multispace = "·" }

-- since markdown has rarely indented lines, and also rarely has overlong lines,
-- move everything a bit more to the right
if vim.bo.buftype == "" then optl.signcolumn = "yes:4" end

--------------------------------------------------------------------------------
-- AUTO BULLETS
-- (simplified implementation of `bullets.vim`)

-- INFO cannot set opt.comments permanently, since it disturbs the
-- correctly indented continuation of bullet lists when hitting `opt.textwidth`
optl.formatoptions:append("r") -- `<CR>` in insert mode
optl.formatoptions:append("o") -- `o` in normal mode

local function autoBullet(key)
	local comBefore = optl.comments:get()
	-- stylua: ignore
	optl.comments = {
		"b:- [ ]", "b:- [x]", "b:\t* [ ]", "b:\t* [x]", -- tasks
		"b:*", "b:-", "b:+", "b:\t*", "b:\t-", "b:\t+", -- unordered list
		"b:1.", "b:\t1.", -- ordered list
		"n:>", -- blockquotes
	}
	vim.defer_fn(function() optl.comments = comBefore end, 1) -- deferred to restore only after return
	return key
end

bkeymap("n", "o", function() return autoBullet("o") end, { expr = true })
bkeymap("i", "<CR>", function() return autoBullet("<CR>") end, { expr = true })

--------------------------------------------------------------------------------
-- HEADINGS

-- Jump to next/prev heading (`##` to skip level 1 and comments in code-blocks)
bkeymap("n", "<C-j>", [[/^##\+ .*<CR>]], { desc = " Next heading" })
bkeymap("n", "<C-k>", [[?^##\+ .*<CR>]], { desc = " Prev heading" })

---@param dir 1|-1
local function headingsIncremantor(dir)
	local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
	local curLine = vim.api.nvim_get_current_line()

	local updated = curLine:gsub("^#* ", function(match)
		if dir == -1 and match ~= "# " then return match:sub(2) end
		if dir == 1 and match ~= "###### " then return "#" .. match end
		return ""
	end)
	if updated == curLine then updated = (dir == 1 and "## " or "###### ") .. curLine end

	vim.api.nvim_set_current_line(updated)
	local diff = #updated - #curLine
	vim.api.nvim_win_set_cursor(0, { lnum, col + diff })
end

-- <D-h> remapped to <D-5>, since used by macOS PENDING https://github.com/neovide/neovide/issues/3099
bkeymap("n", "<D-5>", function() headingsIncremantor(1) end, { desc = " Increment heading" })
bkeymap("n", "<D-H>", function() headingsIncremantor(-1) end, { desc = " Decrement heading" })

--------------------------------------------------------------------------------

-- cycle list types
bkeymap("n", "<D-u>", function()
	local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
	local curLine = vim.api.nvim_get_current_line()

	local updated = curLine:gsub("^(%s*)([%p%d x]* )", function(ind, l)
		if l:find("[*+-] ") and not l:find("%- %[") then return ind .. "1. " end -- list -> ordered
		if l:find("%d") then return ind .. "- [ ] " end -- ordered -> open task
		if vim.startswith(l, "- [") then return ind .. "> " end -- task -> blockquote
		if l:find(">") and ind ~= "" then
			local indentLevel = ind:gsub((" "):rep(vim.bo.shiftwidth), "\t"):len()
			local listChars = { "-", "*", "+" }
			local char = listChars[indentLevel % #listChars + 1]
			return ind .. char .. " "
		end -- indented: blockquote -> list
		if l:find(">") and ind == "" then return "" end -- unindented: blockquote -> none
		return "" -- no list type
	end)
	if updated == curLine then updated = "- " .. curLine end -- none -> list

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
bkeymap("n", "<D-k>", "bi[<Esc>ea]()<Esc>hp", { desc = " Link" })
bkeymap("x", "<D-k>", "<Esc>`<i[<Esc>`>la]()<Esc>hp", { desc = " Link" })
bkeymap("i", "<D-k>", "[]()<Left><Left><Left>", { desc = " Link" })

-- cmd+b: bold
bkeymap("n", "<D-b>", "bi**<Esc>ea**<Esc>", { desc = " Bold" })
bkeymap("i", "<D-b>", "****<Left><Left>", { desc = " Bold" })
bkeymap("x", "<D-b>", "<Esc>`<i**<Esc>`>lla**<Esc>", { desc = " Bold" })

-- cmd+i: italics
bkeymap("n", "<D-i>", "bi*<Esc>ea*<Esc>", { desc = " Italics" })
bkeymap("i", "<D-i>", "**<Left>", { desc = " Italics" })
bkeymap("x", "<D-i>", "<Esc>`<i*<Esc>`>la*<Esc>", { desc = " Italics" })

--------------------------------------------------------------------------------

-- MARKDOWN PREVIEW
bkeymap("n", "<leader>ep", function()
	-- SOURCE https://github.com/sindresorhus/github-markdown-css
	-- (replace `.markdown-body` with `body` and copypaste the first block)
	local css = vim.fn.stdpath("config") .. "/after/ftplugin/github-markdown.css"
	local outputPath = "/tmp/markdown-preview.html"
	vim.cmd("silent update")

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
