local u = require("config.utils")
--------------------------------------------------------------------------------

-- habits from writing too much in other languages
u.ftAbbr("//", "--")
u.ftAbbr("const", "local")
u.ftAbbr("fi", "end")
u.ftAbbr("!=", "~=")
u.ftAbbr("!==", "~=")
u.ftAbbr("===", "==")

-- shorthands
u.ftAbbr("ree", "return end")
u.ftAbbr("tree", "then return end")

vim.opt_local.comments = {
	":---", -- luadoc
	":-- *", -- lists in comments
	":--",
}

--------------------------------------------------------------------------------

-- if in nvim dir, reload file/plugin, otherwise run `make`
vim.keymap.set("n", "<leader>m", function()
	vim.cmd("silent! update")

	-- :make
	local isNvimConfig = vim.loop.cwd() == vim.fn.stdpath("config")
	if not isNvimConfig then
		vim.cmd.lmake()
		return
	end

	-- reload nvim-file
	local filepath = vim.api.nvim_buf_get_name(0)
	if vim.fs.basename(filepath) == "test.lua" then
		vim.cmd.source()
	elseif filepath:find("nvim/after/ftplugin/") then
		u.notify("", "ftplugins cannot be reloaded. Just `:edit` buffer again.", "warn")
	elseif filepath:find("nvim/lua/.*keymap") or filepath:find("nvim/lua/.*keybinding") then
		u.notify("", "keymaps cannot be reloaded due to `map-unique`", "warn")
	elseif isNvimConfig then
		-- unload from lua cache (assuming that the pwd is ~/.config/nvim)
		local packageName = vim.fn.expand("%:r"):gsub("lua/", ""):gsub("/", ".")
		package.loaded[packageName] = nil
		vim.cmd.source()
		u.notify("Re-sourced", packageName)
	end
end, { buffer = true, desc = " Reload /  Make" })
