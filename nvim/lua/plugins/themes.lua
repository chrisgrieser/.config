-- https://dotfyle.com/neovim/colorscheme/top
--------------------------------------------------------------------------------

-- INFO only the first theme will be used
local lightThemes = {
	"sainnhe/everforest",
	-- { "folke/tokyonight.nvim", opts = { style = "day" } },
	-- {
	-- 	"marko-cerovac/material.nvim",
	-- 	init = function() vim.g.material_style = "lighter" end,
	-- 	opts = { lualine_style = "stealth", high_visibility = { lighter = false } },
	-- },
	-- { "EdenEast/nightfox.nvim", name = "dawnfox" },
}

local darkThemes = {
	"EdenEast/nightfox.nvim",
	-- { "EdenEast/nightfox.nvim", name = "duskfox" },
	-- { "folke/tokyonight.nvim", opts = { style = "moon" } },
	-- "rebelot/kanagawa.nvim",
	-- "fynnfluegge/monet.nvim",
	-- { "navarasu/onedark.nvim", opts = { style = "warm" } },
	-- "sainnhe/gruvbox-material",
	-- { "sainnhe/sonokai", init = function() vim.g.sonokai_style = "shusia" end },
}

--------------------------------------------------------------------------------

-- INFO The purpose of this is not having to manage two lists, one with themes
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

-- merge tables
local allThemes = vim.list_extend(darkThemes, lightThemes)

-- ensure themes are never lazy-loaded https://github.com/folke/lazy.nvim#-colorschemes
allThemes = vim.tbl_map(function(theme)
	local themeObj = type(theme) == "string" and { theme } or theme
	themeObj.lazy = false
	themeObj.priority = 1000
	return themeObj
end, allThemes)

-- return for lazy.nvim
return allThemes
