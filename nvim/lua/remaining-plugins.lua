require("utils")
--------------------------------------------------------------------------------

-- netrw
g.netrw_browse_split = 0
g.netrw_list_hide = ".*\\.DS_Store$,^./$,^../$" -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner
g.netrw_liststyle = 3 -- tree style as default
g.netrw_winsize = 30 -- width
g.netrw_localcopydircmd = "cp -r" -- so copy work with directories
cmd [[highlight! def link netrwTreeBar IndentBlankLineChar]]

--------------------------------------------------------------------------------
-- Mundo
g.mundo_width = 30
g.mundo_preview_height = 15
g.mundo_preview_bottom = 0
g.mundo_auto_preview = 1
g.mundo_right = 1 -- right side, not left

augroup("MundoConfig", {})
autocmd("FileType", {
	group = "MundoConfig",
	pattern = "Mundo",
	callback = function()
		keymap("n", "-", "/", {remap = true, buffer = true})
	end
})

--------------------------------------------------------------------------------
require("regexplainer").setup {
	mode = "narrative",
	auto = true, -- automatically show the explainer when the cursor enters a regexp

	-- filetypes (i.e. extensions) in which to run the autocommand
	filetypes = {
		"html",
		"js",
		"cjs",
		"mjs",
		"ts",
		"jsx",
		"tsx",
		"cjsx",
		"mjsx",
	},

	mappings = {
		toggle = "<leader>X",
	},
}
