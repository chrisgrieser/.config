require("config.utils")
--------------------------------------------------------------------------------

-- COMMENT MARKS
-- more useful than symbols for theme development
bo.grepprg = "rg --vimgrep --no-column" -- remove columns for readability
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

-- extra trigger for css files, to work with live reloads
autocmd("TextChanged", {
	buffer = 0, -- buffer-local autocmd
	callback = function() cmd.update(expand("%:p")) end,
})

--------------------------------------------------------------------------------

-- Section movement
keymap({ "n", "x" }, "<C-j>", [[/^\/\* <<CR>:nohl<CR>]], { buffer = true, desc = "next section" })
keymap({ "n", "x" }, "<C-k>", [[?^\/\* <<CR>:nohl<CR>]], { buffer = true, desc = "prev section" })

--------------------------------------------------------------------------------
-- stylua: ignore start
keymap({ "o", "x" }, "is", "<cmd>lua require('various-textobjs').cssSelector(true)<CR>", { desc = "inner CSS Selector textobj", buffer = true })
keymap({ "o", "x" }, "as", "<cmd>lua require('various-textobjs').cssSelector(false)<CR>", { desc = "outer CSS Selector textobj", buffer = true })

keymap({ "o", "x" }, "ix", "<cmd>lua require('various-textobjs').htmlAttribute(true)<CR>", { desc = "inner HTML Attribute textobj", buffer = true })
keymap({ "o", "x" }, "ax", "<cmd>lua require('various-textobjs').htmlAttribute(false)<CR>", { desc = "outer HTML Attribute textobj", buffer = true })
-- stylua: ignore end

--------------------------------------------------------------------------------
---@diagnostic disable: undefined-field, param-type-mismatch

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

-- insert nice divider / header comment
local function cssHeaderComment()
	local hr = {
		"/* ───────────────────────────────────────────────── */",
		"/* << ",
		"──────────────────────────────────────────────────── */",
		"",
		"",
	}
	fn.append(".", hr)
	local lineNum = GetCursor(0)[1] + 2
	local colNum = #hr[2] + 2
	SetCursor(0, { lineNum, colNum })
	cmd.startinsert { bang = true }
end

keymap("n", "qw", function()
	if expand("%:t"):find("source.css") then
		cssHeaderComment()
	else
		require("funcs.comment-divider").commentHr()
	end
end, { buffer = true, desc = "insert comment divider" })
---@diagnostic enable: undefined-field, param-type-mismatch
