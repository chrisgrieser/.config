local bkeymap = require("config.utils").bufKeymap
local optl = vim.opt_local
--------------------------------------------------------------------------------

optl.expandtab = false
optl.tabstop = 4 -- less nesting in md, so we can afford larger tabstop
vim.bo.commentstring = "<--! %s -->" -- add spaces

-- so two trailing spaces highlighted, but not a single trailing space
optl.listchars:remove("trail")
optl.listchars:append { multispace = "·" }

-- since markdown has rarely indented lines, and also rarely has overlong lines,
-- move everything a bit more to the right
if vim.bo.buftype == "" then optl.signcolumn = "yes:4" end

--------------------------------------------------------------------------------
-- AUTO BULLETS
-- (simplified implementation of `bullets.vim`)
local function autoBullet()
	local line = vim.api.nvim_get_current_line()
	local lnum = vim.api.nvim_win_get_cursor(0)[1]
	local indentAndPrefix = ""
	local pointTo = lnum

	while true do
		indentAndPrefix = line:match("^%s*>+ ") -- blockquotes & callouts
			or line:match("^%s*%d+[.)] ") --------- ordered list
			or line:match("^%s*[-*+] ") ----------- unordered list
			or line:match("^%s*%- %[[x ]%] ") ----- task
			or line:match("^%s*") ----------------- just indent

		-- in case of multi-line bullets in hardwrapped text, the prefix we
		-- actually want to use is further up
		if not vim.endswith(indentAndPrefix, "  ") then break end
		pointTo = pointTo - 1
		if pointTo < 1 then break end
		line = vim.api.nvim_buf_get_lines(0, pointTo, pointTo + 1, false)[1]
	end

	indentAndPrefix = indentAndPrefix
		:gsub("%d+", function(n) return tostring(tonumber(n) + 1) end) -- increment ordered list
		:gsub("%[x%]", "[ ]") -- new tasks should be open

	vim.api.nvim_buf_set_lines(0, lnum, lnum, true, { indentAndPrefix })
	vim.api.nvim_win_set_cursor(0, { lnum + 1, #indentAndPrefix })
	vim.cmd.startinsert { bang = true }
end

bkeymap("i", "<CR>", function() autoBullet() end, { desc = "󰉹 Auto-bullet" })
bkeymap("n", "o", function() autoBullet() end, { desc = "󰉹 Auto-bullet" })

--------------------------------------------------------------------------------
-- HEADINGS

-- Jump to next/prev heading (`##` to skip level 1 and comments in code-blocks)
bkeymap("n", "<C-j>", [[/^##\+ .*<CR>]], { desc = " Next heading" })
bkeymap("n", "<C-k>", [[?^##\+ .*<CR>]], { desc = " Prev heading" })

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

-- <D-h> remapped to <D-ö>, PENDING https://github.com/neovide/neovide/issues/2558
bkeymap("n", "<D-ö>", function() headingsIncremantor(1) end, { desc = " Increment heading" })
bkeymap("n", "<D-H>", function() headingsIncremantor(-1) end, { desc = " Decrement heading" })

--------------------------------------------------------------------------------
-- MARKDOWN-SPECIFIC KEYMAPS

-- Tasks
bkeymap("n", "<leader>x", "mzI- [ ] <Esc>`z", { desc = " Add Task" })

-- Format Table
bkeymap("n", "<leader>ft", "vip:!pandoc --to=gfm<CR>", { desc = " Format table under cursor" })

-- cmd+u: markdown bullet
bkeymap("n", "<D-u>", "mzI- <Esc>`z", { desc = "• Bullet list" })

-- cmd+k: markdown link
bkeymap("n", "<D-k>", "bi[<Esc>ea]()<Esc>hp", { desc = " Link" })
bkeymap("x", "<D-k>", "<Esc>`<i[<Esc>`>la]()<Esc>hp", { desc = " Link" })
bkeymap("i", "<D-k>", "[]()<Left><Left><Left>", { desc = " Link" })

-- cmd+b: bold
bkeymap("n", "<D-b>", "bi**<Esc>ea**<Esc>", { desc = " Bold" })
bkeymap("i", "<D-b>", "****<Left><Left>", { desc = " Bold" })
bkeymap("x", "<D-b>", "<Esc>`<i**<Esc>`>lla**<Esc>", { desc = " Bold" })

-- cmd+i: italics
bkeymap("n", "<D-i>", "bi*<Esc>ea*<Esc>", { desc = " Italics" })
bkeymap("i", "<D-i>", "**<Left>", { desc = " Italics" })
bkeymap("x", "<D-i>", "<Esc>`<i*<Esc>`>la*<Esc>", { desc = " Italics" })

--------------------------------------------------------------------------------

-- MARKDOWN PREVIEW (simplified version of markdown-preview.nvim)
bkeymap("n", "<leader>er", function()
	local outputPath = "/tmp/markdown-preview.html"
	local css = vim.fn.stdpath("config") .. "/after/ftplugin/github-markdown.css"

	-- create github-html via pandoc
	vim.cmd("silent update")
	vim.system({
		"pandoc",
		-- rebasing paths, so images are available at output location
		"--from=gfm+rebase_relative_paths",
		vim.api.nvim_buf_get_name(0),
		"--output=" .. outputPath,
		"--standalone",
		"--css=" .. css,
	}):wait()

	local uri = "file://" .. outputPath
	vim.ui.open(uri)
end, { desc = " Preview" })
