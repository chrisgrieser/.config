
vim.opt.runtimepath:append(', "~/.config/nvim/lua"') -- apparently required for homebrew installs where the runtimepath is missing the .config directory?!

require("utils")

require("options")
require("keybindings")
require("packer-setup")

require("appearance")
require("plugin-specific")

