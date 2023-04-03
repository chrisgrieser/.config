require("config.utils")
--------------------------------------------------------------------------------

-- lua regex opener
Keymap("n", "g/", function()
	Normal('"zya"vi"') -- yank and keep selection for quick replacement when done
	local pattern = Fn.getreg("z"):match('"(.-)"')
	local url = "https://gitspartv.github.io/lua-patterns/?pattern=" .. pattern
	Fn.system("open '" .. url .. "'") -- opening method on macOS
end, { desc = " lua pattern in regex viewer", buffer = true })

-- Build / Reload Config
Keymap("n", "<leader>r", function()
	Cmd.update()
	local pwd = vim.loop.cwd() or ""
	if pwd:find("nvim") then
		-- unload from lua cache (assuming that the pwd is parent of the lua folder)
		local packageName = Expand("%:r"):gsub("lua/", ""):gsub("/", ".")
		package.loaded[packageName] = nil 
		Cmd.source()
		vim.notify(Expand("%:r") .. " re-sourced")
	elseif pwd:find("hammerspoon") then
		os.execute([[open -g "hammerspoon://hs-reload"]])
	else
		vim.notify("Neither in nvim nor in hammerspoon directory.", LogError)
	end
end, { buffer = true, desc = " Reload" })

--------------------------------------------------------------------------------
-- INSPECT NVIM OR HAMMERSPOON OBJECTS

-- `:I` or `<leader>li` inspects the passed lua object / selection
local function inspect(strToInspect)
	local parentDir = Expand("%:p:h")

	if parentDir:find("hammerspoon") then
		local hsApplescript =
			string.format('tell application "Hammerspoon" to execute lua code "hs.alert(%s)"', strToInspect)
		Fn.system("osascript -e '" .. hsApplescript .. "'")
	elseif parentDir:find("nvim") then
		local output = vim.inspect(Fn.luaeval(strToInspect))
		vim.notify(output, LogTrace, {
			timeout = 7000, -- ms
			on_open = function(win) -- enable treesitter highlighting in the notification
				local buf = vim.api.nvim_win_get_buf(win)
				vim.api.nvim_buf_set_option(buf, "filetype", "lua")
			end,
		})
	else
		vim.notify("Neither in nvim nor in hammerspoon directory.", LogError)
	end
end

-- stylua: ignore
Keymap("n", "<leader>li", function() inspect(Expand("<cWORD>")) end, { desc = " inspect cWORD", buffer = true })
Keymap("x", "<leader>li", function()
	Normal('"zy')
	inspect(Fn.getreg("z"))
end, { desc = " inspect selection", buffer = true })


-- :I user command
vim.api.nvim_buf_create_user_command(0, "I", function(ctx) inspect(ctx.args) end, { nargs = "+" })
