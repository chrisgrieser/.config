require("utils")
--------------------------------------------------------------------------------

local lightTheme = "melange"
-- local lightTheme = "dawnfox"
local darkTheme = "nightfox"
-- local darkTheme = "tokyonight-moon"

--------------------------------------------------------------------------------
-- CUSTOM HIGHLIGHTS & Theme Customization

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

	-- rainbow brackets without aggressive red…
	cmd [[highlight rainbowcol1 guifg=#7e8a95]]

	-- more visible matching
	cmd [[highlight! MatchParen gui=underline cterm=underline]]

	-- treesittter refactor focus
	cmd [[highlight TSDefinition term=underline gui=underdotted]]
	cmd [[highlight TSDefinitionUsage term=underline gui=underdotted]]

	-- bugfix for https://github.com/neovim/neovim/issues/20456
	cmd [[highlight! def link luaParenError NormalFloat]]

end

local function themeModifications()
	local mode = opt.background:get()
	local theme = g.colors_name
	if theme == "tokyonight" then
		local modes = {"normal", "visual", "insert", "terminal", "replace", "command", "inactive"}
		for _, v in pairs(modes) do
			cmd("highlight lualine_y_diff_modified_" .. v .. " guifg=#acaa62")
			cmd("highlight lualine_y_diff_added_" .. v .. " guifg=#8cbf8e")
		end
		cmd("highlight GitSignsChange guifg=#acaa62")
		cmd("highlight GitSignsAdd guifg=#7fcc82")
		cmd [[highlight link ScrollView Folded]]
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

augroup("themeChange", {})
autocmd("ColorScheme", {
	group = "themeChange",
	callback = function()
		themeModifications()
		customHighlights()
	end
})

--------------------------------------------------------------------------------
-- DARK MODE / LIGHT MODE
-- functions not local, so they can be accessed via file watcher
function setDarkTheme()
	opt.background = "dark" ---@diagnostic disable-line: assign-type-mismatch
	cmd("colorscheme " .. darkTheme)
	g.neovide_transparency = 0.94
end

function setLightTheme()
	opt.background = "light" ---@diagnostic disable-line: assign-type-mismatch
	cmd("colorscheme " .. lightTheme)
	g.neovide_transparency = 0.95
end

-- automatically set dark or light mode on neovim startup (requires mac though)
local macOStheme = fn.system [[defaults read -g AppleInterfaceStyle]]:gsub("\n$", "")
if macOStheme == "Dark" then
	setDarkTheme()
else
	setLightTheme()
end
