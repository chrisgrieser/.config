local bin_path = os.getenv("HOME") .. "/.codeium/bin"
local oldBinaries = vim.fs.find(
	"language_server_macos_arm",
	{ type = "file", limit = math.huge, path = bin_path }
)
vim.notify("🪚 oldBinaries: " .. vim.inspect(oldBinaries))

