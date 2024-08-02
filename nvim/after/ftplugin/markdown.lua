local keymap = vim.keymap.set
local optl = vim.opt_local
--------------------------------------------------------------------------------

optl.expandtab = false
optl.tabstop = 4 -- less nesting in md

-- so two trailing spaces highlighted, but not a single trailing space
optl.listchars:remove("trail")
optl.listchars:append { multispace = "·" }

-- since markdown has rarely indented lines, and also rarely has overlong lines,
-- move everything a bit more to the right
if vim.bo.buftype == "" then optl.signcolumn = "yes:3" end

--------------------------------------------------------------------------------

-- make bullets auto-continue (replaces bullets.vim)
-- INFO cannot set opt.comments permanently, since it disturbs the
-- correctly indented continuation of bullet lists when hitting opt.textwidth
optl.formatoptions:append("r") -- `<CR>` in insert mode
optl.formatoptions:append("o") -- `o` in normal mode

local function autocontinue(key)
	local comBefore = optl.comments:get()
	optl.comments = {
		"b:- [ ]", -- tasks
		"b:- [x]",
		"b:\t* [ ]",
		"b:\t* [x]",
		"b:*", -- unordered list
		"b:-",
		"b:+",
		"b:\t*", -- indented unordered list
		"b:\t-",
		"b:\t+",
		"b:1.", -- ordered list
		"b:\t1.", -- indented ordered list
		"n:>", -- blockquotes
	}
	vim.defer_fn(function() optl.comments = comBefore end, 1) -- deferred to restore only after return
	return key
end

keymap("n", "o", function() return autocontinue("o") end, { buffer = true, expr = true })
keymap("i", "<CR>", function() return autocontinue("<CR>") end, { buffer = true, expr = true })

--------------------------------------------------------------------------------
-- Markdown Preview (replaces markdown-preview.nvim)
keymap("n", "<D-r>", function()
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
end, { desc = " Preview", buffer = true })

--------------------------------------------------------------------------------
-- HEADINGS

-- Jump to next/prev heading
keymap("n", "<C-j>", [[/^#\+ .*<CR>]], { desc = " Next Heading", buffer = true, silent = true })
keymap("n", "<C-k>", [[?^#\+ .*<CR>]], { desc = " Prev Heading", buffer = true, silent = true })

--------------------------------------------------------------------------------
-- MARKDOWN-SPECIFIC KEYMAPS

keymap("n", "<leader>x", "mzI- [ ] <Esc>`z", { desc = " Add Task", buffer = true })

-- Format Table
keymap(
	"n",
	"<leader>ft",
	"vip:!pandoc --to=gfm<CR>",
	{ desc = " Format Table under Cursor", buffer = true, silent = true }
)

-- convert md image to html image
keymap("n", "<leader>fi", function()
	local line = vim.api.nvim_get_current_line()
	local htmlImage = line:gsub("!%[(.-)%]%((.-)%)", '<img src="%2" alt="%1" width=70%%>')
	vim.api.nvim_set_current_line(htmlImage)
end, { desc = " MD image to <img>", buffer = true })

--------------------------------------------------------------------------------
-- GUI KEYBINDINGS

-- cmd+u: markdown bullet
keymap("n", "<D-u>", "mzI- <Esc>`z", { desc = "• Bullet List", buffer = true })

-- cmd+k: markdown link
keymap("n", "<D-k>", "bi[<Esc>ea]()<Esc>hp", { desc = " Link", buffer = true })
keymap("x", "<D-k>", "<Esc>`<i[<Esc>`>la]()<Esc>hp", { desc = " Link", buffer = true })
keymap("i", "<D-k>", "[]()<Left><Left><Left>", { desc = " Link", buffer = true })

-- cmd+b: bold
keymap("n", "<D-b>", "mzbi**<Esc>ea**<Esc>`zll", { desc = " Bold", buffer = true })
keymap("x", "<D-b>", "<Esc>`<i**<Esc>`>lla**<Esc>", { desc = " Bold", buffer = true })
keymap("i", "<D-b>", "****<Left><Left>", { desc = " Bold", buffer = true })

-- cmd+i: italics
keymap("n", "<D-i>", "mzbi*<Esc>ea*<Esc>`zl", { desc = " Italics", buffer = true })
keymap("x", "<D-i>", "<Esc>`<i*<Esc>`>la*<Esc>", { desc = " Italics", buffer = true })
keymap("i", "<D-i>", "**<Left>", { desc = " Italics", buffer = true })
