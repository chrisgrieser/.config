borderStyle = "rounded" -- https://neovim.io/doc/user/api.html#nvim_open_win()
require("packer-setup") -- must be 1st
require("impatient") -- must be 2nd
require("utils") -- must be 3rd

--------------------------------------------------------------------------------

require("options-and-autocmds")
require("appearance")
require("keybindings")
require("file-watcher")

require("surround-config")
require("comment-config")
require("telescope-config")
require("treesitter-config")
require("remaining-plugins")

require("lsp-and-diagnostics") -- should come before completion, linter, and debugger
require("completion")
require("linter")
require("debugger")
require("snippets")

if isGui() then
	require("theme-settings")
	require("gui-settings")
	require("color-utilities")
else
	require("terminal-only")
end
