local javaHome = vim.fs.find(
	function (name) return vim.startswith(name, "jdk-") end,
	{ path = vim.fn.stdpath("data") .. "/mason/packages/ltex-ls/", type = "directory" }
)[1]
vim.notify("👽 javaHome: " .. tostring(javaHome))
