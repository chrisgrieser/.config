-- local lightTheme = "rose-pine"
-- local darkTheme = "rose-pine"
-- local darkTheme = "tokyonight-moon"
-- local lightTheme = "melange"
-- local darkTheme = "oxocarbon"
local lightTheme = "dawnfox"
local darkTheme = "zephyr"

local themePackages = {
	"EdenEast/nightfox.nvim",
	"glepnir/zephyr-nvim", 
	-- "folke/tokyonight.nvim",
	-- "rose-pine/neovim",
	-- "rebelot/kanagawa.nvim",
	-- "nyoom-engineering/oxocarbon.nvim",
	-- "savq/melange",
}

local darkTransparency = 0.96
local lightTransparency = 0.93

--------------------------------------------------------------------------------

function themeSettings()
	require("config.utils")
	---@param hlgroupfrom string
	---@param hlgroupto string
	local function linkHighlight(hlgroupfrom, hlgroupto)
		cmd.highlight { "def link " .. hlgroupfrom .. " " .. hlgroupto, bang = true }
	end

	---@param hlgroup string
	---@param changes string
	local function setHighlight(hlgroup, changes) cmd.highlight(hlgroup .. " " .. changes) end

	-----------------------------------------------------------------------------

	linkHighlight("myAnnotations", "Todo")
	fn.matchadd(
		"myAnnotations",
		[[\<\(BUG\|WARN\|WIP\|TODO\|WTF\|HACK\|INFO\|NOTE\|WARNING\|FIX\|REQUIRED\)\>]]
	)

	function customHighlights()
		local highlights = {
			"DiagnosticUnderlineError",
			"DiagnosticUnderlineWarn",
			"DiagnosticUnderlineHint",
				-- function not local, so they can be accessed via file watcher",
			"SpellLocal",
			"SpellRare",
			"SpellCap",
			"SpellBad",
		}
		for _, v in pairs(highlights) do
			setHighlight(v, "gui=underline cterm=underline")
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
			local modes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }
			for _, v in pairs(modes) do
				setHighlight("lualine_y_diff_modified_" .. v, "guifg=#acaa62")
				setHighlight("lualine_y_diff_added_" .. v, "guifg=#8cbf8e")
			end
			setHighlight("GitSignsChange", "guifg=#acaa62")
			setHighlight("GitSignsAdd", "guifg=#7fcc82")

		-- oxocarbon
		elseif theme == "oxocarbon" then
			linkHighlight("FloatTitle", "TelescopePromptTitle")
			linkHighlight("@function", "@function.builtin")

		-- rose-pine
		elseif theme == "rose-pine" then
			linkHighlight("IndentBlanklineChar", "FloatBorder")
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
			-- setHighlight("ScrollView", "guibg=#303050")
			setHighlight("VirtColumn", "guifg=#323036")
			linkHighlight("UfoFoldedBg", "Folded")

		-- zephyr
		elseif theme == "zephyr" then
			setHighlight("IncSearch", "guifg=#FFFFFF")
			linkHighlight("TabLineSel", "lualine_a_normal")
			linkHighlight("TabLineFill", "lualine_c_normal")

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
	---@param mode string "dark"|"light"
	function setThemeMode(mode)
		o.background = mode
		g.neovide_transparency = mode == "dark" and darkTransparency or lightTransparency
		cmd.highlight("clear") -- needs to be set before colorscheme https://github.com/folke/lazy.nvim/issues/40
		local targetTheme = mode == "dark" and darkTheme or lightTheme
		cmd.colorscheme(targetTheme)
	end

	-- set dark or light mode on neovim startup (requires macos)
	local macOStheme = fn.system([[defaults read -g AppleInterfaceStyle]])
	local targetMode = macOStheme:find("Dark") and "dark" or "light"
	setThemeMode(targetMode)
end

return themePackages
