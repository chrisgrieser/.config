require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗"
		}
	}
})

require('mason-tool-installer').setup {
	ensure_installed = {
		"lua-language-server",
		"yaml-language-server",
		"typescript-language-server",
		"marksman",
		"json-lsp",
		"css-lsp",
		"bash-language-server",
	},
	auto_update = false,
	run_on_start = true,
	start_delay = 0, -- in ms
}
