local cmd = vim.cmd
local keymap = vim.keymap.set
local expand = vim.fn.expand
local u = require("config.utils")
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

-- habits from writing too much in other languages
abbr("<buffer> // --")
abbr("<buffer> # --")
abbr("<buffer> const local")
abbr("<buffer> fi end")

--------------------------------------------------------------------------------

-- Build / Reload Config
keymap("n", "<localleader><localleader>", function()
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
end, { buffer = true, desc = " Reload" })

