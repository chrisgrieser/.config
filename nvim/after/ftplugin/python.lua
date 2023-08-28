local bo = vim.bo
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

require("config.utils").applyTemplateIfEmptyFile("py")

vim.keymap.set("n", "<localleader><localleader>", function()
	vim.cmd.update()
	local output = vim.fn.system { "python3", vim.fn.expand("%"), "--debug" }
	if vim.v.shell_error ~= 0 then
		vim.notify(output, vim.log.levels.ERROR)
		return
	end
	vim.notify(output)
end, { buffer = true, desc = "  Run File" })

--------------------------------------------------------------------------------

-- python standard
bo.expandtab = true
bo.shiftwidth = 4
bo.tabstop = 4
bo.softtabstop = 4

vim.opt_local.listchars:append { tab = "󰌒 " }
vim.opt_local.listchars:append { lead = " " }
-- python inline comments are separated by two spaces via `black`, so multispace
-- only adds noise when displaying the dots for them
vim.opt_local.listchars:append { multispace = " " }

--------------------------------------------------------------------------------

-- fix habits
abbr("<buffer> true True")
abbr("<buffer> false False")
abbr("<buffer> // #")
abbr("<buffer> -- #")
abbr("<buffer> null None")
abbr("<buffer> nil None")
