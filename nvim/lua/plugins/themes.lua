local g = vim.g
--------------------------------------------------------------------------------

-- INFO only the first theme will be used
local lightThemes = {
	{ "rose-pine/neovim", name = "rose-pine" },
	{ "EdenEast/nightfox.nvim", name = "dawnfox" },
	-- { "marko-cerovac/material.nvim", init = function() vim.g.material_style = "lighter" end, config = { lualine_style = "stealth" } },
	-- { "uloco/bluloco.nvim", dependencies = { "rktjmp/lush.nvim" } },
	-- { "catppuccin/nvim", name = "catppuccin" },
}

local darkThemes = {
	"folke/tokyonight.nvim",
	-- { "hardhackerlabs/theme-vim", name = "hardhacker", init = function() vim.g.hardhacker_darker = 1 end },
	-- { "loctvl842/monokai-pro.nvim", config = { filter = "ristretto" } },
	-- "rebelot/kanagawa.nvim",
	-- "glepnir/zephyr-nvim",
	-- "kvrohit/mellow.nvim",
	-- "sainnhe/everforest",
	-- "nyoom-engineering/oxocarbon.nvim",
}

g.darkTransparency = 0.90
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
