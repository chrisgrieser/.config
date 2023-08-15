local cmd = vim.cmd
local keymap = vim.keymap.set
local u = require("config.utils")
--------------------------------------------------------------------------------

u.applyTemplateIfEmptyFile("applescript")

-- https://github.com/echasnovski/mini.operators/blob/main/doc/mini-operators.txt#L214
vim.b.minioperators_config = {
	evaluate = {
		-- TODO this only works for linewise textobjs, not yet charwise.
		func = function(content)
			local lines = table.concat(content.lines, "\n")
			-- INFO osascript evaluates the last line as if it were logged, also in
			-- AppleScript, single quotes are invalid, making it unnecessary to
			-- escape the lines
			local shellCmd = "osascript -l AppleScript -e '" .. lines .. "'"
			local evaluatedOut = vim.fn.system(shellCmd):gsub("\n$", "")
			return evaluatedOut
		end,
	},
}

--------------------------------------------------------------------------------

-- poor man's formatting
keymap({ "n", "i", "x" }, "<D-s>", function()
	cmd.mkview(2)
	u.normal("gg=G")
	vim.lsp.buf.format { async = false } -- still used for null-ls-codespell
	cmd.loadview(2)
	cmd.write()
end, { buffer = true, desc = "Save & Format" })
