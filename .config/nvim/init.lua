-- https://bryankegley.me/posts/nvim-getting-started/
-- https://neovim.io/doc/user/vim_diff.html
--------------------------------------------------------------------------------

vim.opt.rtp:append(', "~/.config/nvim/lua"') -- needed for homebrew installs of nvim
require("options")
require("keybindings")
require("plugins")




