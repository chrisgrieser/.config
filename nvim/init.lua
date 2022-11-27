-- apparently required for homebrew installs where the runtimepath is missing the .config directory?!
vim.opt.runtimepath:append [[, "~/.config/nvim/lua"]]

--------------------------------------------------------------------------------
borderStyle = "rounded" -- https://neovim.io/doc/user/api.html#nvim_open_win()
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
require("lsp-and-diagnostics") -- should come before completion, linter, and debugger
require("completion")
require("linter")
require("debugger")
require("snippets")
require("remaining-plugins")

if isGui() then
	require("theme")
	require("gui-settings")
	require("color-utilities")
else
	require("terminal-only")
end
