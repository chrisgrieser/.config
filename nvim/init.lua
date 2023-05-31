vim.g.mapleader = ","
vim.g.maplocalleader = "!"

vim.loader.enable() -- TODO will be nvim default in later versions

---try to require the module, and do not error when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
	local success, _ = pcall(require, module)
	if success then return end
	local msg = "Error loading " .. module
	local notifyLoaded, _ = pcall(require, "notify")
	if notifyLoaded then
		vim.notify(" " .. msg, vim.log.levels.ERROR)
	else
		vim.cmd(('echohl Error | echo "%s" | echohl None'):format(msg))
	end
end

--------------------------------------------------------------------------------

safeRequire("config.lazy")

if vim.fn.has("gui_running") then safeRequire("config.gui-settings") end
safeRequire("config.theme-customization")

local fn = vim.fn
-- auto-nohl -> https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?context=3
vim.on_key(function(char)
	local searchKeys = { "n", "N", "*", "#" }
	local searchConfirmed = (fn.keytrans(char) == "<CR>" and fn.getcmdtype():find("[/?]") ~= nil)
	if not (searchConfirmed or fn.mode() == "n") then return end
	local searchKeyUsed = searchConfirmed or (vim.tbl_contains(searchKeys, fn.keytrans(char)))
	if vim.opt.hlsearch:get() ~= searchKeyUsed then vim.opt.hlsearch = searchKeyUsed end
end, vim.api.nvim_create_namespace("auto_nohl"))



safeRequire("config.options-and-autocmds")

-- safeRequire("config.keybindings")
-- safeRequire("config.textobject-keymaps")

-- safeRequire("config.folding")
-- safeRequire("config.clipboard")

-- safeRequire("config.user-commands")
-- safeRequire("config.abbreviations")
