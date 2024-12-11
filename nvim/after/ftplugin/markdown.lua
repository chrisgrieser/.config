local bkeymap = require("config.utils").bufKeymap
local optl = vim.opt_local
--------------------------------------------------------------------------------

optl.expandtab = false
optl.tabstop = 4 -- less nesting in md
vim.bo.commentstring = "<--! %s -->" -- add spaces

-- so two trailing spaces highlighted, but not a single trailing space
optl.listchars:remove("trail")
optl.listchars:append { multispace = "·" }

-- since markdown has rarely indented lines, and also rarely has overlong lines,
-- move everything a bit more to the right
if vim.bo.buftype == "" then optl.signcolumn = "yes:4" end

--------------------------------------------------------------------------------

-- make bullets auto-continue (replaces bullets.vim)
-- INFO cannot set opt.comments permanently, since it disturbs the
-- correctly indented continuation of bullet lists when hitting opt.textwidth
optl.formatoptions:append("r") -- `<CR>` in insert mode
optl.formatoptions:append("o") -- `o` in normal mode

local function autocontinue(key)
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

bkeymap("n", "o", function() return autocontinue("o") end, { expr = true })
bkeymap("i", "<CR>", function() return autocontinue("<CR>") end, { expr = true })

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
-- MARKDOWN PREVIEW
-- (replaces markdown-preview.nvim)
bkeymap("n", "<leader>er", function()
	-- CONFIG
	local outputPath = "/tmp/markdown-preview.html"
	local browser = "Brave Browser"
	local css = vim.fn.stdpath("config") .. "/after/ftplugin/github-markdown.css"

	-- create github-html via pandoc
	vim.cmd.update { mods = { silent = true } }
	local input = vim.api.nvim_buf_get_name(0)
	vim.system({
		"pandoc",
		-- rebasing paths, so images are available at output location
		"--from=gfm+rebase_relative_paths",
		input,
		"--output=" .. outputPath,
		"--standalone",
		"--css=" .. css,
	}):wait()

	-- determine the heading above cursor, to scroll to it
	local heading
	local curLine = vim.api.nvim_win_get_cursor(0)[1]
	for i = curLine - 1, 1, -1 do
		local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
		heading = line:match("^#+ (.*)")
		if heading then break end
	end
	local anchor = heading and "#" .. heading:lower():gsub(" ", "-") or ""
	local url = "file://" .. outputPath .. anchor

	-- macOS-specific part: open file and refresh
	-- * cannot use shell's `open` as it does not work with anchors
	-- * closing tab to ensure it's correctly refreshed
	local applescript = ([[
		tell application %q
		if (front window exists) then
		repeat with the_tab in (every tab in front window)
		set the_url to the url of the_tab
		if the_url contains (%q) then close the_tab
		end repeat
		end if
		open location %q
		end tell
	]]):format(browser, outputPath, url)
	vim.system { "osascript", "-e", applescript }
end, { desc = " Preview" })
