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

-- fix line-length violations reported by markdownlint
bkeymap("n", "#", function()
	vim.diagnostic.jump { count = 1 }
	vim.defer_fn(function() vim.cmd.normal { "gw}", bang = true } end, 1)
end, { desc = " hard-wrap next line-length violation" })

---CODEBLOCKS-------------------------------------------------------------------
-- typing `,,lang,,` creates a codeblock for `lang` with dedented clipboard
-- content inserted as code.
bkeymap("i", ",", function()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local textBeforeCursor = vim.api.nvim_get_current_line():sub(1, col)
	local lang = textBeforeCursor:match(",,(%a*),$")
	if not lang then
		vim.api.nvim_feedkeys(",", "n", true) -- pass through the trigger char
		return
	end

	-- dedent clipboard content
	local code = vim.split(vim.fn.getreg("+"), "\n", { trimempty = true })
	local smallestIndent = vim.iter(code):fold(math.huge, function(acc, line)
		local indent = #line:match("^%s*")
		return math.min(acc, indent)
	end)
	local dedented = vim.tbl_map(function(line) return line:sub(smallestIndent + 1) end, code)

	-- insert
	table.insert(dedented, 1, "```" .. lang)
	table.insert(dedented, "```")
	vim.api.nvim_buf_set_lines(0, row - 1, row, false, dedented)
	vim.api.nvim_win_set_cursor(0, { row, 1 })
	if lang == "" then
		vim.cmd.startinsert { bang = true }
	else
		vim.cmd.stopinsert()
	end
end, { desc = " ,, -> Codeblock" })

---MARKDOWN PREVIEW-------------------------------------------------------------
bkeymap("n", "<leader>ep", function()
	local css = vim.env.HOME .. "/.config/pandoc/css/github-markdown.css"
	local outputPath = "/tmp/markdown-preview.html"

	vim.cmd("silent! update")

	-- create github-html via pandoc
	vim.system({
		"pandoc",
		"--from=gfm+rebase_relative_paths", -- rebasing, so images are available at output location
		vim.api.nvim_buf_get_name(0),
		"--output=" .. outputPath,
		"--standalone",
		"--css=" .. css,
	}):wait()

	vim.ui.open(outputPath)
end, { desc = " Preview" })

--------------------------------------------------------------------------------
