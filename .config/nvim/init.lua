
vim.opt.runtimepath:append(', "~/.config/nvim/lua"') -- apparently required for homebrew installs where the runtimepath is missing the .config directory?!

require("packer-setup") -- must be 1st
require("utils") -- must be 2nd

require("options")
require("coc-config")
require("appearance")
require("telescope-config")
require("keybindings")
require("appearance")
require("small-plugins")
require("filetype-specific")

