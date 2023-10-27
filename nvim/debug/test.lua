vim.opt.spelloptions = "camel"
local teststr = "improv(smartCommit): over-length highlights have priority"
local result = vim.spell.check(teststr)
print(vim.inspect(result))
