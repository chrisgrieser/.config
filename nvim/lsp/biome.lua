return {
	-- FIX `biome` does not attach on the 1st buffer of startup, due to the
	-- `root_dir` function by nvim-lspconfig using `cwd`, which is running before
	-- auto-rooting automcmds. Simply using the root markers fixes that.
	root_markers = {
		"biome.json",
		"biome.jsonc",

		-- add to make biome's json formatter available in none-js projects as well
		".git",
	},
}
