-- https://codecompanion.olimorris.dev/configuration/prompt-library#external-lua-files
return function(args)
	-- leave visual mode
	if args.context.is_visual then vim.cmd.normal { vim.fn.mode(), bang = true } end

	return table.concat(args.context.lines, "\n")
end
