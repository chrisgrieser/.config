require("utils")
--------------------------------------------------------------------------------

local lightTheme = "melange"
local darkTheme = "tokyonight-moon"

--------------------------------------------------------------------------------

-- CUSTOM HIGHLIGHTS
-- have to wrapped in function and regularly called due to auto-dark-mode
-- regularly resetting the theme
local function customHighlights()
	local highlights = {
		"DiagnosticUnderlineError",
		"DiagnosticUnderlineWarn",
		"DiagnosticUnderlineHint",
		"DiagnosticUnderlineInfo",
		"SpellLocal",
		"SpellRare",
		"SpellCap",
		"SpellBad",
	}
	for _, v in pairs(highlights) do
		cmd("highlight " .. v .. " gui=underline")
	end

	-- active indent
	cmd [[highlight! def link IndentBlanklineContextChar Comment]]

	-- URLs
	cmd [[highlight urls cterm=underline term=underline gui=underline]]
	fn.matchadd("urls", [[http[s]\?:\/\/[[:alnum:]%\/_#.\-?:=&]*]])

	-- rainbow brackets without agressive red…
	cmd [[highlight rainbowcol1 guifg=#7e8a95]] -- no aggressively red brackets…

	-- treesittter refactor focus
	cmd [[highlight TSDefinition term=underline gui=underdotted]]
	cmd [[highlight TSDefinitionUsage term=underline gui=underdotted]]

	-- Custom Highlight-Group, used for various LSP Hints
	cmd [[highlight GhostText guifg=#7c7c7c]]

	-- bugfix for https://github.com/neovim/neovim/issues/20456
	cmd [[highlight! def link luaParenError NormalFloat]]
end

customHighlights() -- run once to apply them

--------------------------------------------------------------------------------

---@param mode string light|dark
function themeModifications(mode)
	if g.colors_name == "tokyonight" then
		local modes = {"normal", "visual", "insert", "terminal", "replace", "command", "inactive"}
		for _, v in pairs(modes) do
			cmd("highlight lualine_y_diff_modified_" .. v .. " guifg=#acaa62")
			cmd("highlight lualine_y_diff_added_" .. v .. " guifg=#8cbf8e")
		end
	elseif g.colors_name == "dawnfox" then
		cmd [[highlight IndentBlanklineChar guifg=#deccba]]
		cmd [[highlight VertSplit guifg=#b29b84]]
	elseif g.colors_name == "melange" and mode == "light" then
		cmd [[highlight def link @punctuation @label]]
		cmd [[highlight! def link Todo IncSearch]]
		cmd [[highlight! def link NotifyINFOIcon @define]]
		cmd [[highlight! def link NotifyINFOTitle @define]]
		cmd [[highlight! def link NotifyINFOBody @define]]
	end
end

local function light()
	api.nvim_set_option("background", "light")
	cmd("colorscheme " .. lightTheme)
	g.neovide_transparency = 0.96
	customHighlights()
	themeModifications("light")
end

--
local function dark()
	api.nvim_set_option("background", "dark")
	cmd("colorscheme " .. darkTheme)
	g.neovide_transparency = 0.97
	customHighlights()
	themeModifications("dark")
end

-- toggle theme with OS
local auto_dark_mode = require("auto-dark-mode")
auto_dark_mode.setup {
	update_interval = 3000, ---@diagnostic disable-line: assign-type-mismatch
	set_dark_mode = dark,
	set_light_mode = light,
}
auto_dark_mode.init()

