-- doen't highlight leading spaces, since some are needed in the yaml part of
-- comments of the Shimmering Focus theme
cmd[[highlight clear WhiteSpaceBol]]

-- comment marks more useful than symbols for theme development
keymap("n", "gs", function() telescope.current_buffer_fuzzy_find{
	default_text='< ',
	prompt_prefix='🪧',
	prompt_title = 'Navigation Markers',
} end, {buffer = true})


-- kebab-case variables, #hex color codes, & percentage values
cmd[[setlocal iskeyword+=#]] -- for whatever reason, appending to "bo.iskeyword" does not work...
cmd[[setlocal iskeyword+=%]]
cmd[[setlocal iskeyword+=-]]

bo.commentstring = "/* %s */"

-- INFO: fix syntax highlighting with ':syntax sync fromstart'
-- various other solutions are described here: https://github.com/vim/vim/issues/2790
-- however, using treesitter, this is less of an issue

