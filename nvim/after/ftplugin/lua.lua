local cmd = vim.cmd
local keymap = vim.keymap.set
local expand = vim.fn.expand
local u = require("config.utils")

--------------------------------------------------------------------------------

-- habits from writing too much in other languages
u.ftAbbr("//", "--")
u.ftAbbr("const", "local")
u.ftAbbr("fi", "end")
u.ftAbbr("!=", "~=")
u.ftAbbr("!==", "~=")

-- shorthands
u.ftAbbr("tre", "then return end") -- codespell-ignore

--------------------------------------------------------------------------------

-- if in nvim dir, reload file/plugin, otherwise run `make`
keymap("n", "<leader>r", function()
	cmd("silent update")
	local isNvimConfig = vim.loop.cwd() == vim.fn.stdpath("config")
	local filepath = vim.fn.expand("%:p")

	--- GUARD
	if filepath:find("nvim/after/ftplugin/") then
		u.notify("", "ftplugins cannot be reloaded.", "warn")
		return
	elseif filepath:find("nvim/lua/.*keymap") or filepath:find("nvim/lua/.*keybinding") then
		u.notify("", "keymaps cannot be reloaded due to `map-unique`", "warn")
		return
	-- unload from lua cache (assuming that the pwd is ~/.config/nvim)
	elseif isNvimConfig then
		local packageName = expand("%:r"):gsub("lua/", ""):gsub("/", ".")
		package.loaded[packageName] = nil
		cmd.source()
		u.notify("Re-sourced", packageName)

	-- run `make`
	else
		vim.cmd.lmake()
	end
end, { buffer = true, desc = " Reload /  Make" })
