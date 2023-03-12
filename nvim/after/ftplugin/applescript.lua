require("config.utils")
--------------------------------------------------------------------------------

keymap({ "n", "i", "x" }, "<D-s>", function()
	cmd.mkview(2)
	normal("gg=G") -- poor man's formatting
	vim.lsp.buf.format { async = false } -- still used for null-ls-codespell
	cmd.loadview(2)
	cmd.write()
end, {buffer = true, desc = "Save & Format"})


--------------------------------------------------------------------------------



-- Build
keymap("n", "<leader>r", function()
	cmd.update()
	local karabinerBuildScp = vim.env.DOTFILE_FOLDER .. "/karabiner/build-karabiner-config.js"
	local result = fn.system('osascript -l JavaScript "' .. karabinerBuildScp .. '"')
	result = result:gsub("\n$", "")
	vim.notify(result)
end, { buffer = true, desc = " npm run build" })

		cmd.AppleScriptRun()
		cmd.wincmd("p") -- switch to previous window

--------------------------------------------------------------------------------
-- AppleScript Plugin Config
-- https://github.com/mityu/vim-applescript
vim.g.applescript_config = {
	run = {
		output = {
			open_command = "8 split",
			buffer_name = "Applescript Output",
		},
	},
}

