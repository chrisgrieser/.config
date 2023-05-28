local g = vim.g
--------------------------------------------------------------------------------

-- INFO only the first theme will be used
local lightThemes = {
	{ "EdenEast/nightfox.nvim", name = "dawnfox" },
	-- { "catppuccin/nvim", name = "catppuccin" },
	-- { "marko-cerovac/material.nvim", init = function() vim.g.material_style = "lighter" end, config = { lualine_style = "stealth" } },
	-- { "rose-pine/neovim", name = "rose-pine" },
}

local darkThemes = {
	"folke/tokyonight.nvim",
	-- { "loctvl842/monokai-pro.nvim", config = { filter = "ristretto" } },
	-- "rebelot/kanagawa.nvim",
	-- "glepnir/zephyr-nvim",
	-- "kvrohit/mellow.nvim",
	-- "sainnhe/everforest",
	-- "nyoom-engineering/oxocarbon.nvim",
	-- "savq/melange",
}

g.darkTransparency = 0.90
g.lightTransparency = 0.91

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
	local name = repo:gsub(".*/", ""):gsub("[.%-]?nvim$", ""):gsub("neovim%-?", "")
	return name
end

g.lightTheme = getName(lightThemes[1])
g.darkTheme = getName(darkThemes[1])

--------------------------------------------------------------------------------

-- merge tables
local allThemes = {}
for _, theme in pairs(darkThemes) do
	table.insert(allThemes, theme)
end
for _, theme in pairs(lightThemes) do
	table.insert(allThemes, theme)
end

return allThemes
