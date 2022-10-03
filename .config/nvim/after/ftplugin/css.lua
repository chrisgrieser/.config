-- doen't highlight leading spaces, since some are needed in the yaml part of
-- comments of the Shimmering Focus theme
cmd[[highlight clear WhiteSpaceBol]]

b.coc_disabled_sources = {'around', 'buffer', 'file'}
b.coc_additional_keywords = {"-", "#"}
b.syntax = "ON"

-- comment marks more useful than symbols for theme development
keymap("n", "gs", function() telescope.current_buffer_fuzzy_find{
	default_text='< ',
	prompt_prefix='🪧',
	prompt_title = 'Navigation Markers',
} end, {buffer = true})


-- kebab-case variables, #hex color codes, & percentage values
-- bo.iskeyword = bo.iskeyword.."#,-,%" -- opt.iskeyword is table, but bo.iskeyword is a string... 🙈

