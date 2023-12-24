local u = require("config.utils")
--------------------------------------------------------------------------------

-- habits from writing too much in other languages
u.ftAbbr("//", "--")
u.ftAbbr("const", "local")
u.ftAbbr("fi", "end")
u.ftAbbr("!=", "~=")
u.ftAbbr("!==", "~=")

-- shorthands
u.ftAbbr("tre", "then return end")
u.ftAbbr("ree", "return end")

--------------------------------------------------------------------------------

-- if in nvim dir, reload file/plugin, otherwise run `make`
vim.keymap.set("n", "<leader>m", function()
	vim.cmd("silent! update")
	local isNvimConfig = vim.loop.cwd() == vim.fn.stdpath("config")
	local filepath = vim.api.nvim_buf_get_name(0)

	--- GUARD
	if filepath:find("nvim/after/ftplugin/") then
		u.notify("", "ftplugins cannot be reloaded. Just `:edit` buffer again.", "warn")
		return
	elseif filepath:find("nvim/lua/.*keymap") or filepath:find("nvim/lua/.*keybinding") then
		u.notify("", "keymaps cannot be reloaded due to `map-unique`", "warn")
		return
	-- unload from lua cache (assuming that the pwd is ~/.config/nvim)
	elseif isNvimConfig then
		local packageName = vim.fn.expand("%:r"):gsub("lua/", ""):gsub("/", ".")
		package.loaded[packageName] = nil
		vim.cmd.source()
		u.notify("Re-sourced", packageName)
	-- run `make`
	else
		vim.cmd.lmake()
	end
end, { buffer = true, desc = " Reload /  Make" })
