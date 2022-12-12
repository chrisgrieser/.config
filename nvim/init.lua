borderStyle = "single" -- https://neovim.io/doc/user/api.html#nvim_open_win()
require("packer-setup") -- must be 1st
require("impatient") -- must be 2nd
require("utils") -- must be 3rd

--------------------------------------------------------------------------------

-- ffffffffffffffffff ffffffffffffffff fffffffffff ffffffffffffffff fffffffffffff ffffffffffffffffff fffffffffffff

require("options-and-autocmds")

if isGui() then
	require("theme-settings") -- should come first to start with the proper theme
	require("gui-settings")
else
	require("terminal-only")
end
require("keybindings")
require("user-commands")
require("automating-nvim")
require("appearance")

require("lsp-and-diagnostics") -- should come before completion, linter, and debugger
require("completion")
-- require("linter")
require("debugger")

require("surround-config")
require("comment-config")
require("telescope-config")
require("treesitter-config")
if isGui() then require("color-picker") end
require("remaining-plugins")

require("snippets")
