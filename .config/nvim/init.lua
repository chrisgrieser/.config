
vim.opt.runtimepath:append(', "~/.config/nvim/lua"') -- apparently required for homebrew installs where the runtimepath is missing the .config directory?!

require("options")
require("keybindings")
require("load-plugins")

require("appearance")
require("plugin-specific")

