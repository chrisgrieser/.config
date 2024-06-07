-- https://dotfyle.com/neovim/colorscheme/top
--------------------------------------------------------------------------------

-- INFO only the first theme will be used
local lightThemes = {
	"sainnhe/everforest",
	-- { "rose-pine/neovim", name = "rose-pine", opts = { variant = "dawn", styles = { italic = false } }, },
	-- { "EdenEast/nightfox.nvim", name = "dawnfox" },
	-- "cdmill/neomodern.nvim",
	-- {
	-- 	"marko-cerovac/material.nvim",
	-- 	init = function() vim.g.material_style = "lighter" end,
	-- 	opts = { lualine_style = "stealth", high_visibility = { lighter = false } },
	-- },
}

local darkThemes = {
	{ "folke/tokyonight.nvim", opts = { style = "moon", lualine_bold = true } },
	-- {
	-- 	"rose-pine/neovim",
	-- 	name = "rose-pine",
	-- 	opts = {
	-- 		variant = "moon",
	-- 		styles = { italic = false },
	-- 	},
	-- },
	-- { "cdmill/neomodern.nvim", name = "coffeecat" },
	-- "sainnhe/gruvbox-material",
	-- "fynnfluegge/monet.nvim",
	-- "binhtran432k/dracula.nvim",
	-- { "EdenEast/nightfox.nvim", name = "duskfox" },
	-- "rebelot/kanagawa.nvim",
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

local allThemes = vim.iter(vim.list_extend(darkThemes, lightThemes))
	:map(function(theme)
		local themeObj = type(theme) == "string" and { theme } or theme
		themeObj.lazy = false -- ensure themes are never lazy-loaded https://github.com/folke/lazy.nvim#-colorschemes
		themeObj.priority = 1000
		return themeObj
	end)
	:totable()

return allThemes -- return for lazy.nvim
