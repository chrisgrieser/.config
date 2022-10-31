require("utils")
--------------------------------------------------------------------------------

-- comment marks more useful than symbols for theme development
keymap("n", "gs", function() telescope.current_buffer_fuzzy_find{
	default_text='/* < ',
	prompt_prefix=' ',
	prompt_title = 'Navigation Markers',
} end, {buffer = true, silent = true})

-- search only for variables
keymap("n", "gS", function() telescope.current_buffer_fuzzy_find{
	default_text='--',
	prompt_prefix=' ',
	prompt_title = 'CSS Variables',
} end, {buffer = true, silent = true})

-- kebab-case variables, #hex color codes, & percentage values
cmd[[
	setlocal iskeyword+=#
	setlocal iskeyword+=%
	setlocal iskeyword+=-
]]

-- INFO: fix syntax highlighting with ':syntax sync fromstart'
-- various other solutions are described here: https://github.com/vim/vim/issues/2790
-- however, using treesitter, this is less of an issue, but treesitter css
-- highlighting isn't good yet, so...
keymap("n", "zz", ":syntax sync fromstart<CR>", {buffer = true})

keymap("n", "cv", '^Ewct;', {buffer = true}) -- change [v]alue key
keymap("n", "<leader>c", 'mzlEF.yEEp`z', {buffer = true}) -- double [c]lass under cursor
keymap("n", "<leader>C", 'lF.d/[.\\s]<CR>:nohl<CR>', {buffer = true}) -- delete [c]lass under cursor

-- prefix "." and join the last paste. Useful when copypasting from the dev tools
keymap("n", "<leader>.","mz`[v`]: s/^\\| /./g<CR>:nohl<CR>`zl", {buffer = true})

-- toggle !important
---@diagnostic disable: undefined-field, param-type-mismatch
keymap("n", "<leader>i", function ()
	local lineContent = fn.getline('.')
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";", " !important;")
	end
	fn.setline(".", lineContent)
end, {buffer = true})
---@diagnostic enable: undefined-field, param-type-mismatch

