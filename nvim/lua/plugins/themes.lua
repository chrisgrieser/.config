-- https://dotfyle.com/neovim/colorscheme/top
--------------------------------------------------------------------------------

-- INFO only the first theme will be used
local lightThemes = {
	{ "EdenEast/nightfox.nvim", name = "dawnfox" },
	-- { "uloco/bluloco.nvim", dependencies = { "rktjmp/lush.nvim" } },
}

local darkThemes = {
	-- { "folke/tokyonight.nvim", opts = { style = "moon", lualine_bold = true } },
	-- { "binhtran432k/dracula.nvim", opts = { lualine_bold = true } },
	"sainnhe/gruvbox-material",
	-- "fynnfluegge/monet.nvim",
	-- "rebelot/kanagawa.nvim",
	-- { "sainnhe/sonokai", init = function() vim.g.sonokai_style = "shusia" end },
}

vim.g.lightOpacity = 0.92
vim.g.darkOpacity = 0.95

--------------------------------------------------------------------------------

-- INFO The purpose of this is not having to manage two lists, one with themes
-- to install and one for determining light/dark theme

---convert lazy.nvim-plugin-spec or github-repo into theme name
---@param repo string|table either github-repo or plugin-spec with github-repo as first item
---@nodiscard
---@return string name of the color scheme
local function getName(repo)
	if type(repo) == "table" then repo = repo.name or repo[1] end
	local name = repo:gsub(".*/", ""):gsub("[.%-]?n?vim$", ""):gsub("neovim%-?", "")
	return name
end

vim.g.lightTheme = getName(lightThemes[1])
vim.g.darkTheme = getName(darkThemes[1])

--------------------------------------------------------------------------------

local allThemes = vim.iter(vim.list_extend(darkThemes, lightThemes))
	:map(function(theme)
		local themeObj = type(theme) == "string" and { theme } or theme
		local useTheme =
			vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait().stdout:find("Dark")
		themeObj.lazy = useTheme -- main theme not lazy-loaded https://lazy.folke.io/spec/lazy_loading#-colorschemes
		themeObj.priority = useTheme and 1000 or nil
		return themeObj
	end)
	:totable()

return allThemes -- return for lazy.nvim
