-- terminal-only styling, since most of these are already handled when using by
-- a color scheme
--------------------------------------------------------------------------------

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

