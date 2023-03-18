require("config.utils")
-- INFO vim.filetype.add()

--------------------------------------------------------------------------------

-- pipe textobj

--stylua: ignore
Keymap({ "o", "x" }, "iP", function() require("various-textobjs").shellPipe(true) end, { desc = "inner shellPipe textobj", buffer = true })
--stylua: ignore
Keymap({ "o", "x" }, "aP", function() require("various-textobjs").shellPipe(false) end, { desc = "outer shellPipe textobj", buffer = true })

--------------------------------------------------------------------------------
-- Reload Sketchybar
Keymap("n", "<leader>r", function()
	Cmd.update()
	local parentFolder = Expand("%:p:h")

	if parentFolder:find("sketchybar") then
		Fn.system([[brew services restart sketchybar]])

		-- dismiss notification, HACK for https://github.com/FelixKratz/SketchyBar/issues/322
		--stylua: ignore
		---@diagnostic disable: param-type-mismatch
		vim.defer_fn(function() Fn.system([[osascript -l JavaScript "$DOTFILE_FOLDER/utility-scripts/dismiss-notification.js"]]) end, 2000)
	else
		local output = Fn.system("zsh '" .. Expand("%:p").. "'")
		local logLevel = vim.v.shell_error > 0 and LogError or LogTrace
		vim.notify(output, logLevel)
	end
end, { buffer = true, desc = " Run Shell Script" })
