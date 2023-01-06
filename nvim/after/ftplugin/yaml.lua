require("config.utils")
--------------------------------------------------------------------------------

-- use 2 spaces instead of tabs
bo.shiftwidth = 2
bo.tabstop = 2
bo.softtabstop = 2
bo.expandtab = true
wo.listchars = "tab: >"

keymap("x", "<D-m>", [[:!yq -P -o=json -I=0<CR><CR>:s/"//g<CR>==]], {desc = "compatify YAML", buffer = true})
