local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g

local overnestingIndent = 8
local M = {}
--------------------------------------------------------------------------------

---@param hlgroupfrom string
---@param hlgroupto string
local function linkHighlight(hlgroupfrom, hlgroupto)
	if vim.version().minor >= 9 then
		vim.api.nvim_set_hl(0, hlgroupfrom, { link = hlgroupto, default = true })
	else
		cmd.highlight { "def link " .. hlgroupto .. " " .. hlgroupfrom, bang = true }
	end
end

---INFO not using `api.nvim_set_hl` yet as it overwrites a group instead of updating it
---@param hlgroup string
---@param changes string
local function updateHighlight(hlgroup, changes) cmd.highlight(hlgroup .. " " .. changes) end

---@param hlgroup string
local function clearHighlight(hlgroup) cmd.highlight("clear " .. hlgroup) end

-- add SEMANTIC HIGHLIGHTS to themes that do not have it yet https://www.reddit.com/r/neovim/comments/12gvms4/this_is_why_your_higlights_look_different_in_90/
---@diagnostic disable-next-line: unused-function, unused-local
local function fixSemanticHighlighting()
	if vim.version().minor < 9 then return end
	local semanticToTreesitterHl = {
		["@lsp.type.namespace"] = "@namespace",
		["@lsp.type.type"] = "@type",
		["@lsp.type.class"] = "@type",
		["@lsp.type.enum"] = "@type",
		["@lsp.type.interface"] = "@type",
		["@lsp.type.struct"] = "@structure",
		["@lsp.type.parameter"] = "@parameter",
		["@lsp.type.variable"] = "@variable",
		["@lsp.type.property"] = "@property",
		["@lsp.type.enumMember"] = "@constant",
		["@lsp.type.function"] = "@function",
		["@lsp.type.method"] = "@method",
		["@lsp.type.macro"] = "@macro",
		["@lsp.type.decorator"] = "@function",
	}

	for semanticHl, treesitterHl in pairs(semanticToTreesitterHl) do
		linkHighlight(semanticHl, treesitterHl)
	end
end

--------------------------------------------------------------------------------

-- SIGN-COLUMN ICONS
local signIcons = { Error = "", Warn = "▲", Info = "", Hint = "" }
for type, icon in pairs(signIcons) do
	local hl = "DiagnosticSign" .. type
	fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

--------------------------------------------------------------------------------

local function customHighlights()
	-- stylua: ignore
	local highlights = { "DiagnosticUnderlineError", "DiagnosticUnderlineWarn", "DiagnosticUnderlineHint", "DiagnosticUnderlineInfo", "SpellLocal", "SpellRare", "SpellCap", "SpellBad" }
	for _, v in pairs(highlights) do
		updateHighlight(v, "gui=underdouble cterm=underline")
	end

	updateHighlight("urls", "cterm=underline gui=underline")
	fn.matchadd("urls", [[http[s]\?:\/\/[[:alnum:]%\/_#.\-?:=&@+~]*]])

	linkHighlight("myAnnotations", "Todo")
	-- stylua: ignore
	fn.matchadd("myAnnotations", [[\<\(NOTE\|REQUIRED\|BUG\|WARN\|WIP\|SIC\|TODO\|HACK\|INFO\|FIX\|CAVEAT\|DEPRECATED\)\>]])

	updateHighlight("Overnesting", "guibg=#E06C75")
	fn.matchadd("Overnesting", ("\t"):rep(overnestingIndent) .. "\t*")

	updateHighlight("TSRainbowred", "guifg=#7e8a95") -- rainbow brackets without aggressive red
	updateHighlight("MatchParen", "gui=underdotted,bold cterm=underline,bold") -- more visible matchparens
	updateHighlight("TSDefinition", " term=underline gui=underdotted") -- treesittter refactor focus
	updateHighlight("TSDefinitionUsage", " term=underline gui=underdotted")
	updateHighlight("QuickScopePrimary", "gui=reverse cterm=reverse")
	updateHighlight("QuickScopeSecondary", "gui=underdouble cterm=underline")
end

-- selene: allow(high_cyclomatic_complexity)
local function themeModifications()
	local mode = vim.opt.background:get()
	local theme = g.colors_name
	-- some themes do not set g.colors_name
	if not theme then theme = mode == "light" and g.lightTheme or g.darkTheme end

	local vimModes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }
	-- FIX lualine_a not getting bold in some themes
	for _, v in pairs(vimModes) do
		updateHighlight("lualine_a_" .. v, "gui=bold")
	end

	if theme == "tokyonight" then
		for _, v in pairs(vimModes) do
			updateHighlight("lualine_y_diff_modified_" .. v, "guifg=#acaa62")
			updateHighlight("lualine_y_diff_added_" .. v, "guifg=#8cbf8e")
		end
		updateHighlight("GitSignsChange", "guifg=#acaa62")
		updateHighlight("GitSignsAdd", "guifg=#7fcc82")
	elseif theme == "oxocarbon" then
		linkHighlight("FloatTitle", "TelescopePromptTitle")
		linkHighlight("@function", "@function.builtin")
	elseif theme:find("monokai") then
		linkHighlight("GitSignsChange", "@character")
		linkHighlight("@lsp.type.parameter", "@parameter")
		linkHighlight("@lsp.type.property", "@constructor")
	elseif theme == "sweetie" and mode == "light" then
		linkHighlight("ScrollView", "Visual")
		linkHighlight("NotifyINFOIcon", "@string")
		linkHighlight("NotifyINFOTitle", "@string")
		linkHighlight("NotifyINFOBody", "@string")
	elseif theme == "bluloco" then
		updateHighlight("ScrollView", "guibg=#303d50")
		updateHighlight("ColorColumn", "guibg=#2e3742")
	elseif theme == "kanagawa" then
		updateHighlight("ScrollView", "guibg=#303050")
		updateHighlight("VirtColumn", "guifg=#323036")
		clearHighlight("SignColumn")
		-- linkHighlight("MoreMsg", "Folded") -- FIX for https://github.com/rebelot/kanagawa.nvim/issues/89

		-- stylua: ignore
		local noBackground = { "GitSignsAdd", "GitSignsDelete", "GitSignsChange", "DiagnosticSignHint", "DiagnosticSignInfo", "DiagnosticSignWarn", "DiagnosticSignError" }
		for _, hlGroup in pairs(noBackground) do
			updateHighlight(hlGroup, "guibg=NONE")
		end
	elseif theme == "zephyr" then
		updateHighlight("IncSearch", "guifg=#FFFFFF")
		linkHighlight("TabLineSel", "lualine_a_normal")
		linkHighlight("TabLineFill", "lualine_c_normal")
		fixSemanticHighlighting()
	elseif theme == "dawnfox" then
		updateHighlight("IndentBlanklineChar", "guifg=#e3d4c4")
		updateHighlight("ScrollView", "guibg=#303050")
		updateHighlight("ColorColumn", "guibg=#ebe1d5")
		updateHighlight("VertSplit", "guifg=#b29b84")
		for _, v in pairs(vimModes) do
			updateHighlight("lualine_y_diff_modified_" .. v, "guifg=#b3880a")
		end
	elseif theme == "melange" and mode == "light" then
		linkHighlight("Todo", "IncSearch")
		linkHighlight("NonText", "Conceal")
		linkHighlight("NotifyINFOIcon", "@define")
		linkHighlight("NotifyINFOTitle", "@define")
		linkHighlight("NotifyINFOBody", "@define")
	elseif theme == "rose-pine" and mode == "light" then
		updateHighlight("IndentBlanklineChar", "guifg=#e3d4c4")
		updateHighlight("ScrollView", "guibg=#505030")
		updateHighlight("ColorColumn", "guibg=#eee6dc")
		updateHighlight("Headline", "gui=bold guibg=#ebe1d5")
	elseif theme == "oh-lucy" then
		updateHighlight("Todo", "guifg=#111111")
		updateHighlight("Error", "gui=NONE") -- no bold
		updateHighlight("@error", "gui=NONE")
		updateHighlight("NonText", "gui=NONE")
		updateHighlight("Visual", "gui=NONE")
		linkHighlight("@lsp.type.parameter", "@macro") -- fix for semantic hls
	end
end

--------------------------------------------------------------------------------

autocmd("ColorScheme", {
	callback = function()
		-- defer needed for some modifications to properly take effect
		for _, delayMs in pairs { 50, 200 } do
			vim.defer_fn(customHighlights, delayMs)
			vim.defer_fn(themeModifications, delayMs)
		end
	end,
})

--------------------------------------------------------------------------------

---exported for remote control via hammerspoon
---@param mode "dark"|"light"
function M.setThemeMode(mode)
	vim.opt.background = mode
	g.neovide_transparency = mode == "dark" and g.darkTransparency or g.lightTransparency
	cmd.highlight("clear") -- needs to be set before colorscheme https://github.com/folke/lazy.nvim/issues/40
	local targetTheme = mode == "dark" and g.darkTheme or g.lightTheme
	cmd.colorscheme(targetTheme)
end

-- initialize theme on startup
local isDarkMode = fn.system([[defaults read -g AppleInterfaceStyle]]):find("Dark")
local targetMode = isDarkMode and "dark" or "light"
M.setThemeMode(targetMode)

--------------------------------------------------------------------------------

return M
