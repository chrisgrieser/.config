--------------------------------------------------------------------------------

-- INFO first theme used for light, second for dark
local themes = {
	"sainnhe/everforest",
	-- "rebelot/kanagawa.nvim",
	-- "EdenEast/nightfox.nvim",
	-- { "uloco/bluloco.nvim", dependencies = "rktjmp/lush.nvim" },
	-- "glepnir/zephyr-nvim",
	-- "folke/tokyonight.nvim",
	-- "NTBBloodbath/sweetie.nvim",
	-- "nyoom-engineering/oxocarbon.nvim",
	-- "savq/melange",
}

vim.g.darkTransparency = 0.90
vim.g.lightTransparency = 0.93

--------------------------------------------------------------------------------

-- The purpose of this is not having to manage two lists, once with themes 
-- to install and one for determining light/dark theme

local function getName(str) return str:gsub(".*/", ""):gsub("[.%-]?nvim", "") end
vim.g.lightTheme = getName(themes[1])
vim.g.darkTheme = #themes == 1 and vim.g.lightTheme or getName(themes[2])

-- the light/dark values are used in config/theme-config.lua for properly
-- setting up the themes

--------------------------------------------------------------------------------

return themes
