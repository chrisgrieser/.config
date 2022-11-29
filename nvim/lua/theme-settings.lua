require("utils")
--------------------------------------------------------------------------------

local lightTheme = "melange"
local darkTheme = "tokyonight-moon"
-- local darkTheme = "kanagawa"

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

	-- bugfix for https://github.com/neovim/neovim/issues/20456
	cmd [[highlight! def link luaParenError NormalFloat]]

end

customHighlights() -- to apply on default

local function themeModifications()
	local mode = opt.background:get()
	local theme = g.colors_name
	if theme == "dracula" then
		cmd [[highlight! IndentBlanklineChar guifg=#445064]]
		cmd [[highlight! def link ScrollbarHandle IndentBlanklineChar]]
		cmd [[highlight! NonText guifg=#8f8f8f]]
		local modes = {"normal", "visual", "insert", "terminal", "replace", "command", "inactive"}
		for _, v in pairs(modes) do
			cmd("highlight lualine_y_diff_modified_" .. v .. " guifg=#dfdb5d")
		end
		cmd("highlight GitSignsChange guifg=#dfdb5d")
		cmd("highlight! def link MatchParen CursorColumn")
	elseif theme == "tokyonight" then
		local modes = {"normal", "visual", "insert", "terminal", "replace", "command", "inactive"}
		for _, v in pairs(modes) do
			cmd("highlight lualine_y_diff_modified_" .. v .. " guifg=#acaa62")
			cmd("highlight lualine_y_diff_added_" .. v .. " guifg=#8cbf8e")
		end
		cmd("highlight GitSignsChange guifg=#acaa62")
		cmd("highlight GitSignsAdd guifg=#7fcc82")
		cmd("highlight! def link UfoFoldedBg Cursor")
	elseif theme == "dawnfox" then
		cmd [[highlight IndentBlanklineChar guifg=#deccba]]
		cmd [[highlight VertSplit guifg=#b29b84]]
	elseif theme == "melange" then
		cmd [[highlight! def link Todo IncSearch]]
		if mode == "light" then
			cmd [[highlight! def link NonText Conceal]]
			cmd [[highlight! def link NotifyINFOIcon @define]]
			cmd [[highlight! def link NotifyINFOTitle @define]]
			cmd [[highlight! def link NotifyINFOBody @define]]
		end
	end
end

-- toggle theme with OS
local auto_dark_mode = require("auto-dark-mode")
auto_dark_mode.setup {
	update_interval = 2500,
	set_dark_mode = function()
		vim.o.background = "dark"
		cmd("colorscheme " .. darkTheme)
		g.neovide_transparency = 0.97
		themeModifications() -- for some reason, the ColorScheme is not triggered here, requiring the call here
		customHighlights()
	end,
	set_light_mode = function()
		vim.o.background = "light"
		cmd("colorscheme " .. lightTheme)
		g.neovide_transparency = 0.96
		themeModifications()
		customHighlights()
	end,
}
auto_dark_mode.init()

augroup("themeChange", {})
autocmd("ColorScheme", {
	group = "themeChange",
	callback = function()
		themeModifications()
		customHighlights()
	end
})
