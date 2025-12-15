-- FIX escaping of values in selectionwhen in lua
-- PENDING https://github.com/olimorris/codecompanion.nvim/issues/2525
return {
	get = function(args)
		local selection = args.context.code
		if args.context.filetype == "lua" then selection = vim.pesc(selection) end
		return selection
	end,
}
