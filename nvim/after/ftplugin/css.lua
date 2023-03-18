require("config.utils")
--------------------------------------------------------------------------------

-- COMMENT MARKS
-- more useful than symbols for theme development
bo.grepprg = "rg --vimgrep --no-column" -- remove columns
keymap("n", "gs", function()
	cmd([[silent! lgrep "^(\# <<\|/\* <)" %]]) -- riggrep-search for navigaton markers in SF
	require("telescope.builtin").loclist {
		prompt_title = "Navigation Markers",
		fname_width = 0,
	}
end, { desc = "Search Navigation Markers", buffer = true })

-- search only for variables
keymap("n", "gS", function()
	cmd([[silent! lgrep "^\s*--" %]]) -- riggrep-search for css variables
	require("telescope.builtin").loclist {
		prompt_title = "CSS Variables",
		prompt_prefix = "",
		fname_width = 0,
	}
end, { desc = "Search CSS Variables", buffer = true })

--------------------------------------------------------------------------------

-- INFO: fix syntax highlighting with ':syntax sync fromstart'
-- various other solutions are described here: https://github.com/vim/vim/issues/2790
-- however, using treesitter, this is less of an issue, but treesitter css
-- highlighting isn't good yet, so…
keymap("n", "zz", ":syntax sync fromstart<CR>", { buffer = true })

-- extra trigger for css files, to work with hot reloads
autocmd("TextChanged", {
	buffer = 0, -- buffer-local autocmd
	callback = function() cmd.update(expand("%:p")) end,
})

--------------------------------------------------------------------------------

-- Section instead of function movement
keymap({ "n", "x" }, "<C-j>", [[/^\/\* <<CR>:nohl<CR>]], { buffer = true, desc = "next section" })
keymap({ "n", "x" }, "<C-k>", [[?^\/\* <<CR>:nohl<CR>]], { buffer = true, desc = "prev section" })

--------------------------------------------------------------------------------
-- stylua: ignore start
keymap({ "o", "x" }, "as", function() require("various-textobjs").cssSelector(false) end, { desc = "outer CSS selector textobj", buffer = true })
keymap({ "o", "x" }, "is", function() require("various-textobjs").cssSelector(true) end, { desc = "inner CSS selector textobj", buffer = true })
-- stylua: ignore end

--------------------------------------------------------------------------------
---@diagnostic disable: undefined-field, param-type-mismatch

-- Inspect DOM of Obsidian selector
-- normal mode: current line, visual mode: selection
-- Requires: Obsidian advanced URI plugin and `eval` parameter for the plugin enabled
keymap({ "n", "x" }, "<leader>li", function()
	local selector
	if fn.mode() == "n" then
		selector = fn.getline("."):gsub("{.*", "")
	else
		Normal('"zy')
		selector = fn.getreg("z")
	end
	local jsCodeEncoded = [[electronWindow.openDevTools();const%20element%3Ddocument.querySelector("]]
		.. selector
		.. [[");console.log(element);]]
	fn.system("open 'obsidian://advanced-uri?eval=" .. jsCodeEncoded .. "'")
end, { desc = "Obsidian: document.querySelect()", buffer = true })

--------------------------------------------------------------------------------

-- if copying a css selection, add the closing bracket as well
keymap("n", "p", function()
	Normal("p") -- paste as always
	local reg = '"'
	local regContent = fn.getreg(reg)
	local isLinewise = fn.getregtype(reg) == "V"
	if isLinewise and regContent:find("{\n$") then
		fn.append(".", { "\t", "}" })
		Normal("j")
	end
end, { desc = "smarter CSS paste", buffer = true })

-- toggle !important
keymap("n", "<leader>i", function()
	local lineContent = fn.getline(".")
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";", " !important;")
	end
	fn.setline(".", lineContent)
end, { buffer = true, desc = "toggle !important" })

-- insert nice divider
keymap("n", "qw", function()
	local hr = {
		"/* ───────────────────────────────────────────────── */",
		"/* << ",
		"──────────────────────────────────────────────────── */",
		"",
		"",
	}
	fn.append(".", hr)
	local lineNum = getCursor(0)[1] + 2
	local colNum = #hr[2] + 2
	setCursor(0, { lineNum, colNum })
	cmd.startinsert { bang = true }
end, { buffer = true, desc = "insert comment-heading" })
---@diagnostic enable: undefined-field, param-type-mismatch
