local bkeymap = require("config.utils").bufKeymap
local optl = vim.opt_local

---GENERAL----------------------------------------------------------------------
optl.expandtab = false
optl.tabstop = 4 -- less nesting in md, so we can afford larger tabstop
optl.commentstring = "<!-- %s -->" -- add spaces

-- so two trailing spaces are highlighted, but not a single trailing space
optl.listchars:remove("trail")
optl.listchars:append { multispace = "·" }
optl.sidescrolloff = 3 -- lower, since we rarely go beyond textwidth

---KEYMAPS----------------------------------------------------------------------

bkeymap("n", "<leader>rt", "vip:!pandoc --to=gfm<CR>", { desc = " Format table under cursor" })
-- stylua: ignore
bkeymap("n", ">", function() require("personal-plugins.hiraganafy")() end, { desc = " Hiraganafy" })

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

-- when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
	desc = "User: auto-hard-wrap",
	group = vim.api.nvim_create_augroup("auto-hardwrap", { clear = true }),
	buffer = 0,
	callback = function(ctx)
		local line, node = vim.api.nvim_get_current_line(), vim.treesitter.get_node()
		if vim.bo[ctx.buf].buftype ~= "" then return end

		if not line:sub(81):find(" ") then return end -- markdownlint's `line-length` spec
		if line:find("^[|#]") then return end -- heading or table
		if node and node:type() == "code_fence_content" then return end
		if node and node:type() == "html_block" then return end
		vim.cmd.normal { "gww", bang = true }
	end,
})

--------------------------------------------------------------------------------
