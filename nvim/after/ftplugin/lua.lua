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
u.ftAbbr("!== ~=")

--------------------------------------------------------------------------------

-- if in nvim dir, reload file/plugin, otherwise run `make`
keymap("n", "<leader>r", function()
	cmd("silent update")
	local isNvimConfig = vim.loop.cwd() == vim.fn.stdpath("config")
	local filepath = vim.fn.expand("%:p")

	if filepath:find("nvim/after/ftplugin/") then
		u.notify("", "ftplugins cannot be reloaded.", "warn")
	elseif filepath:find("nvim/lua/config/.*keymap") or filepath:find("nvim/lua/config/.*keybinding") then
		u.notify("", "keymaps cannot be reloaded due to `map-unique`", "warn")
	elseif filepath:find("nvim/lua/plugins/") then
		-- experimental reload of plugin-specs via lazy.nvim
		local packageName = vim.fn.expand("%:t:r")
		local pluginSpecs = require("plugins." .. packageName)
		local pluginNames = vim.tbl_map(function(spec)
			local name = spec[1]:gsub(".*/", "")
			return name
		end, pluginSpecs)
		vim.cmd.Lazy("reload " .. table.concat(pluginNames, " "))
	elseif filepath:find("/lua/") and filepath:find("nvim") then
		-- locally developed nvim plugin
		local pluginName = filepath:match(".*/(.-)/lua/")
		vim.cmd.Lazy("reload " .. pluginName)
	elseif isNvimConfig then
		-- unload from lua cache (assuming that the pwd is ~/.config/nvim)
		local packageName = expand("%:r"):gsub("lua/", ""):gsub("/", ".")
		package.loaded[packageName] = nil
		cmd.source()
		u.notify("Re-sourced", packageName)
	else
		require("funcs.maker").make("useFirst")
	end
end, { buffer = true, unique = false, desc = " Reload /  Make" })
