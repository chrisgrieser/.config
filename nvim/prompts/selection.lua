-- https://codecompanion.olimorris.dev/configuration/prompt-library#external-lua-files
-- PENDING https://github.com/olimorris/codecompanion.nvim/discussions/2521
return {
	get = function(args)
		local selection = table.concat(args.context.lines, "\n")
		if args.context.filetype == "lua" then selection = vim.pesc(selection) end -- FIX non-escaped values
		return selection
	end,
}
