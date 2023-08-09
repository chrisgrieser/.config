local g = vim.g
--------------------------------------------------------------------------------

-- INFO only the first theme will be used
local lightThemes = {
	{ "EdenEast/nightfox.nvim", name = "dawnfox" },
	-- {
	-- 	"marko-cerovac/material.nvim",
	-- 	init = function() vim.g.material_style = "lighter" end,
	-- opts = { lualine_style = "stealth", high_visibility = { lighter = false } },
	-- },
	-- { "catppuccin/nvim", name = "catppuccin" },
	-- { "rose-pine/neovim", name = "rose-pine" },
}

local darkThemes = {
	"sainnhe/gruvbox-material",
	"folke/tokyonight.nvim",
	-- "sainnhe/everforest",
	-- "rebelot/kanagawa.nvim",
	-- "nvimdev/zephyr-nvim",
	-- "kvrohit/mellow.nvim",
	-- "nyoom-engineering/oxocarbon.nvim",
}

g.darkTransparency = 0.92
g.lightTransparency = 0.93

--------------------------------------------------------------------------------

-- DOCS
-- The purpose of this is not having to manage two lists, one with themes
-- to install and one for determining light/dark theme

---convert lazy.nvim-plugin-spec or github-repo into theme name
---@param repo string|table either github-repo or plugin-spec with github-repo as first item
---@nodiscard
---@return string name of the color scheme
local function getName(repo)
	if type(repo) == "table" then repo = repo.name or repo[1] end
	local name = repo:gsub(".*/", ""):gsub("[.%-]?nvim$", ""):gsub("neovim%-?", "")
	return name
end

g.lightTheme = getName(lightThemes[1])
g.darkTheme = getName(darkThemes[1])

--------------------------------------------------------------------------------

-- merge tables & insert priority
local allThemes = {}
for _, theme in pairs(darkThemes) do
	table.insert(allThemes, theme)
end
for _, theme in pairs(lightThemes) do
	table.insert(allThemes, theme)
end

return allThemes
