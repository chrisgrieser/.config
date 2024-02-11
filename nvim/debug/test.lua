local url = "file:///tmp/markdown-preview.html#for-obsidian-users"
vim.fn.system {
	"open",
	"-a",
	"Brave Browser",
	url,
}
