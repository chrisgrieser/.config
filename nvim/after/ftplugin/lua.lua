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
	cmd("silent update")
	---@diagnostic disable-next-line: undefined-field
	local isNvimConfig = vim.loop.cwd() == vim.fn.stdpath("config")
	local filepath = vim.fn.expand("%:p")

	if not isNvimConfig then
		require("funcs.maker").make()
		return
	elseif filepath:find("nvim/after/ftplugin/") then
		u.notify("", "ftplugins cannot be reloaded.", "warn")
	elseif filepath:find("nvim/lua/plugins/") then
		-- experimental reload of plugin-specs via lazy.nvim
		local packageName = vim.fn.expand("%:t:r")
		local pluginSpecs = require("plugins." .. packageName)
		local pluginNames = vim.tbl_map(function(spec)
			local name = spec[1]:gsub(".*/", "")
			return name
		end, pluginSpecs)
		vim.cmd.Lazy("reload " .. table.concat(pluginNames, " "))
	else
		-- unload from lua cache (assuming that the pwd is ~/.config/nvim)
		local packageName = expand("%:r"):gsub("lua/", ""):gsub("/", ".")
		package.loaded[packageName] = nil
		cmd.source()
		u.notify("Re-sourced", expand("%:r"))
	end
end, { buffer = true, desc = "  Reload/Make" })
