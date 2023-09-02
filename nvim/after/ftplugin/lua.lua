local cmd = vim.cmd
local keymap = vim.keymap.set
local expand = vim.fn.expand
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

-- habits from writing too much in other languages
abbr("<buffer> // --")
abbr("<buffer> # --")
abbr("<buffer> const local")
abbr("<buffer> fi end")

--------------------------------------------------------------------------------

-- if in nvim dir, reload file, otherwise run `make`
keymap("n", "<leader><r>", function()
	local pwd = vim.loop.cwd() or ""
	if not pwd:find("nvim") then
		require("funcs.maker").make()
		return
	end
	cmd("silent update")
	-- unload from lua cache (assuming that the pwd is ~/.config/nvim)
	local packageName = expand("%:r"):gsub("lua/", ""):gsub("/", ".")
	package.loaded[packageName] = nil
	cmd.source()
	vim.notify("re-sourced:\n" .. expand("%:r"))
end, { buffer = true, desc = "  Reload/Make" })
