local bkeymap = require("config.utils").bufKeymap
local optl = vim.opt_local

---GENERAL----------------------------------------------------------------------
optl.expandtab = false
optl.tabstop = 4 -- less nesting in md, so we can afford larger tabstop
vim.bo.commentstring = "<!-- %s -->" -- add spaces

-- so two trailing spaces are highlighted, but not a single trailing space
optl.listchars:remove("trail")
optl.listchars:append { multispace = "·" }

-- wrap
optl.wrap = true
optl.formatlistpat:append([[\|^\s*>\s\+]]) -- if wrapping, also indent blockquotes via `breakindentopt`

bkeymap("n", "<leader>rt", "vip:!pandoc --to=gfm<CR>", { desc = " Format table under cursor" })

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
	local code = vim.split(vim.fn.getreg("+"), "\n")
	while vim.trim(code[1]) == "" do
		table.remove(code, 1)
	end
	while vim.trim(code[#code]) == "" do
		table.remove(code)
	end
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
	vim.cmd.stopinsert()
end, { desc = " ,, -> Codeblock" })

---AUTO BULLETS-----------------------------------------------------------------
-- (simplified implementation of `bullets.vim`)
do
	optl.formatoptions:append("r") -- `<CR>` in insert mode
	optl.formatoptions:append("o") -- `o` in normal mode

	local function autoBullet(key)
		-- cannot set opt.comments permanently, since it disturbs the correctly
		-- indented continuation of bullet lists when hitting `opt.textwidth`
		local comBefore = optl.comments:get()
		-- stylua: ignore
		optl.comments = {
			"b:- [ ]", "b:- [x]", -- tasks
			"b:*", "b:-", "b:+", "b:\t*", "b:\t-", "b:\t+", -- unordered list
			"b:1.", "b:\t1.", -- ordered list
			"n:>", -- blockquotes
		}
		vim.defer_fn(function() optl.comments = comBefore end, 1) -- deferred to restore only after key
		return key
	end

	bkeymap("n", "o", function() return autoBullet("o") end, { expr = true })
	bkeymap("i", "<CR>", function() return autoBullet("<CR>") end, { expr = true })
end

---HEADINGS---------------------------------------------------------------------
-- Jump to next/prev heading (`##` to skip level 1 and comments in code-blocks)
bkeymap("n", "<C-j>", [[/^##\+ .*<CR>]], { desc = " Next heading" })
bkeymap("n", "<C-k>", [[?^##\+ .*<CR>]], { desc = " Prev heading" })

do
	local function headingsIncremantor(dir) ---@param dir 1|-1
		local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
		local curLine = vim.api.nvim_get_current_line()

		local updated = curLine:gsub("^#* ", function(match)
			if dir == -1 and match ~= "# " then return match:sub(2) end
			if dir == 1 and match ~= "###### " then return "#" .. match end
			return ""
		end)
		if updated == curLine then updated = (dir == 1 and "## " or "###### ") .. curLine end

		vim.api.nvim_set_current_line(updated)
		local diff = #updated - #curLine
		vim.api.nvim_win_set_cursor(0, { lnum, col + diff })
	end

	-- <D-h> remapped to <D-5>, since used by macOS PENDING https://github.com/neovide/neovide/issues/3099
	-- stylua: ignore
	bkeymap({ "n", "i" }, "<D-5>", function() headingsIncremantor(1) end, { desc = " Increment heading" })
	-- stylua: ignore
	bkeymap({ "n", "i" }, "<D-H>", function() headingsIncremantor(-1) end, { desc = " Decrement heading" })
end

---CYCLE LIST TYPES-------------------------------------------------------------
bkeymap({ "n", "i" }, "<D-u>", function()
	local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
	local curLine = vim.api.nvim_get_current_line()

	local updated = curLine:gsub("^(%s*)([%p%d x]* )", function(indent, list)
		if list:find("[*+-] ") and not list:find("%- %[") then return indent .. "- [ ] " end -- bullet -> task
		if vim.startswith(list, "- [") then return indent .. "1. " end -- task -> number
		return indent .. "- " -- number/other -> bullet
	end)
	-- none -> bullet
	if updated == curLine then updated = curLine:gsub("^(%s*)(.*)", "%1- %2") end

	vim.api.nvim_set_current_line(updated)
	local diff = #updated - #curLine
	vim.api.nvim_win_set_cursor(0, { lnum, math.max(1, col + diff) })
end, { desc = "󰍔 Cycle list types" })

---MARKDOWN PREVIEW-------------------------------------------------------------
bkeymap("n", "<leader>ep", function()
	-- SOURCE https://github.com/sindresorhus/github-markdown-css
	-- (replace `.markdown-body` with `body` and copypaste the first block)
	local css = vim.fn.stdpath("config") .. "/after/ftplugin/github-markdown.css"

	local outputPath = "/tmp/markdown-preview.html"
	vim.cmd("silent! update")

	-- create github-html via pandoc
	-- (alternative: github API https://docs.github.com/en/rest/markdown/markdown)
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
