local builtins = vim.fs.find(
	function(name) return name ~= "habamax.vim" end,
	{ path = vim.env.VIMRUNTIME .. "/colors", limit = math.huge }
)
vim.notify("❗ builtins: " .. vim.inspect(builtins))
