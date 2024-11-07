-- local out = require("lspconfig").util.available_servers()

local text = [[
fsfsfsf
fsfsfsf
fsfsfsf
fsfsfsf
]]


vim.notify(text, vim.log.levels.ERROR, {
	title = "test",
	timeout = 1000,
})

