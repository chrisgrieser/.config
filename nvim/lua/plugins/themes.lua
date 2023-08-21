-- INFO only the first theme will be used
local lightThemes = {
	{ "EdenEast/nightfox.nvim", name = "dawnfox" },
	-- { "rose-pine/neovim", name = "rose-pine" },
	-- {
	-- 	"marko-cerovac/material.nvim",
	-- 	init = function() vim.g.material_style = "lighter" end,
	-- 	opts = { lualine_style = "stealth", high_visibility = { lighter = false } },
	-- },
	-- { "catppuccin/nvim", name = "catppuccin" },
}

local darkThemes = {
	"folke/tokyonight.nvim",
	-- "sainnhe/gruvbox-material",
	-- "rebelot/kanagawa.nvim",
	-- { "sainnhe/sonokai", init = function() g.sonokai_style = "shusia" end },
	-- "sainnhe/everforest",
	-- "nvimdev/zephyr-nvim",
	-- "kvrohit/mellow.nvim",
	-- "nyoom-engineering/oxocarbon.nvim",
}

vim.g.darkOpacity = 0.92
vim.g.lightOpacity = 0.93

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

vim.g.lightTheme = getName(lightThemes[1])
vim.g.darkTheme = getName(darkThemes[1])

--------------------------------------------------------------------------------

-- merge tables & return for lazy.nvim
local allThemes = {}
for _, theme in pairs(darkThemes) do
	table.insert(allThemes, theme)
end
for _, theme in pairs(lightThemes) do
	table.insert(allThemes, theme)
end

return allThemes
