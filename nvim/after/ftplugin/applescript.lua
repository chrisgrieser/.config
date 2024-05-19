vim.bo.commentstring = "-- %s"
vim.opt_local.comments = { ":#", ":--" }

vim.opt_local.formatoptions:append("r") -- `<CR>` in insert mode
vim.opt_local.formatoptions:append("o") -- `o` in normal mode

--------------------------------------------------------------------------------

local function abbr(lhs, rhs) vim.keymap.set("ia", lhs, rhs, { buffer = true }) end
abbr("sleep", "delay")
