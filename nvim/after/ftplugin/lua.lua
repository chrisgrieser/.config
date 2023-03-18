require("config.utils")
--------------------------------------------------------------------------------

-- lua regex opener
Keymap("n", "g/", function()
	Normal('"zya"vi"') -- yank and keep selection for quick replacement when done
	local pattern = Fn.getreg("z"):match('"(.-)"')
	local url = "https://gitspartv.github.io/lua-patterns/?pattern=" .. pattern
	Fn.system("open '" .. url .. "'") -- opening method on macOS
end, { desc = " Open lua pattern in regex viewer", buffer = true })

-- Build
Keymap("n", "<leader>r", function()
	Cmd.update()
	local parentFolder = Expand("%:p:h")
	if parentFolder:find("nvim") then
		Cmd.source()
		vim.notify(Expand("%:r") .. " re-sourced")
	elseif parentFolder:find("hammerspoon") then
		os.execute([[open -g "hammerspoon://hs-reload"]])
	else
		vim.notify("Neither in nvim nor in hammerspoon directory.", LogError)
	end
end, { buffer = true, desc = " Reload" })

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- INSPECT NVIM OR HAMMERSPOON OBJECTS

-- 1) `:I` or `<leader>li` inspects the passed lua object / selection
local function inspect(strToInspect)
	local parentDir = Expand("%:p:h")

	if parentDir:find("hammerspoon") then
		local hsApplescript = string.format('tell application "Hammerspoon" to execute lua code "hs.alert(%s)"', strToInspect)
		Fn.system("osascript -e '" .. hsApplescript .. "'")
	elseif parentDir:find("nvim") then
		local output = vim.inspect(Fn.luaeval(strToInspect))
		vim.notify(output, LogTrace, {
			timeout = 10000, -- 10 seconds
			on_open = function(win) -- enable treesitter highlighting in the notification
				local outputIsStr = output:find('^"') and output:find('"$')
				if not outputIsStr then
					local buf = vim.api.nvim_win_get_buf(win)
					vim.api.nvim_buf_set_option(buf, "filetype", "lua")
				end
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

vim.api.nvim_buf_create_user_command(0, "I", function(ctx) inspect(ctx.args) end, { nargs = "+" })

--------------------------------------------------------------------------------

-- 2) `:II` inspects the passed object and puts it into a new buffer, https://www.reddit.com/r/neovim/comments/zhweuc/comment/izo9br1/
vim.api.nvim_buf_create_user_command(0, "II", function(ctx)
	if not (Expand("%:p"):find("nvim")) then
		vim.notify("Not in a nvim directory.", LogError)
		return
	end
	os.remove("/tmp/nvim-cmd-output")
	local output = "out = " .. vim.inspect(Fn.luaeval(ctx.args))
	local lines = vim.split(output, "\n", { plain = true }) ---@diagnostic disable-line: param-type-mismatch
	Cmd.vsplit()
	Cmd.ene()
	Bo.filetype = "lua"
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	Cmd.write { "/tmp/nvim-cmd-output.lua", bang = true }
end, { nargs = "+" })
