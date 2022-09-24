-- https://bryankegley.me/posts/nvim-getting-started/
-- https://neovim.io/doc/user/vim_diff.html
--------------------------------------------------------------------------------

-- required for homebrew installs (where the runtimepath is in the homebrew dir)
vim.opt.runtimepath:append(', "~/.config/nvim/lua"') 

require("options")
require("keybindings")
require("plugins")


-------------------------------------------------------------------------------

