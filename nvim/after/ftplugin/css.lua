require("config.utils")
--------------------------------------------------------------------------------

-- COMMENT MARKS
-- more useful than symbols for theme development
Bo.grepprg = "rg --vimgrep --no-column" -- remove columns for readability
Keymap("n", "gs", function()
	Cmd([[silent! lgrep "^(\# <<\|/\* <)" %]]) -- riggrep-search for navigaton markers in SF
	require("telescope.builtin").loclist {
		prompt_title = "Navigation Markers",
		fname_width = 0,
	}
end, { desc = "Search Navigation Markers", buffer = true })

-- search only for variables
Keymap("n", "gS", function()
	Cmd([[silent! lgrep "^\s*--" %]]) -- riggrep-search for css variables
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
Keymap("n", "zz", ":syntax sync fromstart<CR>", { buffer = true })

-- extra trigger for css files, to work with live reloads
Autocmd("TextChanged", {
	buffer = 0, -- buffer-local autocmd
	callback = function() Cmd.update(Expand("%:p")) end,
})

--------------------------------------------------------------------------------

-- Section movement
Keymap({ "n", "x" }, "<C-j>", [[/^\/\* <<CR>:nohl<CR>]], { buffer = true, desc = "next section" })
Keymap({ "n", "x" }, "<C-k>", [[?^\/\* <<CR>:nohl<CR>]], { buffer = true, desc = "prev section" })

--------------------------------------------------------------------------------
-- stylua: ignore start
Keymap({ "o", "x" }, "is", function() require("various-textobjs").cssSelector(true) end, { desc = "inner CSS Selector textobj", buffer = true })
Keymap({ "o", "x" }, "as", function() require("various-textobjs").cssSelector(false) end, { desc = "outer CSS Selector textobj", buffer = true })

Keymap({ "o", "x" }, "ix", function() require("various-textobjs").htmlAttribute(true) end, { desc = "inner HTML Attribute textobj", buffer = true })
Keymap({ "o", "x" }, "ax", function() require("various-textobjs").htmlAttribute(false) end, { desc = "outer HTML Attribute textobj", buffer = true })
-- stylua: ignore end

--------------------------------------------------------------------------------
---@diagnostic disable: undefined-field, param-type-mismatch

-- toggle !important
Keymap("n", "<leader>i", function()
	local lineContent = Fn.getline(".")
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";", " !important;")
	end
	Fn.setline(".", lineContent)
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
	Fn.append(".", hr)
	local lineNum = GetCursor(0)[1] + 2
	local colNum = #hr[2] + 2
	SetCursor(0, { lineNum, colNum })
	Cmd.startinsert { bang = true }
end

Keymap("n", "qw", function()
	if Expand("%:t"):find("source.css") then
		cssHeaderComment()
	else
		require("funcs.comment-divider").commentHr()
	end
end, { buffer = true, desc = "insert comment divider" })
---@diagnostic enable: undefined-field, param-type-mismatch
