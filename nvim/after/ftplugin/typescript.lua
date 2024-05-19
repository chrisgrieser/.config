-- fix my habits
local function abbr(lhs, rhs) vim.keymap.set("ia", lhs, rhs, { buffer = true }) end

abbr("cosnt", "const")
abbr("local", "const")
abbr("--", "//")
abbr("~=", "!==")
abbr("elseif", "else if")

--------------------------------------------------------------------------------

-- add space
vim.bo.commentstring = "// %s"

-- set errorformat to tsc, but keep `make` as makeprg
local maker = vim.o.makeprg
vim.cmd.compiler("tsc")
vim.o.makeprg = maker
