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

