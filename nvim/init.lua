g.mapleader = ","
borderStyle = "single" -- options: https://neovim.io/doc/user/api.html#nvim_open_win()

--------------------------------------------------------------------------------

require("config/lazy")
require("config/utils") -- should come after lazy

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

require("config/comments")
require("config/AI-support")
require("config/telescope")
require("config/treesitter")
if isGui() then require("config/color-picker") end

require("config/snippets")

