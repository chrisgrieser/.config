-- apparently required for homebrew installs where the runtimepath is missing the .config directory?!
vim.opt.runtimepath:append(', "~/.config/nvim/lua"') ---@diagnostic disable-line: undefined-field

--------------------------------------------------------------------------------

borderStyle = "rounded" -- must be 0th
require("packer-setup") -- must be 1st
require('impatient') -- must be 2nd (plugin, improve startuptime)
require("utils") -- must be 3rd

--------------------------------------------------------------------------------

require("options-and-autocmds")
require("keybindings")
require("remaining-plugins")
require("appearance")
require("telescope-config")
require("treesitter-config")
require("lsp-and-diagnostics")
require("completion") -- should come after lsp
require("linter") -- should come after lsp
require("snippets")

if isGui() then
	require("gui-settings")
	require("color-utilities")
else
	require("terminal-only")
end

