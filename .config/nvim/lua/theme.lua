require("utils")
local styler = require("styler")
local auto_dark_mode = require("auto-dark-mode")
local currentTheme = g.colors_name
--------------------------------------------------------------------------------

local darkThemes = {
	default = "tokyonight-moon",
	yaml = "melange",
	lua = "onedark",
}

local lightThemes = {
	default = "dawnfox",
	yaml = "melange",
	lua = "dawnfox",
}

local stylerLightThemes = {}
for ft, theme in pairs(lightThemes) do
	if not (ft == "default") then
		stylerLightThemes[ft] = {
			colorscheme = theme,
			background = "light",
		}
	end
end

local stylerDarkThemes = {}
for ft, theme in pairs(darkThemes) do
	if not (ft == "default") then
		stylerDarkThemes[ft] = {
			colorscheme = theme,
			background = "dark",
		}
	end
end

--------------------------------------------------------------------------------

-- CUSTOM HIGHLIGHTS & Theme Modifications
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

---@param mode string light|dark
local function themeModifications(mode)
	if currentTheme == "tokyonight" then
		local modes = {"normal", "visual", "insert", "terminal", "replace", "command", "inactive"}
		for _, v in pairs(modes) do
			cmd("highlight lualine_y_diff_modified_" .. v .. " guifg=#acaa62")
			cmd("highlight lualine_y_diff_added_" .. v .. " guifg=#8cbf8e")
		end
	elseif currentTheme == "dawnfox" then
		cmd [[highlight IndentBlanklineChar guifg=#deccba]]
		cmd [[highlight VertSplit guifg=#b29b84]]
	elseif currentTheme == "melange" and mode == "light" then
		cmd [[highlight def link @punctuation @label]]
		cmd [[highlight! def link Todo IncSearch]]
		cmd [[highlight! def link NotifyINFOIcon @define]]
		cmd [[highlight! def link NotifyINFOTitle @define]]
		cmd [[highlight! def link NotifyINFOBody @define]]
	end
end

--------------------------------------------------------------------------------
-- AUTO DARK MODE

-- toggle theme with OS
auto_dark_mode.setup {
	update_interval = 3000, ---@diagnostic disable-line: assign-type-mismatch
	set_dark_mode = function()
		api.nvim_set_option("background", "dark")
		cmd("colorscheme " .. darkThemes.default)
		g.neovide_transparency = 0.97
		themeModifications("dark")
	end,
	set_light_mode = function()
		api.nvim_set_option("background", "light")
		cmd("colorscheme " .. lightThemes.default)
		g.neovide_transparency = 0.96
		themeModifications("light")
	end,
}
auto_dark_mode.init()

--------------------------------------------------------------------------------

customHighlights() -- run once to apply them

augroup("themeChange", {})
autocmd("ColorScheme", {
	group = "themeChange",
	callback = function ()
		customHighlights()
		local mode = api.nvim_get_option(name)
	end,
})

