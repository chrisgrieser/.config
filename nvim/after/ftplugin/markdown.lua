---OPTIONS----------------------------------------------------------------------
local optl = vim.opt_local

optl.expandtab = true
optl.shiftwidth = 4
optl.commentstring = "<!-- %s -->" -- add spaces

-- so two trailing spaces are highlighted, but not a single trailing space
optl.listchars:remove("trail")
optl.listchars:append { multispace = "·" }

-- hard-wrap when typing beyond `textwidth`
vim.schedule(function() optl.formatoptions:append("t") end)

---ABBREVIATIONS----------------------------------------------------------------
local abbr = require("config.utils").bufAbbrev
abbr("->", "→")

---KEYMAPS----------------------------------------------------------------------
local bkeymap = require("config.utils").bufKeymap
local qol = require("personal-plugins.md-qol")

bkeymap("n", "p", function()
	require("personal-plugins.md-qol").addTitleToUrlIfMarkdown("+")
	return "p"
end, { desc = " Paste (+ add title if URL)", expr = true })
bkeymap("n", "<leader>cu", qol.addTitleToUrl, { desc = " Add title to URL" })

bkeymap("n", "o", function() qol.autoBullet("o") end, { desc = " Auto-bullet o" })
bkeymap("n", "O", function() qol.autoBullet("O") end, { desc = " Auto-bullet O" })
bkeymap("i", "<CR>", function() qol.autoBullet("<CR>") end, { desc = " Auto-bullet <CR>" })

bkeymap({ "n", "i" }, "<D-u>", qol.cycleList, { desc = "󰍔 Cycle list types" })

-- headings
-- Jump to next/prev heading (`##` to skip H1 and comments in code-blocks)
bkeymap("n", "<C-j>", [[/^##\+ .*<CR>]], { desc = " Next heading" })
bkeymap("n", "<C-k>", [[?^##\+ .*<CR>]], { desc = " Prev heading" })

-- stylua: ignore
bkeymap("n", "gx", qol.followMdlinkOrWikilink, { desc = " Follow URL/Wikilink" })

-- <D-h> remapped to <D-5>, since used by macOS PENDING https://github.com/neovide/neovide/issues/3099
bkeymap({ "n", "i" }, "<D-5>", function() qol.incrementHeading(1) end, { desc = " Heading++" })
bkeymap({ "n", "i" }, "<D-H>", function() qol.incrementHeading(-1) end, { desc = " Heading--" })

-- aliases frontmatter
bkeymap("n", "<leader>ra", function()
	local toInsert = { "aliases:", "  - " }
	qol.insertFrontmatter(toInsert)
end, { desc = " Add aliases frontmatter" })

bkeymap("n", "<leader>ep", qol.previewViaPandoc, { desc = " Preview" })

-- `hyper` gets registered by neovide as `cmd+ctrl` (`<D-C-`)
bkeymap({ "n", "i" }, "<D-C-e>", qol.codeBlockFromClipboard, { desc = " Codeblock" })

bkeymap("n", "<leader>cb", qol.backlinks, { desc = " Backlinks" })
-- bkeymap("n", "<leader>fr", qol.renameAndUpdateWikilinks, { desc = " Rename file & backlinks" })

-- stylua: ignore
bkeymap("n", "#", function() require("personal-plugins.hiraganafy")() end, { desc = " Hiraganafy" })

--------------------------------------------------------------------------------
