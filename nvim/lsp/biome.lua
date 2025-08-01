-- FIX
-- `biome` does not attach on the first buffer of startup, due to the `root_dir`
-- function by nvim-lspconfig using `cwd`, which is running before auto-rooting
-- automcmds become active. Simply using the root markers fixes that.
return {
	root_markers = { "biome.json", "biome.jsonc" },
}
