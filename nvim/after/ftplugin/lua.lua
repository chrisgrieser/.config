local fn = vim.fn
local cmd = vim.cmd
local keymap = vim.keymap.set
local expand = vim.fn.expand
local u = require("config.utils")
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

-- habits from writing too much js
abbr("<buffer> // --")
abbr("<buffer> const local")

--------------------------------------------------------------------------------

-- Build / Reload Config
keymap("n", "<leader>r", function()
	cmd("silent update")
	local pwd = vim.loop.cwd() or ""
	if pwd:find("nvim") then
		-- unload from lua cache (assuming that the pwd is parent of the lua folder)
		local packageName = expand("%:r"):gsub("lua/", ""):gsub("/", ".")
		package.loaded[packageName] = nil
		cmd.source()
		vim.notify("re-sourced:\n" .. expand("%:r"))
	elseif pwd:find("hammerspoon") then
		os.execute([[open -g "hammerspoon://hs-reload"]])
		vim.notify("✅ Hammerspoon reloaded.")
	else
		vim.notify("Neither in nvim nor in hammerspoon directory.", u.warn)
	end
end, { buffer = true, desc = " Reload" })

--------------------------------------------------------------------------------
-- INSPECT NVIM OR HAMMERSPOON OBJECTS

-- inspects the passed lua object / selection
local function inspect(str)
	local parentDir = expand("%:p:h")

	if parentDir:find("hammerspoon") then
		-- stylua: ignore
		local hsApplescript = ('tell application "Hammerspoon" to execute lua code "hs.alert(%s)"'):format(str)
		fn.system({ "osascript", "-e", hsApplescript })
	elseif parentDir:find("nvim") then
		if vim.startswith(str, "fn") or vim.startswith(str, "bo") then str = "vim." .. str end
		local output = vim.inspect(fn.luaeval(str))
		vim.notify(output, u.trace, {
			timeout = 7000, -- ms
			on_open = function(win) -- enable treesitter highlighting in the notification
				local buf = vim.api.nvim_win_get_buf(win)
				vim.api.nvim_buf_set_option(buf, "filetype", "lua")
			end,
		})
	else
		vim.notify("Neither in nvim nor in hammerspoon directory.", u.warn)
	end
end

-- stylua: ignore
keymap("n", "<leader>li", function() inspect(expand("<cWORD>")) end, { desc = " inspect cWORD", buffer = true })
keymap("x", "<leader>li", function()
	u.normal('"zy')
	inspect(fn.getreg("z"))
end, { desc = " inspect selection", buffer = true })
