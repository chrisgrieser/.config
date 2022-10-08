require("mason").setup()

g.ensureInstalledForMasson = {
	"lua-language-server",
	"yaml-language-server",
	"typescript-language-server",
	"marksman",
	"json-lsp",
	"css-lsp",
	"bash-language-server",
}

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

	-- automatically install / update on startup. If set to false nothing
	-- will happen on startup. You can use :MasonToolsInstall or
	-- :MasonToolsUpdate to install tools and check for updates.
	-- Default: true
	run_on_start = true,

	-- set a delay (in ms) before the installation starts. This is only
	-- effective if run_on_start is set to true.
	-- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
	-- Default: 0
	start_delay = 3000, -- 3 second delay
}
