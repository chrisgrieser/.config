local u = require("config.utils")
--------------------------------------------------------------------------------

-- fix my habits
u.ftAbbr("cosnt", "const")
u.ftAbbr("local", "const")
u.ftAbbr("--", "//")
u.ftAbbr("==", "===")
u.ftAbbr("~=", "!==")
u.ftAbbr("elseif", "else if")

--------------------------------------------------------------------------------

vim.keymap.set("n", "<localleader><localleader>", function()
	local toEvaluate
	if vim.fn.mode() == "n" then
		toEvaluate = vim.trim(vim.api.nvim_get_current_line())
	else
		u.normal('"zy')
		toEvaluate = vim.fn.getreg("z")
	end
	local uri = "obsidian://advanced-uri?eval=" .. toEvaluate
	vim.fn.system { "open", uri }
end)
