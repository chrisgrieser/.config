-- INFO only the first theme will be used
local lightThemes = {
	{ "sainnhe/everforest", init = function ()
		vim.g.everforest_background = 'soft'
	end },
	"folke/tokyonight.nvim",
	-- { "EdenEast/nightfox.nvim", name = "dawnfox" },
	-- {
	-- 	"marko-cerovac/material.nvim",
	-- 	init = function() vim.g.material_style = "lighter" end,
	-- 	opts = { lualine_style = "stealth", high_visibility = { lighter = false } },
	-- },
}

local darkThemes = {
	"AlexvZyl/nordic.nvim",
	-- { "navarasu/onedark.nvim", opts = { diagnostics = { darker = false } } },
	-- { "folke/tokyonight.nvim", opts = { style = "moon" } },
	-- "sainnhe/gruvbox-material",
	-- { "sainnhe/sonokai", init = function() vim.g.sonokai_style = "shusia" end },
	-- "rebelot/kanagawa.nvim",
	-- { "catppuccin/nvim", name = "catppuccin" },
}

vim.g.darkOpacity = 0.92
vim.g.lightOpacity = 0.93

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

-- return for lazy
return allThemes
