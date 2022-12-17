borderStyle = "single" -- https://neovim.io/doc/user/api.html#nvim_open_win()
require("config/packer-setup") -- must be 1st
require("impatient") -- plugin, must be 2nd
require("config/utils") -- must be 3rd

--------------------------------------------------------------------------------

require("config/options-and-autocmds")
if isGui() then
	require("config/theme-settings") -- should come early to start with the proper theme
	require("config/gui-settings")
else
	require("config/terminal-only")
end
require("config/keybindings")
require("config/textobjects")
require("config/user-commands")
require("config/automating-nvim")
require("config/appearance")

require("config/lsp-and-diagnostics") -- should come before completion, linter, and debugger
require("config/completion")
require("config/linter")
require("config/debugger")

require("config/comment-config")
require("config/AI-support")
require("config/telescope-config")
require("config/treesitter-config")
if isGui() then require("config/color-picker") end
require("config/remaining-plugins")

require("config/snippets")
