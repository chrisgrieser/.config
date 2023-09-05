local cmd = vim.cmd
local keymap = vim.keymap.set
local expand = vim.fn.expand
local abbr = vim.cmd.inoreabbrev
local u = require("config.utils")
--------------------------------------------------------------------------------

-- habits from writing too much in other languages
abbr("<buffer> // --")
abbr("<buffer> # --")
abbr("<buffer> const local")
abbr("<buffer> fi end")

--------------------------------------------------------------------------------

-- if in nvim dir, reload file, otherwise run `make`
keymap("n", "<leader>r", function()
	---@diagnostic disable-next-line: undefined-field
	local pwd = vim.loop.cwd() or ""
	if not pwd:find("nvim") then
		require("funcs.maker").make()
		return
	end
	cmd("silent update")

	if pwd:find("nvim/lua/plugins/") then 
	else
		-- unload from lua cache (assuming that the pwd is ~/.config/nvim)
		local packageName = expand("%:r"):gsub("lua/", ""):gsub("/", ".")
		package.loaded[packageName] = nil
		cmd.source()
		u.notify("Re-sourced", expand("%:r"))
	end
end, { buffer = true, desc = "  Reload/Make" })
