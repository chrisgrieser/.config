vim.opt.spelloptions = "camel"
local teststr = "app"
local result = vim.spell.check(teststr)
print(vim.inspect(result))
