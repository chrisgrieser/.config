-- BUILD SYSTEM
keymap("n", "<leader>r", function()
	cmd.update()
	local parentFolder = expand("%:p:h")
	local ft = bo.filetype

	-- sketchybar
	if parentFolder:find("sketchybar") then
		-- HACK for https://github.com/FelixKratz/SketchyBar/issues/322
		fn.system([[brew services restart sketchybar]])

		---@diagnostic disable: param-type-mismatch
		--stylua: ignore
		vim.defer_fn(function ()
			fn.system([[osascript -l JavaScript "$DOTFILE_FOLDER/utility-scripts/dismiss-notification.js"]])
		end, 2000)
		---@diagnostic enable: param-type-mismatch


	-- Karabiner
	elseif ft == "yaml" and parentFolder:find("/karabiner") then
		local karabinerBuildScp = vim.env.DOTFILE_FOLDER .. "/karabiner/build-karabiner-config.js"
		local result = fn.system('osascript -l JavaScript "' .. karabinerBuildScp .. '"')
		result = result:gsub("\n$", "")
		vim.notify(result)

	-- Typescript
	elseif ft == "typescript" then
		cmd.redir("@z")
		-- silent, to not show up message (redirection still works)
		-- make-command run is defined in bo.makeprg in the typescript ftplugin
		cmd([[silent make]])
		local output = fn.getreg("z"):gsub(".-\r", "") -- remove first line
		local logLevel = output:find("error") and logError or logTrace
		vim.notify(output, logLevel)
		cmd.redir("END")

	-- AppleScript
	elseif ft == "applescript" then
		cmd.AppleScriptRun()
		cmd.wincmd("p") -- switch to previous window

	-- None
	else
		vim.notify("No build system set.", logWarn)
	end
end, { desc = "Build System" })
