local keymap = vim.keymap.set
local fn = vim.fn
local u = require("config.utils")
--------------------------------------------------------------------------------

-- less nesting in md
vim.opt_local.tabstop = 4

-- Enable wrapping lines
vim.opt_local.wrap = true
vim.opt_local.colorcolumn = ""
keymap("n", "A", "g$a", { buffer = true })
keymap("n", "I", "g^i", { buffer = true })

-- decrease line length without zen mode plugins
-- filetype condition ensure ssub-filtypes like "markdown.cody_history" are not affected
if vim.bo.ft == "markdown" then vim.opt_local.signcolumn = "yes:9" end

-- do not auto-wrap text
vim.opt_local.formatoptions:remove { "t", "c" }

-- hide links and some markup (similar to Obsidian's live preview)
vim.opt_local.conceallevel = 2

--------------------------------------------------------------------------------
-- MARKDOWN-SPECIFIC KEYMAPS

-- Build / Preview
keymap(
	"n",
	"<localleader><localleader>",
	"<Plug>MarkdownPreview",
	{ desc = " Preview", buffer = true }
)

-- Format Table
keymap(
	"n",
	"<localleader>f",
	"vip:!pandoc -t commonmark_x<CR><CR>",
	{ desc = "  Format Table under Cursor", buffer = true }
)

-- convert md image to html image
keymap("n", "<localleader>i", function()
	local line = vim.api.nvim_get_current_line()
	local htmlImage = line:gsub("!%[(.-)%]%((.-)%)", '<img src="%2" alt="%1" width=70%%>')
	vim.api.nvim_set_current_line(htmlImage)
end, { desc = "  MD image to <img>", buffer = true })

-- stylua: ignore start
-- link textobj
keymap({ "o", "x" }, "il", "<cmd>lua require('various-textobjs').mdlink('inner')<CR>", { desc = "󱡔 inner md link", buffer = true })
keymap({ "o", "x" }, "al", "<cmd>lua require('various-textobjs').mdlink('outer')<CR>", { desc = "󱡔 outer md link", buffer = true })

-- iE/aE: code block textobj
keymap({ "o", "x" }, "iE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('inner')<CR>", { desc = "󱡔 inner code block", buffer = true })
keymap({ "o", "x" }, "aE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('outer')<CR>", { desc = "󱡔 outer code block", buffer = true })

-- Heading jump to next/prev heading
keymap({ "n", "x" }, "<C-j>", [[/^#\+ <CR><cmd>nohl<CR>]], { desc = " # Next Heading", buffer = true })
keymap({ "n", "x" }, "<C-k>", [[?^#\+ <CR><cmd>nohl<CR>]], { desc = " # Prev Heading", buffer = true })
-- stylua: ignore end

--------------------------------------------------------------------------------
-- SPELLING

-- [z]pelling [l]ist
keymap("n", "zl", function() vim.cmd.Telescope("spell_suggest") end, { desc = "󰓆 Spell Suggest" })
keymap("n", "z.", "1z=", { desc = "󰓆 Fix Spelling" })

---add word under cursor to vale/languagetool dictionary
keymap({ "n", "x" }, "zg", function()
	local word
	if fn.mode() == "n" then
		local iskeywBefore = vim.opt_local.iskeyword:get() -- remove word-delimiters for <cword>
		vim.opt_local.iskeyword:remove { "_", "-", "." }
		word = fn.expand("<cword>")
		vim.opt_local.iskeyword = iskeywBefore
	else
		u.normal('"zy')
		word = fn.getreg("z")
	end
	local filepath = u.linterConfigFolder .. "/dictionary-for-vale-and-languagetool.txt"
	local error = u.writeToFile(filepath, word, "a")
	local msg = error and "󰓆 Error: " .. error or "󰓆 Added: " .. word
	vim.notify(msg)
end, { desc = "󰓆 Accept Word", buffer = true })

local lang = "de-DE"
keymap("n", "zd", function()
	local clients = vim.lsp.buf_get_clients(0)
	for _, client in ipairs(clients) do
		if client.name == "ltex" then
			vim.notify("󰓆 ltex language set to " .. lang)
			client.config.settings.ltex.language = lang
			vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = client.config.settings })
			return
		end
	end
end, { desc = "󰓆 Set ltex language to " .. lang, buffer = true })

--------------------------------------------------------------------------------
-- GUI KEYBINDINGS

-- cmd+k: markdown link
keymap("n", "<D-k>", "bi[<Esc>ea]()<Esc>hp", { desc = "  Link", buffer = true })
keymap("x", "<D-k>", "<Esc>`<i[<Esc>`>la]()<Esc>hp", { desc = "  Link", buffer = true })
keymap("i", "<D-k>", "[]()<Left><Left><Left>", { desc = "  Link", buffer = true })

-- cmd+b: bold
keymap("n", "<D-b>", "bi__<Esc>ea__<Esc>", { desc = "  Bold", buffer = true })
keymap("x", "<D-b>", "<Esc>`<i__<Esc>`>lla__<Esc>", { desc = "  Bold", buffer = true })
keymap("i", "<D-b>", "____<Left><Left>", { desc = "  Bold", buffer = true })

-- cmd+i: italics
keymap("n", "<D-i>", "bi*<Esc>ea*<Esc>", { desc = "  Italics", buffer = true })
keymap("x", "<D-i>", "<Esc>`<i*<Esc>`>la*<Esc>", { desc = "  Italics", buffer = true })
keymap("i", "<D-i>", "**<Left>", { desc = "  Italics", buffer = true })
