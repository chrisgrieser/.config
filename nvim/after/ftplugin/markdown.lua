local keymap = vim.keymap.set
local optl = vim.opt_local
--------------------------------------------------------------------------------

-- less nesting in md
optl.tabstop = 4

-- Enable wrapping lines
optl.wrap = true
optl.colorcolumn = ""
keymap("n", "A", "g$a", { buffer = true })
keymap("n", "I", "g^i", { buffer = true })

-- decrease line length without zen mode plugins
-- filetype condition ensure ssub-filtypes like "markdown.cody_history" are not affected
if vim.bo.ft == "markdown" then optl.signcolumn = "yes:9" end

-- do not auto-wrap text
optl.formatoptions:remove { "t", "c" }

-- hide links and some markup (similar to Obsidian's live preview)
optl.conceallevel = 2

-- off, since using vale & ltex here
optl.spell = false

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
