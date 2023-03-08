-- local darkTheme = "bluloco"
-- local darkTheme = "tokyonight-moon"
-- local lightTheme = "melange"
-- local darkTheme = "oxocarbon"
local lightTheme = "sweetie"
-- local darkTheme = "zephyr"
local darkTheme = "kanagawa"
-- local darkTheme = "sweetie"

local themePackages = {
	-- { "uloco/bluloco.nvim", dependencies = "rktjmp/lush.nvim" },
	-- "EdenEast/nightfox.nvim",
	-- "glepnir/zephyr-nvim",
	-- "folke/tokyonight.nvim",
	"rebelot/kanagawa.nvim",
	"NTBBloodbath/sweetie.nvim",
	-- "nyoom-engineering/oxocarbon.nvim",
	-- "savq/melange",
}

local darkTransparency = 0.93
local lightTransparency = 0.94

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

---@param hlgroupfrom string
---@param hlgroupto string
local function linkHighlight(hlgroupfrom, hlgroupto)
	vim.cmd.highlight { "def link " .. hlgroupfrom .. " " .. hlgroupto, bang = true }
end

---@param hlgroup string
---@param changes string
local function setHighlight(hlgroup, changes) vim.cmd.highlight(hlgroup .. " " .. changes) end

local function clearHighlight(hlgroup) vim.cmd.highlight("clear " .. hlgroup) end

local function customHighlights()
	-- stylua: ignore
	local highlights = { "DiagnosticUnderlineError", "DiagnosticUnderlineWarn", "DiagnosticUnderlineHint", "DiagnosticUnderlineInfo", "SpellLocal", "SpellRare", "SpellCap", "SpellBad" }
	for _, v in pairs(highlights) do
		setHighlight(v, "gui=underdouble cterm=underline")
	end

	setHighlight("urls", "cterm=underline gui=underline")
	vim.fn.matchadd("urls", [[http[s]\?:\/\/[[:alnum:]%\/_#.\-?:=&@+~]*]])
	linkHighlight("myAnnotations", "Todo")
	vim.fn.matchadd(
		"myAnnotations",
		[[\<\(BUG\|WARN\|WIP\|TODO\|HACK\|INFO\|NOTE\|FIX\|CAVEAT\|DEPRECATED\)\>]]
	)

	linkHighlight("IndentBlanklineContextChar", "Comment") -- active indent
	setHighlight("rainbowcol1", "guifg=#7e8a95") -- rainbow brackets without aggressive red
	setHighlight("MatchParen", "gui=inverse cterm=inverse") -- more visible matchparens
	linkHighlight("CodiVirtualText", "Comment") -- Codi
	setHighlight("TSDefinition", " term=underline gui=underdotted") -- treesittter refactor focus
	setHighlight("TSDefinitionUsage", " term=underline gui=underdotted")
	setHighlight("CleverFDefaultLabel", "gui=inverse cterm=inverse")

	-- HACK bugfix for https://github.com/neovim/neovim/issues/20456
	linkHighlight("luaParenError.highlight", "NormalFloat")
	linkHighlight("luaParenError", "NormalFloat")
end

local function themeModifications()
	local mode = vim.opt.background:get()
	local theme = vim.g.colors_name
	local modes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }
	-- FIX lualine_a not getting bold in some themes
	for _, v in pairs(modes) do
		setHighlight("lualine_a_" .. v, "gui=bold")
	end

	-- tokyonight
	if theme == "tokyonight" then
		-- HACK bugfix for https://github.com/neovim/neovim/issues/20456
		linkHighlight("luaParenError.highlight", "NormalFloat")
		linkHighlight("luaParenError", "NormalFloat")
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
		setHighlight("GitSignsAdd", "guibg=NONE")
		setHighlight("GitSignsDelete", "guibg=NONE")
		setHighlight("GitSignsChange", "guibg=NONE")

		-- zephyr
	elseif theme == "zephyr" then
		setHighlight("IncSearch", "guifg=#FFFFFF")
		linkHighlight("TabLineSel", "lualine_a_normal")
		linkHighlight("TabLineFill", "lualine_c_normal")

		-- dawnfox
	elseif theme == "dawnfox" then
		setHighlight("IndentBlanklineChar", "guifg=#deccba")
		setHighlight("VertSplit", "guifg=#b29b84")
		setHighlight("ScrollView", "guibg=#303050")
		-- linkHighlight("@field.yaml", "@field") -- HACK https://github.com/EdenEast/nightfox.nvim/issues/314

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

vim.api.nvim_create_augroup("themeChange", {})
vim.api.nvim_create_autocmd("ColorScheme", {
	group = "themeChange",
	callback = function()
		-- HACK defer needed for some modifications to properly take effect
		for _, delayMs in pairs { 50, 100, 200 } do
			vim.defer_fn(customHighlights, delayMs) ---@diagnostic disable-line: param-type-mismatch
			vim.defer_fn(themeModifications, delayMs) ---@diagnostic disable-line: param-type-mismatch
		end
	end,
})

---@param mode string "dark"|"light"
function SetThemeMode(mode)
	vim.o.background = mode
	vim.g.neovide_transparency = mode == "dark" and darkTransparency or lightTransparency
	vim.cmd.highlight("clear") -- needs to be set before colorscheme https://github.com/folke/lazy.nvim/issues/40
	local targetTheme = mode == "dark" and darkTheme or lightTheme
	vim.cmd.colorscheme(targetTheme)
end

---to be set right after theme startup to select the right mode
function InitializeTheme()
	-- set dark or light mode on neovim startup (requires macos)
	local isDarkMode = vim.fn.system([[defaults read -g AppleInterfaceStyle]]):find("Dark")
	local targetMode = isDarkMode and "dark" or "light"
	SetThemeMode(targetMode)
end

-- return the list for lazy.nvim
return themePackages
