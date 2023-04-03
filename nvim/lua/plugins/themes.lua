local g = vim.g
--------------------------------------------------------------------------------

-- INFO order defines themes
-- - first theme used for light mode
-- - second for dark mode
-- - rest ignored
-- - if only one theme, it's used for both light and dark
local themes = {
	-- "EdenEast/nightfox.nvim",
	{ "rose-pine/neovim", name = "rose-pine" },
	-- "sainnhe/everforest",
	-- "rebelot/kanagawa.nvim",
	"glepnir/zephyr-nvim",
	-- "folke/tokyonight.nvim",
	-- "NTBBloodbath/sweetie.nvim",
	-- "nyoom-engineering/oxocarbon.nvim",
	-- "savq/melange",
}

g.darkTransparency = 0.91
g.lightTransparency = 0.93

--------------------------------------------------------------------------------

-- The purpose of this is not having to manage two lists, once with themes
-- to install and one for determining light/dark theme

-- the light/dark values are used in config/theme-config.lua for properly
-- setting up the themes

---convert lazy.nvim-plugin-spec or github-repo into theme name
---@param repo string|table either github-repo or plugin-spec with github-repo as first item
---@nodiscard
---@return string name of the color scheme
local function getName(repo)
	-- either first item, or name-key
	if type(repo) == "table" then repo = repo.name or repo[1] end
	local name = repo:gsub(".*/", ""):gsub("[.%-]?nvim", ""):gsub("neovim%-?", "")
	return name
end

g.lightTheme = getName(themes[1])
g.darkTheme = #themes == 1 and g.lightTheme or getName(themes[2])

-- account for special names
if g.lightTheme == "nightfox" then g.lightTheme = "dawnfox" end

--------------------------------------------------------------------------------

return themes
