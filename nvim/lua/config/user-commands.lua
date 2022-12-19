require("config/utils")
local newCommand = vim.api.nvim_create_user_command
--------------------------------------------------------------------------------

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

-- `:SwapDelete` delete the swapfile
newCommand("SwapDelete", function(_)
	local success, err = os.remove(fn.swapname(0))
	if success then
		vim.notify("Swap File deleted.")
	else
		vim.notify(tostring(err), logError)
	end
end, {})

-- `:PackerRoot` opens path where packer packages are installed
newCommand("PackerRoot", function(_)
	fn.system('open "' .. fn.stdpath("data") .. '/site/pack/packer"')
end, {})

-- `:II` inspects the passed object and puts it into a new buffer, https://www.reddit.com/r/neovim/comments/zhweuc/comment/izo9br1/?utm_source=share&utm_medium=web2x&context=3
newCommand("II", function(ctx)
	local output = vim.inspect(fn.luaeval(ctx.args))
	local lines = vim.split(output, "\n", { plain = true }) ---@diagnostic disable-line: param-type-mismatch
	cmd.vsplit()
	cmd.ene()
	api.nvim_buf_set_lines(0, 0, -1, false, lines)
	os.remove("/tmp/nvim-cmd-output")
	cmd.write { "/tmp/nvim-cmd-output", bang = true }
end, { nargs = "+" })
