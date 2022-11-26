-- apparently required for homebrew installs where the runtimepath is missing the .config directory?!
vim.opt.runtimepath:append [[, "~/.config/nvim/lua"]] 

--------------------------------------------------------------------------------

require("packer-setup") -- must be 1st
require("impatient") -- must be 2nd (plugin, improve startuptime)
require("utils") -- must be 3rd

--------------------------------------------------------------------------------

require("options-and-autocmds")
require("keybindings")
require("appearance")
require("surround-config")
require("comment-config")
require("telescope-config")
require("treesitter-config")
require("lsp-and-diagnostics")
require("completion") -- should come after lsp
require("linter") -- should come after lsp
require("debugger") -- should come after lsp
require("snippets")
require("remaining-plugins")

if isGui() then ---@diagnostic disable-line: undefined-global
	require("theme")
	require("gui-settings")
	require("color-utilities")
else
	require("terminal-only")
end
