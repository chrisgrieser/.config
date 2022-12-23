require("config/utils")
local opts = { buffer = true }
--------------------------------------------------------------------------------

-- comment marks more useful than symbols for theme development
keymap("n", "gs", function()
	cmd([[silent! lgrep "^(\# <<\|/\* <)" %]]) -- riggrep-search for navigaton markers in SF
	telescope.loclist {
		prompt_title = "Navigation Markers",
		fname_width = 0,
	}
end, { desc = "Search Navigation Markers", buffer = true })

-- search only for variables
keymap("n", "gS", function()
	cmd([[silent! lgrep "^\s*--" %]]) -- riggrep-search for css variables
	telescope.loclist {
		prompt_prefix = " ",
		prompt_title = "CSS Variables",
		fname_width = 0,
	}
end, { desc = "Search CSS Variables", buffer = true })

--------------------------------------------------------------------------------

-- INFO: fix syntax highlighting with ':syntax sync fromstart'
-- various other solutions are described here: https://github.com/vim/vim/issues/2790
-- however, using treesitter, this is less of an issue, but treesitter css
-- highlighting isn't good yet, so…
keymap("n", "zz", ":syntax sync fromstart<CR>", opts)

--------------------------------------------------------------------------------

-- Section instead of function movement
keymap({ "n", "x" }, "<C-j>", [[/^\/\* <<CR>:nohl<CR>]], opts)
keymap({ "n", "x" }, "<C-k>", [[?^\/\* <<CR>:nohl<CR>]], opts)

--------------------------------------------------------------------------------

keymap(
	{ "o", "x" },
	"as",
	function() varTextObj.cssSelector(false) end,
	{ desc = "outer CSS selector textobj", buffer = true }
)
keymap(
	{ "o", "x" },
	"is",
	function() varTextObj.cssSelector(true) end,
	{ desc = "inner CSS selector textobj", buffer = true }
)

-- double a selector
keymap("n", "yd", "yisEp", { buffer = true, silent = true, remap = true })

--------------------------------------------------------------------------------

-- smart line duplicate (mnemonic: [R]eplicate)
-- switches top/bottom & moves to value
keymap("n", "R", function() qol.duplicateLine { reverse = true, moveTo = "value" } end, opts)

---@diagnostic disable: undefined-field, param-type-mismatch
keymap("n", "<leader>i", function()
	local lineContent = fn.getline(".")
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";", " !important;")
	end
	fn.setline(".", lineContent)
end, { buffer = true, desc = "toggle !important" })

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
