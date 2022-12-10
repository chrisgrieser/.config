require("utils")
--------------------------------------------------------------------------------

-- use 2 spaces instead of tabs
bo.shiftwidth = 2
bo.tabstop = 2
bo.softtabstop = 2
bo.expandtab = true
setlocal("backspace", "start,eol,indent") -- restrict insert mode backspace behavior
setlocal("listchars", "tab: >")
