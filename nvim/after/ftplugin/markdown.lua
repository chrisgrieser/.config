local keymap = vim.keymap.set
local fn = vim.fn
local u = require("config.utils")
--------------------------------------------------------------------------------

-- Enable wrapping lines
-- needs to be wrapped in a condition, probably due to some recursion thing
vim.opt_local.wrap = true
vim.opt_local.colorcolumn = ""
keymap("n", "A", "g$a", { buffer = true })
keymap("n", "I", "g^i", { buffer = true })

-- decrease line length without zen mode plugins
vim.opt_local.signcolumn = "yes:9"

-- do not auto-wrap text
vim.opt_local.formatoptions:remove({"t", "c"})

-- hide links and some markup (similar to Obsidian's live preview)
vim.opt_local.conceallevel = 2 

--------------------------------------------------------------------------------

-- searchlink
keymap({ "n", "x" }, "<leader>k", function()
	local query
	if fn.mode() == "n" then
		u.normal([["zciw]])
	else
		u.normal([["zc]])
	end
	query = fn.getreg("z")
	local jsonResponse = fn.system(([[ddgr --num=1 --json "%s"]]):format(query))
	local link = vim.json.decode(jsonResponse)[1].url
	local mdlink = ("[%s](%s)"):format(query, link)
	fn.setreg("z", mdlink)
	u.normal([["zp]])
end, { desc = " SearchLink (ddgr)", buffer = true })

-- Open in Obsidian
keymap("n", "<D-S-l>", function()
	local filepath = fn.expand("%:p")
	local isInMainVault = vim.startswith(filepath, vim.env.VAULT_PATH)
	if not isInMainVault then
		vim.notify("Not in Obsidian vault", vim.log.levels.WARN)
		return
	end
	-- assumes being on mac and the Obsidian-opener.app set as default app for markdown files
	fn.system("open -a Obsidian", filepath)
end, { desc = " Open in Obsidian", buffer = true })

-- Build / Preview
keymap("n", "<D-r>", "<Plug>MarkdownPreview", { desc = "  Preview", buffer = true })
keymap("n", "<leader>r", "<Plug>MarkdownPreview", { desc = "  Preview", buffer = true })

-- stylua: ignore start
-- link textobj
keymap({ "o", "x" }, "il", "<cmd>lua require('various-textobjs').mdlink(true)<CR>", { desc = "inner md link textobj", buffer = true })
keymap({ "o", "x" }, "al", "<cmd>lua require('various-textobjs').mdlink(false)<CR>", { desc = "outer md link textobj", buffer = true })

-- iE/aE: code block textobj
keymap({ "o", "x" }, "iE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(true)<CR>", { desc = "inner md code block textobj", buffer = true })
keymap({ "o", "x" }, "aE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(false)<CR>", { desc = "outer md code block textobj", buffer = true })

-- Format Table
keymap("n", "<leader>q", "vip:!pandoc -t commonmark_x<CR><CR>", { desc = "  Format Table", buffer = true })

-- Heading jump to next/prev heading
keymap({ "n", "x" }, "<C-j>", [[/^#\+ <CR><cmd>nohl<CR>]], { desc = " # Next Heading", buffer = true })
keymap({ "n", "x" }, "<C-k>", [[?^#\+ <CR><cmd>nohl<CR>]], { desc = " # Prev Heading", buffer = true })
-- stylua: ignore end

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
