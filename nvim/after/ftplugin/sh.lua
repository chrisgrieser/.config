require("config.utils")
-- INFO vim.filetype.add()

--------------------------------------------------------------------------------

-- pipe textobj

--stylua: ignore
keymap({ "o", "x" }, "iP", function() require("various-textobjs").shellPipe(true) end, { desc = "inner shellPipe textobj", buffer = true })
--stylua: ignore
keymap({ "o", "x" }, "aP", function() require("various-textobjs").shellPipe(false) end, { desc = "outer shellPipe textobj", buffer = true })

--------------------------------------------------------------------------------
-- Reload Sketchybar
keymap("n", "<leader>r", function()
	cmd.update()
	local parentFolder = expand("%:p:h")

	if parentFolder:find("sketchybar") then
		fn.system([[brew services restart sketchybar]])

		-- dismiss notification, HACK for https://github.com/FelixKratz/SketchyBar/issues/322
		--stylua: ignore
		---@diagnostic disable: param-type-mismatch
		vim.defer_fn(function() fn.system([[osascript -l JavaScript "$DOTFILE_FOLDER/utility-scripts/dismiss-notification.js"]]) end, 2000)
	else
		local output = fn.system("zsh '" .. expand("%:p").. "'")
		local logLevel = vim.v.shell_error > 0 and logError or logTrace
		vim.notify(output, logLevel)
	end
end, { buffer = true, desc = " Run Shell Script" })
