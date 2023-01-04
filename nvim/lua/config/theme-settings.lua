-- CONFIG
-- local lightTheme = "rose-pine"
-- local darkTheme = "rose-pine"
local lightTheme = "dawnfox"
local darkTheme = "tokyonight-moon"
-- local lightTheme = "melange"
-- local darkTheme = "oxocarbon"
local darkTransparency = 0.95
local lightTransparency = 0.94

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
require("config.utils")
---@param hlgroupfrom string
---@param hlgroupto string
local function linkHighlight(hlgroupfrom, hlgroupto)
	vim.cmd.highlight { "def link " .. hlgroupfrom .. " " .. hlgroupto, bang = true }
end

---@param hlgroup string
---@param changes string
local function setHighlight(hlgroup, changes) vim.cmd.highlight(hlgroup .. " " .. changes) end
--------------------------------------------------------------------------------

-- Annotations
linkHighlight("myAnnotations", "Todo")
fn.matchadd("myAnnotations", [[\<\(BUG\|WARN\|WIP\|TODO\|WTF\|HACK\|INFO\|NOTE\|WARNING\|FIX\|REQUIRED\)\>]])

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
		setHighlight(v, "gui=underline")
	end

	-- active indent
	linkHighlight("IndentBlanklineContextChar", "Comment")

	-- URLs
	setHighlight("urls", "cterm=underline gui=underline")
	fn.matchadd("urls", [[http[s]\?:\/\/[[:alnum:]%\/_#.\-?:=&]*]])

	-- rainbow brackets without aggressive red
	setHighlight("rainbowcol1", " guifg=#7e8a95")

	-- more visible matchparens
	setHighlight("MatchParen", " gui=underdotted cterm=underdotted")

	-- Codi
	linkHighlight("CodiVirtualText", "Comment")

	-- treesittter refactor focus
	setHighlight("TSDefinition", " term=underline gui=underdotted")
	setHighlight("TSDefinitionUsage", " term=underline gui=underdotted")
end

local function themeModifications()
	local mode = opt.background:get()
	local theme = g.colors_name

	-- tokyonight
	if theme == "tokyonight" then
		-- HACK bugfix for https://github.com/neovim/neovim/issues/20456
		linkHighlight("luaParenError.highlight", "NormalFloat")
		linkHighlight("luaParenError", "NormalFloat")

		-- linkHighlight("ScrollbarHandle", "FloatShadow")

		local modes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }
		for _, v in pairs(modes) do
			setHighlight("lualine_y_diff_modified_" .. v, "guifg=#acaa62")
			setHighlight("lualine_y_diff_added_" .. v, "guifg=#8cbf8e")
		end
		setHighlight("GitSignsChange", "guifg=#acaa62")
		setHighlight("GitSignsAdd", "guifg=#7fcc82")
		linkHighlight("ScrollView", "Folded")

	-- oxocarbon
	elseif theme == "oxocarbon" then
		linkHighlight("FloatTitle", "TelescopePromptTitle")
		linkHighlight("@function", "@function.builtin")

	-- rose-pine
	elseif theme == "rose-pine" then
		if mode == "dark" then
			linkHighlight("ScrollView", "FloatShadow")
			linkHighlight("IndentBlanklineChar", "FloatBorder")
		elseif mode == "light" then
			setHighlight("ScrollView", "guibg=#bb8861")
			linkHighlight("IndentBlanklineChar", "FloatBorder")
		end
		local blueHlgroups = {
			"@keyword",
			"@include",
			"@exception",
			"@repeat",
			"@conditional",
			"Conditional",
			"@string.escape",
		}
		for _, hlgroup in pairs(blueHlgroups) do
			setHighlight(hlgroup, "guifg=#4fa1c3")
		end

	-- kanagawa
	elseif theme == "kanagawa" then
		setHighlight("ScrollView", "guibg=#303050")
		setHighlight("VirtColumn", "guifg=#323036")
		linkHighlight("UfoFoldedBg", "Folded")

	-- dawnfox
	elseif theme == "dawnfox" then
		setHighlight("IndentBlanklineChar", "guifg=#deccba")
		setHighlight("VertSplit", "guifg=#b29b84")

	-- melange
	elseif theme == "melange" then
		linkHighlight("Todo", "IncSearch")
		if mode == "light" then
			linkHighlight("NonText", "Conceal")
			linkHighlight("NotifyINFOIcon", "@define")
			linkHighlight("NotifyINFOTitle", "@define")
			linkHighlight("NotifyINFOBody", "@define")
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
	g.neovide_transparency = darkTransparency
	cmd.highlight("clear") -- needs to be set before colorscheme https://github.com/folke/lazy.nvim/issues/40
	cmd.colorscheme(darkTheme)
end

function setLightTheme()
	opt.background = "light" ---@diagnostic disable-line: assign-type-mismatch
	g.neovide_transparency = lightTransparency
	cmd.highlight("clear")
	cmd.colorscheme(lightTheme)
end

-- set dark or light mode on neovim startup (requires macos)
local macOStheme = fn.system([[defaults read -g AppleInterfaceStyle]])
if macOStheme:find("Dark") then
	setDarkTheme()
else
	setLightTheme()
end
