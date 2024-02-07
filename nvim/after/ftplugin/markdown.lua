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

-- make bullets auto-continue
-- replaces bullets.vim https://www.reddit.com/r/vim/comments/otpr29/how_do_you_get_vim_to_automatically_continue_a/
-- INFO cannot set opt.comments permanently, since it disturbs the
-- correctly indented continuation of bullet lists when hitting opt.textwidth
optl.formatoptions:append("r") -- `<CR>` in insert mode
optl.formatoptions:append("o") -- `o` in normal mode

local function autocontinue(key)
	local comBefore = optl.comments:get()
	optl.comments = {
		"b:- [ ]", -- tasks
		"b:- [x]",
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
	local input = vim.api.nvim_buf_get_name(0)
	local output = "/tmp/markdown-preview.html"
	local githubCssPath = os.getenv("HOME") .. "/.config/pandoc/css/github-markdown.css"
	vim.fn.system {
		"pandoc",
		"--from=gfm", -- gfm = GitHub Flavored Markdown
		input,
		"--output=" .. output,
		"--standalone",
		"--css=" .. githubCssPath,
	}
	vim.fn.system { "open", output } -- macOS open command
end, { desc = " Preview", buffer = true })

--------------------------------------------------------------------------------
-- MARKDOWN-SPECIFIC KEYMAPS

-- Jump to next/prev heading
keymap({ "n", "x" }, "<C-j>", [[/^#\+ .*<CR>]], { desc = " Next Heading", buffer = true, silent = true })
keymap({ "n", "x" }, "<C-k>", [[?^#\+ .*<CR>]], { desc = " Prev Heading", buffer = true, silent = true })

keymap("n", "<leader>x", "mzI- [ ] <Esc>`z", { desc = " Add Task", buffer = true })
keymap("n", "<D-4>", "mzI- <Esc>`z", { desc = " Add List", buffer = true })

-- Format Table
keymap(
	"n",
	"<localleader>f",
	"vip:!pandoc -t commonmark_x<CR>",
	{ desc = " Format Table under Cursor", buffer = true, silent = true }
)

-- convert md image to html image
keymap("n", "<localleader>i", function()
	local line = vim.api.nvim_get_current_line()
	local htmlImage = line:gsub("!%[(.-)%]%((.-)%)", '<img src="%2" alt="%1" width=70%%>')
	vim.api.nvim_set_current_line(htmlImage)
end, { desc = "  MD image to <img>", buffer = true })

--------------------------------------------------------------------------------
-- GUI KEYBINDINGS

-- cmd+u: markdown bullet
keymap("n", "<D-u>", "mzI- <Esc>`z", { desc = " Bullet List", buffer = true })

-- cmd+c: CodeBlock
keymap("n", "<D-c>", function()
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { "```", "```", "" })
	-- insert mode at language block
	vim.api.nvim_win_set_cursor(0, { ln + 1, 0 })
	vim.cmd.startinsert { bang = true }
end, { desc = " Code Block", buffer = true })

-- cmd+k: markdown link
keymap("n", "<D-k>", "bi[<Esc>ea]()<Esc>hp", { desc = "  Link", buffer = true })
keymap("x", "<D-k>", "<Esc>`<i[<Esc>`>la]()<Esc>hp", { desc = "  Link", buffer = true })
keymap("i", "<D-k>", "[]()<Left><Left><Left>", { desc = "  Link", buffer = true })

-- cmd+b: bold
keymap("n", "<D-b>", "bi**<Esc>ea**<Esc>", { desc = "  Bold", buffer = true })
keymap("x", "<D-b>", "<Esc>`<i**<Esc>`>lla**<Esc>", { desc = "  Bold", buffer = true })
keymap("i", "<D-b>", "****<Left><Left>", { desc = "  Bold", buffer = true })

-- cmd+i: italics
keymap("n", "<D-i>", "bi*<Esc>ea*<Esc>", { desc = "  Italics", buffer = true })
keymap("x", "<D-i>", "<Esc>`<i*<Esc>`>la*<Esc>", { desc = "  Italics", buffer = true })
keymap("i", "<D-i>", "**<Left>", { desc = "  Italics", buffer = true })
