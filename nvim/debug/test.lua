local ns = vim.api.nvim_create_namespace("tinygit.test")
vim.fn.matchadd(
	"conventionalCommits",
	[[feat]]
)
vim.api.nvim_set_hl(ns, "conventionalCommits", { link = "Title" })

vim.fn.matchadd("Warning", [[\w\+.lua:\d\+:]])


