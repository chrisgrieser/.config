---@diagnostic disable-next-line: undefined-field
vim.opt.runtimepath:append(', "~/.config/nvim/lua"') -- apparently required for homebrew installs where the runtimepath is missing the .config directory?!

require("packer-setup") -- must be 1st
require('impatient') -- must be 2nd (plugin, improve startuptime)
require("utils") -- must be 3rd

--------------------------------------------------------------------------------

require("options")
require("keybindings")
require("filetype-specific")
require("remaining-plugins")
require("appearance")
require("telescope-config")
require("treesitter-config")
require("cheat-sh-config")
require("lsp-and-diagnostics")
require("completion")
require("linter")

if isGui() then
	require("gui-settings")
	require("color-utilities")
else
	require("terminal-only")
end

