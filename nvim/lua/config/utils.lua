local M = {}
--------------------------------------------------------------------------------

---runs :normal with bang
---@param cmdStr string
function M.normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---@param msg string
---@param title string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
function M.notify(title, msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = title })
end

function M.ftAbbr(lhs, rhs)
	-- TODO update on nvim 0.10
	-- vim.keymap.set("ia", lhs, rhs, { buffer = true })
	vim.cmd.inoreabbrev(("<buffer> %s %s"):format(lhs, rhs))
end

---https://www.reddit.com/r/neovim/comments/oxddk9/comment/h7maerh/
---@param name string name of highlight group
---@param key "fg"|"bg"
---@nodiscard
---@return string|nil the value, or nil if hlgroup or key is not available
function M.getHighlightValue(name, key)
	local hl = vim.api.nvim_get_hl(0, { name = name })
	local value = hl[key]
	if not value then return end
	return ("#%06x"):format(value)
end

--------------------------------------------------------------------------------

---Creates autocommand triggered by Colorscheme change, that modifies a
---highlight group. Mostly useful for setting up colorscheme modifications
---specific to plugins, that should persist across colorscheme changes triggered
---by switching between dark and light mode.
---@param hlgroup string
---@param modification table
function M.colorschemeMod(hlgroup, modification)
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function() vim.api.nvim_set_hl(0, hlgroup, modification) end,
	})
end

---@alias vimMode "n"|"v"|"x"|"i"|"o"|"c"|"t"

---set up subkey for the <leader> key (if whichkey is loaded)
---@param key string
---@param label string
---@param modes? vimMode|vimMode[]
function M.leaderSubkey(key, label, modes)
	vim.defer_fn(function()
		local ok, whichkey = pcall(require, "which-key")
		if not ok then return end
		whichkey.register(
			{ [key] = { name = " " .. label } },
			{ prefix = "<leader>", mode = modes or "n" }
		)
	end, 2000)
end

---Adds a component to the lualine after lualine was already set up. Useful for
---lazyloading.
---@param bar "tabline"|"winbar"|"inactive_winbar"|"sections"
---@param section "lualine_a"|"lualine_b"|"lualine_c"|"lualine_x"|"lualine_y"|"lualine_z"
---@param component function|table the component forming the lualine
---@param whereInComponent? "before"|"after"
function M.addToLuaLine(bar, section, component, whereInComponent)
	local ok, lualine = pcall(require, "lualine")
	if not ok then return end
	local sectionConfig = lualine.get_config()[bar][section] or {}

	local componentObj = type(component) == "table" and component or { component }
	if whereInComponent == "before" then
		table.insert(sectionConfig, 1, componentObj)
	else
		table.insert(sectionConfig, componentObj)
	end
	lualine.setup { [bar] = { [section] = sectionConfig } }

	-- Theming needs to be re-applied, since the lualine-styling can change
	require("config.theme-customization").reloadTheming()
end

---ensures unique keymaps https://www.reddit.com/r/neovim/comments/16h2lla/can_you_make_neovim_warn_you_if_your_config_maps/
---@param modes vimMode|vimMode[]
---@param lhs string
---@param rhs string|function
---@param opts? { unique: boolean, desc: string, buffer: boolean|number, nowait: boolean, remap: boolean }
function M.uniqueKeymap(modes, lhs, rhs, opts)
	if not opts then opts = {} end
	if opts.unique == nil then opts.unique = true end
	vim.keymap.set(modes, lhs, rhs, opts)
end

--------------------------------------------------------------------------------

M.textobjRemaps = {
	c = "}", -- [c]urly brace
	r = "]", -- [r]ectangular bracket
	m = "W", -- [m]assive word
	q = '"', -- [q]uote
	z = "'", -- [z]ingle quote
	e = "`", -- t[e]mplate string / inline cod[e]
}

--------------------------------------------------------------------------------
return M
