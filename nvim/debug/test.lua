local ffff
local msg = "Lorem local dolor sit amet, officia excepteur. Lorem ipsum dolor sit amet, officia excepteur"
vim.notify(msg, vim.log.levels.INFO, {
	title = "Lorem ipsum",
	timeout = false,
})

vim.fn.matchadd("ErrorMsg", "\\s*local")
-- test: fffff
