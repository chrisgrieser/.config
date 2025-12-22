local bkeymap = require("config.utils").bufKeymap
local optl = vim.opt_local

---GENERAL----------------------------------------------------------------------
optl.expandtab = true
optl.commentstring = "<!-- %s -->" -- add spaces

-- so two trailing spaces are highlighted, but not a single trailing space
optl.listchars:remove("trail")
optl.listchars:append { multispace = "·" }
optl.sidescrolloff = 3 -- lower, since we rarely go beyond textwidth

---KEYMAPS----------------------------------------------------------------------

bkeymap("n", "<leader>rt", "vip:!pandoc --to=gfm<CR>", { desc = " Format table under cursor" })
-- stylua: ignore
bkeymap("n", "#", function() require("personal-plugins.hiraganafy")() end, { desc = " Hiraganafy" })

-- auto-bullet
-- stylua: ignore start
bkeymap("n", "o", function() require("personal-plugins.markdown-qol").autoBullet("o") end, { desc = " Auto-bullet o" })
bkeymap("n", "O", function() require("personal-plugins.markdown-qol").autoBullet("O") end, { desc = " Auto-bullet O" })
bkeymap("i", "<CR>", function() require("personal-plugins.markdown-qol").autoBullet("<CR>") end, { desc = " Auto-bullet <CR>" })
-- stylua: ignore end

-- cycle list
-- stylua: ignore
bkeymap({ "n", "i" }, "<D-u>", function() require("personal-plugins.markdown-qol").cycleList() end, { desc = "󰍔 Cycle list types" })

-- headings
-- Jump to next/prev heading (`##` to skip H1 and comments in code-blocks)
bkeymap("n", "<C-j>", [[/^##\+ .*<CR>]], { desc = " Next heading" })
bkeymap("n", "<C-k>", [[?^##\+ .*<CR>]], { desc = " Prev heading" })

-- follow url/wikilink
-- stylua: ignore
bkeymap("n", "gx", function() require("personal-plugins.markdown-qol").followUrlOrWikilink() end, { desc = " Follow URL/Wikilink" })

-- <D-h> remapped to <D-5>, since used by macOS PENDING https://github.com/neovide/neovide/issues/3099
-- stylua: ignore
bkeymap({ "n", "i" }, "<D-5>", function() require("personal-plugins.markdown-qol").incrementHeading(1) end, { desc = " Increment heading" })
-- stylua: ignore
bkeymap({ "n", "i" }, "<D-H>", function() require("personal-plugins.markdown-qol").incrementHeading(-1) end, { desc = " Decrement heading" })

-- aliases frontmatter
bkeymap("n", "<leader>ra", function()
	local toInsert = { "aliases:", "  - " }
	require("personal-plugins.markdown-qol").insertFrontmatter(toInsert)
end, { desc = " Add aliases frontmatter" })

-- add title to url
-- stylua: ignore
bkeymap("n", "<leader>cu", function() require("personal-plugins.markdown-qol").addTitleToUrl() end, { desc = " Add title to URL" })

-- preview
bkeymap("n", "<leader>ep", function()
	local css = vim.env.HOME .. "/.config/pandoc/css/github-markdown.css"
	require("personal-plugins.markdown-qol").previewViaPandoc(css)
end, { desc = " Preview" })

bkeymap(
	{ "n", "i" },
	"<D-C-e>", -- `hyper` gets registered by neovide as `cmd+ctrl` (`<D-C-`)
	function() require("personal-plugins.markdown-qol").codeBlockFromClipboard() end,
	{ desc = " Codeblock" }
)

---HARD WRAP--------------------------------------------------------------------

-- when typing beyond `textwidth`
vim.schedule(function() optl.formatoptions:append("t") end)

--------------------------------------------------------------------------------
