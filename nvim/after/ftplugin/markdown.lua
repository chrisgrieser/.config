local keymap = vim.keymap.set
local optl = vim.opt_local
local u = require("config.utils")
local fn = vim.fn
--------------------------------------------------------------------------------

optl.expandtab = false
optl.tabstop = 4 -- less nesting in md

-- since markdown has rarely indented lines, and also rarely overlength in lines,
-- move everything a bit more to the right
if vim.bo.buftype == "" then optl.signcolumn = "yes:3" end

--------------------------------------------------------------------------------
-- HEADING navigation (instead of symbols)

-- stylua: ignore
vim.keymap.set("n", "gs", function ()
	require("telescope.builtin").lsp_document_symbols {
		prompt_title = "Headings",
		symbols = "string", -- lsp considers headings as symbol-kind "string"
	}
end, { desc = " Headings", buffer = true })

-- Jump to next/prev heading
keymap({ "n", "x" }, "<C-j>", [[/^#\+ .*<CR>]], { desc = " Next Heading", buffer = true })
keymap({ "n", "x" }, "<C-k>", [[?^#\+ .*<CR>]], { desc = " Prev Heading", buffer = true })

--------------------------------------------------------------------------------
-- MARKDOWN-SPECIFIC KEYMAPS
keymap("n", "<leader>x", "mzI- [ ] <Esc>`z", { desc = " Add Task", buffer = true })
keymap("n", "<D-4>", "mzI- <Esc>`z", { desc = " Add List", buffer = true })

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
	u.normal(fn.mode() == "n" and '"zciw' or '"zc')
	query = fn.getreg("z")
	local jsonResponse = fn.system(("ddgr --num=1 --json '%s'"):format(query))
	local link = vim.json.decode(jsonResponse)[1].url
	local mdlink = ("[%s](%s)"):format(query, link)
	fn.setreg("z", mdlink)
	u.normal('"zP')
end, { desc = " SearchLink (ddgr)", buffer = true })

--------------------------------------------------------------------------------
-- GUI KEYBINDINGS

-- cmd+u: markdown link
keymap("n", "<D-u>", "mzI- <Esc>`z", { desc = " Bullet List", buffer = true })

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
