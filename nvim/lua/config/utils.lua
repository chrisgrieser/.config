local M = {}
--------------------------------------------------------------------------------

-- vim.env reads from .zshenv
M.vimDataDir = vim.env.DATA_DIR .. "/vim-data/"
M.linterConfigFolder = vim.env.DOTFILE_FOLDER .. "/_linter-configs/"

---runs :normal natively with bang
---@param cmdStr string
function M.normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---@param str string
---@param filePath string line(s) to add
---@param mode "w"|"a" -- write or append
---@return string|nil error
---@nodiscard
function M.writeToFile(filePath, str, mode)
	local file, error = io.open(filePath, mode)
	if not file then return error end
	file:write(str .. "\n")
	file:close()
end

---send notification
---@param msg string
---@param title string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
function M.notify(title, msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = title })
end

---reads a template to apply if the file is empty. Add to a filetype config to
---activate templates for it
---@param ext string extension of the skeleton
function M.applyTemplateIfEmptyFile(ext)
	-- prevent buggy duplicate application of template
	if vim.b.templateWasApplied then return end
	vim.b.templateWasApplied = true ---@diagnostic disable-line: inject-field

	vim.defer_fn(function()
		local filename = vim.fn.expand("%")
		local fileExists = vim.loop.fs_stat(filename) ~= nil
		if not fileExists then return end

		local skeletonFile = vim.fn.stdpath("config") .. "/templates/skeleton." .. ext
		local skeletonExists = vim.loop.fs_stat(skeletonFile) ~= nil
		if not skeletonExists then
			vim.notify("Skeleton file not found.", vim.log.levels.ERROR)
			return
		end

		local fileIsEmpty = vim.loop.fs_stat(filename).size < 4 -- account for linebreaks
		if not fileIsEmpty then return end

		vim.cmd("silent keepalt 0read " .. skeletonFile)
		M.normal("G")
	end, 1)
end

--------------------------------------------------------------------------------

---https://www.reddit.com/r/neovim/comments/oxddk9/comment/h7maerh/
---@param name string name of highlight group
---@param key "fg"|"bg"
---@nodiscard
---@return string|nil the value, or nil if hlgroup or key is not available
function M.getHighlightValue(name, key)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name })
	if not ok then return end
	local value = hl[key]
	if not value then return end
	return string.format("#%06x", value)
end

---Creates autocommand triggered by Colorscheme change, that modifies a
---highlight group. Mostly useful for setting up colorscheme modifications
---specific to plugins, that should persist across colorscheme changes triggered
---by switching between dark and light mode.
---@param hlgroup string
---@param modification string|object
---@return nil
function M.colorschemeMod(hlgroup, modification)
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function() vim.api.nvim_set_hl(0, hlgroup, modification) end,
	})
end

---set up subkey for the <leader> key (if whichkey is loaded)
---@param key string
---@param label string
function M.leaderSubkey(key, label)
	local ok, whichKey = pcall(require, "which-key")
	if ok then whichKey.register { ["<leader>" .. key] = { name = " " .. label } } end
end

---Adds a component to the lualine after lualine was already set up. Useful for
---lazyloading.
---@param component function|table the component forming the lualine
---@param location "tabline"|"sections" tabline = top, sections = bottom
---@param section "lualine_a"|"lualine_b"|"lualine_c"|"lualine_x"|"lualine_y"|"lualine_z"
function M.addToLuaLine(location, section, component)
	local topSeparators = { left = "", right = "" }

	local ok, lualine = pcall(require, "lualine")
	if not ok then return end
	local sectionConfig = lualine.get_config()[location][section] or {}

	local componentObj = type(component) == "table" and component or { component }
	if location == "tabline" then componentObj.section_separators = topSeparators end
	table.insert(sectionConfig, componentObj)
	lualine.setup {
		[location] = { [section] = sectionConfig },
	}

	-- Theming needs to be re-applied, since the lualine-styling can change
	require("config.theme-customization").reloadTheming()
end

--------------------------------------------------------------------------------

---Sets the global BorderStyle variable and the matching BorderChars Variable.
---See also https://neovim.io/doc/user/api.html#nvim_open_win()
---(BorderChars is needed for Harpoon and Telescope, both of which do not accept
---a Borderstyle string.)

M.borderStyle = "single"

if M.borderStyle == "single" then
	M.borderChars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
	M.borderHorizontal = "─"
elseif M.borderStyle == "double" then
	M.borderChars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
	M.borderHorizontal = "═"
elseif M.borderStyle == "rounded" then
	M.borderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	M.borderHorizontal = "─"
end

--------------------------------------------------------------------------------

M.textobjectRemaps = {
	c = "}", -- [c]urly brace
	r = "]", -- [r]ectangular bracket
	m = "W", -- [m]assive word
	q = '"', -- [q]uote
	z = "'", -- [z]ingle quote
	e = "`", -- t[e]mplate string / inline cod[e]
}

M.textobjectMaps = {
	["function"] = "f",
	["conditional"] = "o",
	["call"] = "l",
	["doubleSquareBracket"] = "R",
}

--------------------------------------------------------------------------------

return M
