local fn = vim.fn
local cmd = vim.cmd
local keymap = vim.keymap.set
local expand = vim.fn.expand
local u = require("config.utils")
--------------------------------------------------------------------------------

-- lua regex opener
keymap("n", "g/", function()
	u.normal('"zya"vi"') -- yank and keep selection for quick replacement when done
	local pattern = fn.getreg("z"):match('"(.-)"')
	local url = "https://gitspartv.github.io/lua-patterns/?pattern=" .. pattern
	fn.system("open '" .. url .. "'") -- opening method on macOS
end, { desc = " lua pattern in regex viewer", buffer = true })

-- Build / Reload Config
keymap("n", "<leader>r", function()
	cmd.update()
	local pwd = vim.loop.cwd() or ""
	if pwd:find("nvim") then
		-- unload from lua cache (assuming that the pwd is parent of the lua folder)
		local packageName = expand("%:r"):gsub("lua/", ""):gsub("/", ".")
		package.loaded[packageName] = nil 
		cmd.source()
		vim.notify("re-sourced:\n"..expand("%:r"))
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
		local hsApplescript =
			string.format('tell application "Hammerspoon" to execute lua code "hs.alert(%s)"', str)
		fn.system("osascript -e '" .. hsApplescript .. "'")
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
		vim.notify("Neither in nvim nor in hammerspoon directory.", u.error)
	end
end

-- stylua: ignore
keymap("n", "<leader>li", function() inspect(expand("<cWORD>")) end, { desc = " inspect cWORD", buffer = true })
keymap("x", "<leader>li", function()
	u.normal('"zy')
	inspect(fn.getreg("z"))
end, { desc = " inspect selection", buffer = true })
