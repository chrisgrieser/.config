require("utils")
local newCommand = vim.api.nvim_create_user_command
--------------------------------------------------------------------------------

-- `:I` inspects the passed lua object
newCommand("I", function(ctx)
	vim.pretty_print(fn.luaeval(ctx.args))
end, {nargs = "+"})

-- `:SwapDelete` delete the swapfile
newCommand("SwapDelete", function(_)
	local success, err = os.remove(fn.swapname(0))
	if success then
		vim.notify(" Swap File deleted. ")
	else
		vim.notify(tostring(err), logError)
	end
end, {})

-- `:II` inspects the passed object and puts it into a new buffer, https://www.reddit.com/r/neovim/comments/zhweuc/comment/izo9br1/?utm_source=share&utm_medium=web2x&context=3
newCommand("II", function(ctx)
	local output = fn.luaeval(ctx.args)
	local lines = vim.split(output, "\n", {plain = true}) ---@diagnostic disable-line: param-type-mismatch
	cmd.new()
	api.nvim_buf_set_lines(0, 0, -1, false, lines)
	cmd.write("/tmp/nvim-cmd-output")
end, {nargs = "+"})
