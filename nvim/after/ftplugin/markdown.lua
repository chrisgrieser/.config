local keymap = vim.keymap.set
local optl = vim.opt_local
local u = require("config.utils")
local fn = vim.fn
--------------------------------------------------------------------------------

-- less nesting in md
optl.tabstop = 4

-- Enable wrapping lines
require("funcs.quality-of-life").wrap("on")

-- decrease line length without zen mode plugins
if vim.bo.buftype == "" then optl.signcolumn = "yes:9" end

-- do not auto-wrap text
optl.formatoptions:remove { "t", "c" }

-- hide links and some markup (similar to Obsidian's live preview)
optl.conceallevel = 2

--------------------------------------------------------------------------------
-- MARKDOWN-SPECIFIC KEYMAPS

-- stylua: ignore
keymap("n", "gs", function ()
	require("telescope.builtin").lsp_document_symbols {
		ignore_symbols = {}, -- do not ignore type "string", since that's what headings in md are
		prompt_title = "Headings",
	}
end, { desc = "󰒕 Markdown Headings", buffer = true })

keymap("n", "<leader>x", "mzI- [ ] <Esc>`z", { desc = " Add Task", buffer = true })
keymap("n", "<leader>-", "mzI- <Esc>`z", { desc = " Add List", buffer = true })

-- Format Table
keymap(
	"n",
	"<localleader>f",
	"vip:!pandoc -t commonmark_x<CR><CR>",
	{ desc = " Format Table under Cursor", buffer = true }
)

-- convert md image to html image
keymap("n", "<localleader>i", function()
	local line = vim.api.nvim_get_current_line()
	local htmlImage = line:gsub("!%[(.-)%]%((.-)%)", '<img src="%2" alt="%1" width=70%%>')
	vim.api.nvim_set_current_line(htmlImage)
end, { desc = "  MD image to <img>", buffer = true })

-- searchlink / ddgr
keymap({ "n", "x" }, "<localleader>k", function()
	local query
	if fn.mode() == "n" then
		u.normal([["zciw]])
	else
		u.normal([["zc]])
	end
	query = fn.getreg("z")
	local jsonResponse = fn.system(("ddgr --num=1 --json '%s'"):format(query))
	local link = vim.json.decode(jsonResponse)[1].url
	local mdlink = ("[%s](%s)"):format(query, link)
	fn.setreg("z", mdlink)
	u.normal([["zP]])
end, { desc = " SearchLink (ddgr)", buffer = true })

--------------------------------------------------------------------------------

-- Heading jump to next/prev heading
keymap(
	{ "n", "x" },
	"<C-j>",
	[[/^#\+ <CR><cmd>nohl<CR>]],
	{ desc = " Next Heading", buffer = true }
)
keymap(
	{ "n", "x" },
	"<C-k>",
	[[?^#\+ <CR><cmd>nohl<CR>]],
	{ desc = " Prev Heading", buffer = true }
)

--------------------------------------------------------------------------------
-- GUI KEYBINDINGS

-- cmd+k: markdown link
keymap("n", "<D-k>", "bi[<Esc>ea]()<Esc>hp", { desc = "  Link", buffer = true })
keymap("x", "<D-k>", "<Esc>`<i[<Esc>`>la]()<Esc>hp", { desc = "  Link", buffer = true })
keymap("i", "<D-k>", "[]()<Left><Left><Left>", { desc = "  Link", buffer = true })

-- cmd+b: bold
keymap("n", "<D-b>", "bi__<Esc>ea**<Esc>", { desc = "  Bold", buffer = true })
keymap("x", "<D-b>", "<Esc>`<i**<Esc>`>lla**<Esc>", { desc = "  Bold", buffer = true })
keymap("i", "<D-b>", "****<Left><Left>", { desc = "  Bold", buffer = true })

-- cmd+i: italics
keymap("n", "<D-i>", "bi*<Esc>ea*<Esc>", { desc = "  Italics", buffer = true })
keymap("x", "<D-i>", "<Esc>`<i*<Esc>`>la*<Esc>", { desc = "  Italics", buffer = true })
keymap("i", "<D-i>", "**<Left>", { desc = "  Italics", buffer = true })
