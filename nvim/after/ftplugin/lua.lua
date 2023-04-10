local fn = vim.fn
local cmd = vim.cmd
local keymap = vim.keymap.set
local expand = vim.fn.expand
--------------------------------------------------------------------------------

-- lua regex opener
keymap("n", "g/", function()
	normal('"zya"vi"') -- yank and keep selection for quick replacement when done
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
		vim.notify(expand("%:r") .. " re-sourced")
	elseif pwd:find("hammerspoon") then
		os.execute([[open -g "hammerspoon://hs-reload"]])
	else
		vim.notify("Neither in nvim nor in hammerspoon directory.", logError)
	end
end, { buffer = true, desc = " Reload" })

--------------------------------------------------------------------------------
-- INSPECT NVIM OR HAMMERSPOON OBJECTS

-- `:I` or `<leader>li` inspects the passed lua object / selection
local function inspect(strToInspect)
	local parentDir = expand("%:p:h")

	if parentDir:find("hammerspoon") then
		local hsApplescript =
			string.format('tell application "Hammerspoon" to execute lua code "hs.alert(%s)"', strToInspect)
		fn.system("osascript -e '" .. hsApplescript .. "'")
	elseif parentDir:find("nvim") then
		local output = vim.inspect(fn.luaeval(strToInspect))
		vim.notify(output, logTrance, {
			timeout = 7000, -- ms
			on_open = function(win) -- enable treesitter highlighting in the notification
				local buf = vim.api.nvim_win_get_buf(win)
				vim.api.nvim_buf_set_option(buf, "filetype", "lua")
			end,
		})
	else
		vim.notify("Neither in nvim nor in hammerspoon directory.", logError)
	end
end

-- stylua: ignore
keymap("n", "<leader>li", function() inspect(expand("<cWORD>")) end, { desc = " inspect cWORD", buffer = true })
keymap("x", "<leader>li", function()
	normal('"zy')
	inspect(fn.getreg("z"))
end, { desc = " inspect selection", buffer = true })
