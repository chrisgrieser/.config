-- https://codecompanion.olimorris.dev/configuration/prompt-library#external-lua-files
return {
	get = function(args)
		-- leave visual mode
		if args.context.is_visual then vim.cmd.normal { vim.fn.mode(), bang = true } end

		local selection = table.concat(args.context.lines, "\n")
		if args.context.filetype == "lua" then selection = vim.pesc(selection) end
		return selection
	end,
}
