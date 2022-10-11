vim.opt.runtimepath:append(', "~/.config/nvim/lua"') -- apparently required for homebrew installs where the runtimepath is missing the .config directory?!

require("packer-setup") -- must be 1st
require("utils") -- must be 2nd

require('impatient') -- plugin, improve startuptime

require("options")
require("keybindings")
require("filetype-specific")
require("remaining-plugins")
require("appearance")
require("telescope-config")
require("treesitter-config")
require("cheat-sh-config")
require("lsp")
require("completion")
require("linter")

if (g.neovide or g.goneovim) then
	require("gui-settings")
	require("color-utilities")
else
	require("terminal-only")
end

