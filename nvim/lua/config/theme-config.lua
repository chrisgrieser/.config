require("config.utils")
local g = vim.g
--------------------------------------------------------------------------------

-- INFO not using `api.nvim_set_hl` yet as it overwrites an update group instead
-- of overwriting it

---@param hlgroupfrom string
---@param hlgroupto string
local function linkHighlight(hlgroupfrom, hlgroupto)
	Cmd.highlight { "def link " .. hlgroupfrom .. " " .. hlgroupto, bang = true }
end

---@param hlgroup string
---@param changes string
local function setHighlight(hlgroup, changes) Cmd.highlight(hlgroup .. " " .. changes) end

---@param hlgroup string
local function clearHighlight(hlgroup) Cmd.highlight("clear " .. hlgroup) end

--------------------------------------------------------------------------------

-- SIGN-COLUMN ICONS
local signIcons = { Error = "", Warn = "▲", Info = "", Hint = "" }
for type, icon in pairs(signIcons) do
	local hl = "DiagnosticSign" .. type
	Fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

--------------------------------------------------------------------------------

local function customHighlights()
	-- stylua: ignore
	local highlights = { "DiagnosticUnderlineError", "DiagnosticUnderlineWarn", "DiagnosticUnderlineHint", "DiagnosticUnderlineInfo", "SpellLocal", "SpellRare", "SpellCap", "SpellBad" }
	for _, v in pairs(highlights) do
		setHighlight(v, "gui=underdouble cterm=underline")
	end

	setHighlight("urls", "cterm=underline gui=underline")
	Fn.matchadd("urls", [[http[s]\?:\/\/[[:alnum:]%\/_#.\-?:=&@+~]*]])

	linkHighlight("myAnnotations", "Todo")
	-- stylua: ignore
	Fn.matchadd( "myAnnotations", [[\<\(NOTE\|REQUIRED\|BUG\|WARN\|WIP\|TODO\|HACK\|INFO\|FIX\|CAVEAT\|DEPRECATED\)\>]])

	setHighlight("Overnesting", "guibg=#E06C75")
	Fn.matchadd("Overnesting", ("\t"):rep(8) .. "\t*")

	setHighlight("TSRainbowred", "guifg=#7e8a95") -- rainbow brackets without aggressive red
	setHighlight("MatchParen", "gui=underdotted,bold cterm=underline,bold") -- more visible matchparens
	linkHighlight("CodiVirtualText", "Comment") -- Codi
	setHighlight("TSDefinition", " term=underline gui=underdotted") -- treesittter refactor focus
	setHighlight("TSDefinitionUsage", " term=underline gui=underdotted")
	setHighlight("QuickScopePrimary", "gui=reverse cterm=reverse")
	setHighlight("QuickScopeSecondary", "gui=underdouble cterm=underline")

	-- HACK for https://github.com/neovim/neovim/issues/20456
	-- linkHighlight("luaParenError.highlight", "NormalFloat")
	-- linkHighlight("luaParenError", "NormalFloat")
end

--------------------------------------------------------------------------------

local function themeModifications()
	local mode = vim.opt.background:get()
	local theme = g.colors_name
	local vimModes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }
	-- FIX lualine_a not getting bold in some themes
	for _, v in pairs(vimModes) do
		setHighlight("lualine_a_" .. v, "gui=bold")
	end

	-- tokyonight
	if theme == "tokyonight" then
		for _, v in pairs(vimModes) do
			setHighlight("lualine_y_diff_modified_" .. v, "guifg=#acaa62")
			setHighlight("lualine_y_diff_added_" .. v, "guifg=#8cbf8e")
		end
		setHighlight("GitSignsChange", "guifg=#acaa62")
		setHighlight("GitSignsAdd", "guifg=#7fcc82")

		-- oxocarbon
	elseif theme == "oxocarbon" then
		linkHighlight("FloatTitle", "TelescopePromptTitle")
		linkHighlight("@function", "@function.builtin")

		-- sweetie
	elseif theme == "sweetie" and mode == "light" then
		linkHighlight("ScrollView", "Visual")
		linkHighlight("NotifyINFOIcon", "@string")
		linkHighlight("NotifyINFOTitle", "@string")
		linkHighlight("NotifyINFOBody", "@string")

		-- blueloco
	elseif theme == "bluloco" then
		setHighlight("ScrollView", "guibg=#303d50")
		setHighlight("ColorColumn", "guibg=#2e3742")

		-- kanagawa
	elseif theme == "kanagawa" then
		setHighlight("ScrollView", "guibg=#303050")
		setHighlight("VirtColumn", "guifg=#323036")
		linkHighlight("MoreMsg", "Folded") -- FIX for https://github.com/rebelot/kanagawa.nvim/issues/89

		clearHighlight("SignColumn")
		-- stylua: ignore
		local noBackground = { "GitSignsAdd", "GitSignsDelete", "GitSignsChange", "DiagnosticSignHint", "DiagnosticSignInfo", "DiagnosticSignWarn", "DiagnosticSignError" }
		for _, hlGroup in pairs(noBackground) do
			setHighlight(hlGroup, "guibg=NONE")
		end

		-- zephyr
	elseif theme == "zephyr" then
		setHighlight("IncSearch", "guifg=#FFFFFF")
		linkHighlight("TabLineSel", "lualine_a_normal")
		linkHighlight("TabLineFill", "lualine_c_normal")

		-- dawnfox
	elseif theme == "dawnfox" then
		setHighlight("IndentBlanklineChar", "guifg=#e3d4c4")
		setHighlight("ColorColumn", "guibg=#ebe1d5")
		setHighlight("VertSplit", "guifg=#b29b84")
		setHighlight("ScrollView", "guibg=#303050")
		for _, v in pairs(vimModes) do
			setHighlight("lualine_y_diff_modified_" .. v, "guifg=#b3880a")
		end

		-- melange
	elseif theme == "melange" and mode == "light" then
		linkHighlight("Todo", "IncSearch")
		linkHighlight("NonText", "Conceal")
		linkHighlight("NotifyINFOIcon", "@define")
		linkHighlight("NotifyINFOTitle", "@define")
		linkHighlight("NotifyINFOBody", "@define")
	end
end

--------------------------------------------------------------------------------

Autocmd("ColorSchemePre", {
	callback = function()
		-- everforest requires change before setting colorscheme
		local mode = vim.opt.background:get()
		local theme = g.colors_name
		if theme == "everforest" and mode == "light" then
			g.everforest_background = "soft"
		elseif theme == "everforest" and mode == "dark" then
			g.everforest_background = "hard"
		end
	end,
})
Autocmd("ColorScheme", {
	callback = function()
		-- HACK defer needed for some modifications to properly take effect
		for _, delayMs in pairs { 50, 100, 200 } do
			vim.defer_fn(customHighlights, delayMs) ---@diagnostic disable-line: param-type-mismatch
			vim.defer_fn(themeModifications, delayMs) ---@diagnostic disable-line: param-type-mismatch
		end
	end,
})

--------------------------------------------------------------------------------

---@param mode string "dark"|"light"
function SetThemeMode(mode)
	vim.opt.background = mode
	g.neovide_transparency = mode == "dark" and g.darkTransparency or g.lightTransparency
	Cmd.highlight("clear") -- needs to be set before colorscheme https://github.com/folke/lazy.nvim/issues/40
	local targetTheme = mode == "dark" and g.darkTheme or g.lightTheme
	Cmd.colorscheme(targetTheme)
end

-- initialize theme on startup
local isDarkMode = Fn.system([[defaults read -g AppleInterfaceStyle]]):find("Dark")
local targetMode = isDarkMode and "dark" or "light"
SetThemeMode(targetMode)
