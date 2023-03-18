require("config.utils")
--------------------------------------------------------------------------------

Keymap({ "n", "i", "x" }, "<D-s>", function()
	Cmd.mkview(2)
	Normal("gg=G") -- poor man's formatting
	vim.lsp.buf.format { async = false } -- still used for null-ls-codespell
	Cmd.loadview(2)
	Cmd.write()
end, { buffer = true, desc = "Save & Format" })

--------------------------------------------------------------------------------

-- Build
Keymap("n", "<leader>r", Cmd.AppleScriptRun, { buffer = true, desc = " Run Applescript" })

vim.g.applescript_config = { -- https://github.com/mityu/vim-applescript
	run = {
		output = {
			open_command = "7 split",
			buffer_name = "Applescript Output",
		},
	},
}

Autocmd("FileType", {
	pattern = "AppleScriptRunOutput",
	callback = function()
		vim.opt_local.wrap = true	
	end,
})
