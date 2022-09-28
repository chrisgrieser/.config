
vim.opt.runtimepath:append(', "~/.config/nvim/lua"') -- apparently required for homebrew installs where the runtimepath is missing the .config directory?!
require("packer-setup") -- must be loaded first
require("utils") -- should be loaded second

require("options")
require("keybindings")
require("appearance")
require("plugin-specific")
require("lsp-setup")

