
vim.opt.runtimepath:append(', "~/.config/nvim/lua"') -- apparently required for homebrew installs where the runtimepath is missing the .config directory?!

require("packer-setup") -- must be 1st
require("utils") -- must be 2nd

require("options")
require("keybindings")
require("filetype-specific")
require("remaining-plugins")

if g.started_by_firenvim then
	require("firenvim-config")
else
	require("appearance")
	require("coc-config")
	require("telescope-config")
	require("treesitter-config")
	require("cheat-sh-config")
end

if (g.neovide or g.goneovim) then
	require("gui-settings")
end

