---@diagnostic disable: undefined-global
require("utils")
local opts = {buffer = true, silent = true}
--------------------------------------------------------------------------------

-- comment marks more useful than symbols for theme development
keymap("n", "gs", function() telescope.current_buffer_fuzzy_find {
		default_text = "/* < ",
		prompt_prefix = " ",
		prompt_title = "Navigation Markers",
	}
end, opts)

-- search only for variables
keymap("n", "gS", function() telescope.current_buffer_fuzzy_find {
		default_text = "--",
		prompt_prefix = " ",
		prompt_title = "CSS Variables",
	}
end, opts)

--------------------------------------------------------------------------------

-- INFO: fix syntax highlighting with ':syntax sync fromstart'
-- various other solutions are described here: https://github.com/vim/vim/issues/2790
-- however, using treesitter, this is less of an issue, but treesitter css
-- highlighting isn't good yet, so…
keymap("n", "zz", ":syntax sync fromstart<CR>", {buffer = true})

--------------------------------------------------------------------------------

-- Section instead of function movement
keymap({"n", "x"}, "<C-j>", [[/^\/\* <\+ <CR>:nohl<CR>]], opts)
keymap({"n", "x"}, "<C-k>", [[/^\/\* <\+ <CR>:nohl<CR>]], opts)

--------------------------------------------------------------------------------

-- custom text object css [s]elector (overwriting sentence textobj)
-- https://github.com/echasnovski/mini.nvim/blob/main/doc/mini-ai.txt
b.miniai_config = {
	custom_textobjects = {
		-- is = with ".", as = without
		s = {"%.()[%w-]+()"},
	},
}

-- double css class
keymap("n", "yc", "yaslBP", {buffer = true, silent = true, remap = true})

--------------------------------------------------------------------------------


-- smart line duplicate (mnemonic: [R]eplicate)
-- switches top/bottom & moves to value
keymap("n", "R", function () qol.duplicateLine {reverse = true, moveTo = "value"} end, opts)

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
end, {buffer = true})

keymap("n", "zh", function()
	local hr = {
		"/* ───────────────────────────────────────────────── */",
		"/* << ",
		"──────────────────────────────────────────────────── */",
		"",
		"",
	}
	fn.append(".", hr)
	local lineNum = api.nvim_win_get_cursor(0)[1] + 2
	local colNum = #hr[2] + 2
	api.nvim_win_set_cursor(0, {lineNum, colNum})
	cmd [[startinsert!]]
end, opts)

---@diagnostic enable: undefined-field, param-type-mismatch
