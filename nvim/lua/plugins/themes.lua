local g = vim.g
--------------------------------------------------------------------------------

-- INFO order defines themes
-- - first theme used for light mode
-- - second for dark mode
-- - rest ignored
-- - if only one theme, it's used for both light and dark
local themes = {
	"EdenEast/nightfox.nvim",
	-- "sainnhe/everforest",
	-- "rebelot/kanagawa.nvim",
	"glepnir/zephyr-nvim",
	{"rose-pine/neovim", name = "rose-pine"},
	-- "folke/tokyonight.nvim",
	-- "NTBBloodbath/sweetie.nvim",
	-- "nyoom-engineering/oxocarbon.nvim",
	-- "savq/melange",
}

g.darkTransparency = 0.91
g.lightTransparency = 0.92

--------------------------------------------------------------------------------

-- The purpose of this is not having to manage two lists, once with themes 
-- to install and one for determining light/dark theme

-- the light/dark values are used in config/theme-config.lua for properly
-- setting up the themes

---convert lazy.nvim-plugin-spec or github-repo into theme name
---@param repoName string|table either github-repo or plugin-spec with github-repo as first item
---@nodiscard
---@return string name of the color scheme
local function getName(repoName)
	if type(repoName) == "table" then repoName =repoName[1] end
	repoName = repoName:gsub(".*/", ""):gsub("[.%-]?nvim", ""):gsub("neovim%-?", "")
	return repoName
end

g.lightTheme = getName(themes[1])
g.darkTheme = #themes == 1 and g.lightTheme or getName(themes[2])

-- account for special names
if g.lightTheme == "nightfox" then g.lightTheme = "dawnfox" end

--------------------------------------------------------------------------------

return themes
