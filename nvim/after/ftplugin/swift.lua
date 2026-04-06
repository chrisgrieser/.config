-- formatters prescribe comments being separated by two spaces
vim.opt_local.listchars:append { multispace = " " }

vim.opt_local.shiftwidth = 3
vim.opt_local.expandtab = false

--------------------------------------------------------------------------------

BufAbbr("--", "//")
BufAbbr("local", "let")
BufAbbr("const", "let")
