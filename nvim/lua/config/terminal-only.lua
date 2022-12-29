require("config.utils")
-- a color scheme
--------------------------------------------------------------------------------

-- Gutter transparent
cmd[[highlight clear SignColumn]] 

-- Ruler
cmd[[highlight ColorColumn ctermbg=DarkGrey]]

-- Active Line
cmd[[highlight CursorLine term=none cterm=none ctermbg=black]]

-- Indentation Lines
cmd[[highlight IndentBlanklineChar ctermfg=DarkGrey]]

-- Comments
cmd[[highlight Comment ctermfg=grey]]

-- Popup Menus
cmd[[highlight Pmenu ctermbg=DarkGrey]]

-- Line Numbers
cmd[[highlight LineNr ctermfg=DarkGrey]]
cmd[[highlight CursorLineNr ctermfg=Grey]]

-- Tree Sitter Context Line
cmd[[highlight TreesitterContext ctermbg=Black]]
