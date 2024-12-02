local function irregularWhitespace()
	if vim.bo.buftype ~= "" then return "" end
	local spaceFiletypes = { python = 4, yaml = 2, query = 2, just = 4 } -- CONFIG

	local spaceFtsOnly = vim.tbl_keys(spaceFiletypes)
	local spacesInsteadOfTabs = vim.bo.expandtab and not vim.tbl_contains(spaceFtsOnly, vim.bo.ft)
	local differentSpaceAmount = vim.bo.expandtab and spaceFiletypes[vim.bo.ft] ~= vim.bo.shiftwidth
	local tabsInsteadOfSpaces = not vim.bo.expandtab and vim.tbl_contains(spaceFtsOnly, vim.bo.ft)

	if spacesInsteadOfTabs or differentSpaceAmount then
		return "󱁐 " .. vim.bo.shiftwidth
	elseif tabsInsteadOfSpaces then
		return "󰌒 " .. vim.bo.shiftwidth
	end
	return ""
end

local function filenameAndIcon()
	local maxLength = 30 --CONFIG
	local name = vim.fs.basename(vim.api.nvim_buf_get_name(0))
	local display = #name < maxLength and name or vim.trim(name:sub(1, maxLength)) .. "…"
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if not ok then return display end
	local extension = name:match("%w+$")
	local icon = devicons.get_icon(display, extension) or devicons.get_icon(display, vim.bo.ft)
	if not icon then return display end
	return icon .. " " .. display
end

local function newlineCharIfNotUnix()
	if vim.bo.fileformat == "unix" then return "" end
	if vim.bo.fileformat == "mac" then return "󰌑 " end
	if vim.bo.fileformat == "dos" then return "󰌑 " end
	error("Unknown fileformat: " .. vim.bo.fileformat)
end

--------------------------------------------------------------------------------

local lualineConfig = {
	options = {
		globalstatus = true,
		always_divide_middle = false,
		section_separators = { left = "", right = "" },
		component_separators = { left = "", right = "" },
		always_show_tabs = true,
		-- stylua: ignore
		ignore_focus = {
			"DressingInput", "DressingSelect", "ccc-ui", "TelescopePrompt",
			"checkhealth", "mason", "qf", "lazy",
		},
	},
	tabline = {
		lualine_a = {
			{
				"datetime",
				style = " %H:%M:%S",
				cond = function() return vim.o.columns > 120 end, -- if window is maximized
				-- make `:` blink
				fmt = function(time) return os.time() % 2 == 0 and time or time:gsub(":", " ") end,
				padding = { left = 0, right = 1 },
			},
		},
		lualine_b = {},
		lualine_c = {
			-- HACK so the tabline is never empty (in which case vim adds its ugly tabline)
			{ function() return " " end, padding = { left = 0, right = 0 } },
		},
		lualine_y = {
			{ -- recording status
				function() return "󰑊 Recording…" end,
				cond = function() return vim.fn.reg_recording() ~= "" end,
				color = "lualine_y_diff_removed_normal",
			},
		},
	},
	sections = {
		lualine_a = {
			{
				"branch",
				cond = function() -- only if not on main or master
					local curBranch = require("lualine.components.branch.git_branch").get_branch()
					return curBranch ~= "main" and curBranch ~= "master" and vim.bo.buftype == ""
				end,
			},
			{ filenameAndIcon },
		},
		lualine_b = {
			{ require("personal-plugins.alt-alt").altFileStatusbar },
		},
		lualine_c = {
			{ require("config.quickfix").quickfixCounterStatusbar },
		},
		lualine_x = {
			{ newlineCharIfNotUnix },
			{ irregularWhitespace },
			{
				"diagnostics",
				symbols = { error = "󰅚 ", warn = " ", info = "󰋽 ", hint = "󰘥 " },
			},
		},
		lualine_y = {},
		lualine_z = {
			{
				"selectioncount",
				fmt = function(str)
					local icon = vim.fn.mode():find("[Vv]") and "礪" or ""
					return icon .. str
				end,
			},
			{ "location" },
		},
	},
}

--------------------------------------------------------------------------------

---Adds a component to the lualine after lualine was already set up. Useful for
---lazyloading. Accessed via `vim.g`, as this file's exports are used by lazy.nvim
---@param whichBar "tabline"|"winbar"|"inactive_winbar"|"sections"
---@param whichSection "lualine_a"|"lualine_b"|"lualine_c"|"lualine_x"|"lualine_y"|"lualine_z"
---@param component function|table the component forming the lualine
---@param where "after"|"before"? defaults to "after"
vim.g.lualine_add = function(whichBar, whichSection, component, where)
	local ok, lualine = pcall(require, "lualine")
	if not ok then return end

	local sectionConfig = lualine.get_config()[whichBar][whichSection] or {}
	local componentObj = type(component) == "table" and component or { component }
	local pos = where == "before" and 1 or #sectionConfig + 1
	table.insert(sectionConfig, pos, componentObj)

	lualine.setup { [whichBar] = { [whichSection] = sectionConfig } }
end

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	event = "UIEnter", -- not `VeryLazy` so UI does not flicker
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = lualineConfig,
}
