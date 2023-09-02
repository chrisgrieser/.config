local bo = vim.bo
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

require("config.utils").applyTemplateIfEmptyFile("py")

vim.keymap.set(
	"n",
	"<localleader>v",
	"<cmd>VenvSelect<CR>",
	{ buffer = true, desc = "󱥒  VenvSelect" }
)

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
abbr("<buffer> none None")
