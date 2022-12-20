require("config/utils")
--------------------------------------------------------------------------------

lightTheme = "dawnfox"
darkTheme = "tokyonight-moon"
-- lightTheme = "melange"
-- darkTheme = "oxocarbon"
-- darkTheme = "nightfox"

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
		cmd.highlight(v .. " gui=underline")
	end

	-- active indent
	cmd.highlight { "def link IndentBlanklineContextChar Comment", bang = true }

	-- URLs
	cmd.highlight([[urls cterm=underline gui=underline]])
	fn.matchadd("urls", [[http[s]\?:\/\/[[:alnum:]%\/_#.\-?:=&]*]])

	-- rainbow brackets without aggressive red…
	cmd.highlight([[rainbowcol1 guifg=#7e8a95]])

	-- more visible matching
	cmd.highlight([[MatchParen gui=underdotted cterm=underdotted]])

	-- treesittter refactor focus
	cmd.highlight([[TSDefinition term=underline gui=underdotted]])
	cmd.highlight([[TSDefinitionUsage term=underline gui=underdotted]])
end

local function themeModifications()
	local mode = opt.background:get()
	local theme = g.colors_name

	-- tokyo night
	if theme == "tokyonight" then
		-- HACK bugfix for https://github.com/neovim/neovim/issues/20456
		cmd.highlight { "def link luaParenError.highlight NormalFloat", bang = true }
		cmd.highlight { "def link luaParenError NormalFloat", bang = true }

		local modes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }
		for _, v in pairs(modes) do
			cmd.highlight("lualine_y_diff_modified_" .. v .. " guifg=#acaa62")
			cmd.highlight("lualine_y_diff_added_" .. v .. " guifg=#8cbf8e")
		end
		cmd.highlight("GitSignsChange guifg=#acaa62")
		cmd.highlight("GitSignsAdd guifg=#7fcc82")
		cmd.highlight { "def link ScrollView Folded", bang = true }

	-- oxocarbon
	elseif theme == "oxocarbon" then
		cmd.highlight { "def link FloatTitle TelescopePromptTitle", bang = true }
		cmd.highlight { "def link @function @function.builtin", bang = true } -- no bold

	-- dawnfox
	elseif theme == "dawnfox" then
		cmd.highlight([[IndentBlanklineChar guifg=#deccba]])
		cmd.highlight([[VertSplit guifg=#b29b84]])

	-- melange
	elseif theme == "melange" then
		cmd.highlight { "def link Todo IncSearch", bang = true }
		if mode == "light" then
			cmd.highlight { "def link NonText Conceal", bang = true }
			cmd.highlight { "def link NotifyINFOIcon @define", bang = true }
			cmd.highlight { "def link NotifyINFOTitle @define", bang = true }
			cmd.highlight { "def link NotifyINFOBody @define", bang = true }
		end
	end
end

augroup("themeChange", {})
autocmd("ColorScheme", {
	group = "themeChange",
	callback = function()
		themeModifications()
		customHighlights()
	end,
})

--------------------------------------------------------------------------------
-- DARK MODE / LIGHT MODE
-- functions not local, so they can be accessed via file watcher
function setDarkTheme()
	opt.background = "dark" ---@diagnostic disable-line: assign-type-mismatch
	g.neovide_transparency = 0.94
	cmd.colorscheme(darkTheme)
	-- cmd.colorscheme(darkTheme) -- HACK needs to be set twice https://github.com/folke/lazy.nvim/issues/40
end

function setLightTheme()
	opt.background = "light" ---@diagnostic disable-line: assign-type-mismatch
	g.neovide_transparency = 0.95
	cmd.colorscheme(lightTheme)
end

-- set dark or light mode on neovim startup (requires macos)
local macOStheme = fn.system([[defaults read -g AppleInterfaceStyle]]):gsub("\n$", "")
if macOStheme == "Dark" then
	setDarkTheme()
else
	setLightTheme()
end
