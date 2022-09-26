-- https://bryankegley.me/posts/nvim-getting-started/
--------------------------------------------------------------------------------

vim.opt.runtimepath:append(', "~/.config/nvim/lua"') -- required for homebrew installs (where the runtimepath is in the homebrew dir)

require("options")
require("keybindings")
require("plugins")

-------------------------------------------------------------------------------

