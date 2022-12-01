-- apparently required for homebrew installs where the runtimepath is missing the .config directory?!
-- vim.opt.runtimepath:append("~/.config/nvim/lua")

borderStyle = "rounded" -- https://neovim.io/doc/user/api.html#nvim_open_win()
require("packer-setup") -- must be 1st
require("impatient") -- must be 2nd
require("utils") -- must be 3rd

---try to require a package
---@param pkg string
---@return boolean
local function tryRequire(pkg)
	local status_ok, _ = pcall(require, pkg)
	return status_ok
end

--------------------------------------------------------------------------------

tryRequire("options-and-autocmds")
tryRequire("appearance")

tryRequire("keybindings")
tryRequire("surround-config")
tryRequire("comment-config")
tryRequire("telescope-config")
tryRequire("treesitter-config")
tryRequire("remaining-plugins")

tryRequire("lsp-and-diagnostics") -- should come before completion, linter, and debugger
tryRequire("completion")
tryRequire("linter")
tryRequire("debugger")
tryRequire("snippets")

if isGui() then
	tryRequire("theme-settings")
	tryRequire("gui-settings")
	tryRequire("color-utilities")
else
	tryRequire("terminal-only")
end
