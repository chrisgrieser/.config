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
safeRequire("config.options-and-autocmds")

safeRequire("config.keybindings")
safeRequire("config.textobject-keymaps")
safeRequire("config.folding")
safeRequire("config.clipboard")

safeRequire("config.user-commands")
safeRequire("config.abbreviations")

--------------------------------------------------------------------------------

-- runs in the background and with timeout, in case the site does not respond
local function tipOfTheDay()
	local command = 'curl -s --max-time 5 "https://vtip.43z.one"' -- --max-time = timeout for curl
	vim.fn.jobstart(command, {
		stdout_buffered = true,
		on_stdout = function(_, stdout)
			vim.notify(" TIP\n" .. stdout[1], vim.log.levels.INFO, { timeout = 10000 })
		end,
	})
end

vim.defer_fn(tipOfTheDay, 2000)
