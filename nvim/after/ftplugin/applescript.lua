require("config.utils")
--------------------------------------------------------------------------------

keymap({ "n", "i", "x" }, "<D-s>", function()
	cmd.mkview(2)
	Normal("gg=G") -- poor man's formatting
	vim.lsp.buf.format { async = false } -- still used for null-ls-codespell
	cmd.loadview(2)
	cmd.write()
end, { buffer = true, desc = "Save & Format" })

--------------------------------------------------------------------------------

-- Build
keymap("n", "<leader>r", cmd.AppleScriptRun, { buffer = true, desc = " Run Applescript" })

vim.g.applescript_config = { -- https://github.com/mityu/vim-applescript
	run = {
		output = {
			open_command = "7 split",
			buffer_name = "Applescript Output",
		},
	},
}

autocmd("FileType", {
	pattern = "AppleScriptRunOutput",
	callback = function()
		wo.wrap = true	
	end,
})
