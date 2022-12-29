vim.g.mapleader = ","
borderStyle = "single" -- options: https://neovim.io/doc/user/api.html#nvim_open_win()

--------------------------------------------------------------------------------

require("config/lazy")
require("config/utils") -- should come after lazy

if isGui() then
	require("config/theme-settings") -- should come early to start with the proper theme
	require("config/gui-settings")
	require("config/notifications")
else
	require("config/terminal-only")
end
require("config/options-and-autocmds")
require("config/keybindings")
require("config/user-commands")
require("config/lualine")
require("config/treesitter")

require("config/lsp-and-diagnostics") -- should come before linter and debugger
require("config/linter")
require("config/debugger")

require("config/comments")
require("config/textobjects")
require("config/telescope")
require("config/automating-nvim")


