
local g = vim.g

-- Quick Scope: only highlight on key presses
g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }

-- netrw
g.netrw_list_hide= '.*\\.DS_Store$,^./$' -- hide files createed by macOS & current directory
g.netrw_banner = 0 -- no ugly menu for netrw
