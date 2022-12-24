require("config/utils")
local newCommand = vim.api.nvim_create_user_command
--------------------------------------------------------------------------------

-- `:SwapDeleteAll` deletes all swap files
newCommand("SwapDeleteAll", function(_)
	local swapdir = vimDataDir .. "swap/"
	local out = fn.system([[rm -vf "]]..swapdir..[["* ]])
	vim.notify("Deleted:\n"..out)
end, {})

-- `:ViewDir` opens the nvim view directory
newCommand("ViewDir", function(_)
	local viewdir = expand(opt.viewdir:get())
	fn.system('open "' .. viewdir .. '"')
end, {})

-- `:PluginDir` opens the nvim data path, where mason and lazy install their stuff
newCommand("PluginDir", function(_)
	fn.system('open "' .. fn.stdpath("data") .. '"')
end, {})

-- `:I` inspects the passed lua object
newCommand("I", function(ctx)
	local output = vim.inspect(fn.luaeval(ctx.args))
	vim.notify(output, vim.log.levels.INFO, {
		-- enable highlighting in the notification
		on_open = function(win)
			local outputIsStr = output:find('^"') and output:find('"$')
			if not outputIsStr then
				local buf = api.nvim_win_get_buf(win)
				api.nvim_buf_set_option(buf, "filetype", "lua")
			end
		end,
	})
end, { nargs = "+" })

-- `:II` inspects the passed object and puts it into a new buffer, https://www.reddit.com/r/neovim/comments/zhweuc/comment/izo9br1/?utm_source=share&utm_medium=web2x&context=3
newCommand("II", function(ctx)
	local output = "out = "..vim.inspect(fn.luaeval(ctx.args))
	local lines = vim.split(output, "\n", { plain = true }) ---@diagnostic disable-line: param-type-mismatch
	cmd.vsplit()
	cmd.ene()
	api.nvim_buf_set_lines(0, 0, -1, false, lines)
	os.remove("/tmp/nvim-cmd-output.lua")
	cmd.write { "/tmp/nvim-cmd-output.lua", bang = true }
end, { nargs = "+" })
