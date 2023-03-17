require("config.utils")
--------------------------------------------------------------------------------

-- lua regex opener
keymap("n", "g/", function()
	normal('"zya"vi"') -- yank and keep selection for quick replacement when done
	local pattern = fn.getreg("z"):match('"(.-)"')
	local url = "https://gitspartv.github.io/lua-patterns/?pattern=" .. pattern
	fn.system("open '" .. url .. "'") -- opening method on macOS
end, { desc = "Open next lua pattern in regex viewer", buffer = true })

-- Build
keymap("n", "<leader>r", function()
	cmd.update()
	local parentFolder = expand("%:p:h")
	if parentFolder:find("nvim") then
		cmd.source()
		vim.notify(expand("%:r") .. " re-sourced.")
	elseif parentFolder:find("hammerspoon") then
		os.execute([[open -g "hammerspoon://hs-reload"]])
	end
end, { buffer = true, desc = " Reload" })

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- INSPECT NVIM OR HAMMERSPOON OBJECTS

-- 1) `:I` or `<leader>li` inspects the passed lua object / selection
local function inspect(str)
	local output = vim.inspect(fn.luaeval(str))
	vim.notify(output, logTrace, {
		on_open = function(win) -- enable treesitter highlighting in the notification
			local outputIsStr = output:find('^"') and output:find('"$')
			if not outputIsStr then
				local buf = api.nvim_win_get_buf(win)
				api.nvim_buf_set_option(buf, "filetype", "lua")
			end
		end,
		timeout = 10000, -- 10 seconds
	})
end
-- stylua: ignore
keymap("n", "<leader>li", function() inspect(expand("<cWORD>")) end, { desc = " inspect cWORD", buffer = true })
keymap("x", "<leader>li", function()
	normal('"zy')
	inspect(fn.getreg("z"))
end, { desc = " inspect selection", buffer = true })

vim.api.nvim_buf_create_user_command(0, "I", function(ctx) inspect(ctx.args) end, { nargs = "+" })

-- 2) `:II` inspects the passed object and puts it into a new buffer, https://www.reddit.com/r/neovim/comments/zhweuc/comment/izo9br1/?utm_source=share&utm_medium=web2x&context=3
vim.api.nvim_buf_create_user_command(0, "II", function(ctx)
	if expand("%:p"):find("/nvim/") then
		vim.notify("Not in a nvim")
		return
	end
	os.remove("/tmp/nvim-cmd-output")
	local output = "out = " .. vim.inspect(fn.luaeval(ctx.args))
	local lines = vim.split(output, "\n", { plain = true }) ---@diagnostic disable-line: param-type-mismatch
	cmd.vsplit()
	cmd.ene()
	bo.filetype = "lua"
	api.nvim_buf_set_lines(0, 0, -1, false, lines)
	cmd.write { "/tmp/nvim-cmd-output.lua", bang = true }
end, { nargs = "+" })
