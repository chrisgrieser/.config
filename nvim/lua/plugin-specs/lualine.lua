-- DOCS https://github.com/nvim-lualine/lualine.nvim#default-configuration
--------------------------------------------------------------------------------

---Adds a component lualine was already set up. This enables lazy-loading
---plugins that add statusline components. (Accessed via `vim.g`, as this file's
---exports are used by `lazy.nvim`.)
---@param whichBar "tabline"|"winbar"|"inactive_winbar"|"sections"
---@param whichSection "lualine_a"|"lualine_b"|"lualine_c"|"lualine_x"|"lualine_y"|"lualine_z"
---@param component function|table the component forming the lualine
---@param where "after"|"before"? defaults to "after"
vim.g.lualineAdd = function(whichBar, whichSection, component, where)
	local componentObj = type(component) == "table" and component or { component }
	local sectionConfig = require("lualine").get_config()[whichBar][whichSection] or {}
	local pos = where == "before" and 1 or #sectionConfig + 1
	table.insert(sectionConfig, pos, componentObj)
	require("lualine").setup { [whichBar] = { [whichSection] = sectionConfig } }
end

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	event = "UIEnter", -- not `VeryLazy` so UI does not flicker
	dependencies = "echasnovski/mini.icons",
	opts = {
		options = {
			globalstatus = true,
			always_divide_middle = false,
			section_separators = { left = "", right = "" },
			component_separators = { left = "│", right = "│" },
		},
		tabline = {
			lualine_a = {
				{
					"datetime",
					style = "%H:%M:%S",
					cond = function() return vim.o.columns > 120 end, -- only if window is maximized
					-- make the `:` blink
					fmt = function(time) return os.time() % 2 == 0 and time or time:gsub(":", " ") end,
				},
			},
			lualine_b = {},
			lualine_c = {
				-- HACK dummy, so tabline is never empty (in which case vim adds its ugly tabline)
				{ function() return " " end },
			},
			lualine_y = {
				{ -- recording status
					function() return ("Recording [%s]…"):format(vim.fn.reg_recording()) end,
					icon = "󰑊",
					cond = function() return vim.fn.reg_recording() ~= "" end,
					color = "lualine_y_diff_removed_normal", -- so it has correct bg from lualine
				},
			},
		},
		sections = {
			lualine_a = {
				{
					"branch",
					icon = "",
					cond = function() -- only if not on main or master
						local curBranch = require("lualine.components.branch.git_branch").get_branch()
						return curBranch ~= "main" and curBranch ~= "master" and vim.bo.buftype == ""
					end,
				},
				{ -- file name & icon
					function()
						local maxLength = 30
						local name = vim.fs.basename(vim.api.nvim_buf_get_name(0))
						if name == "" then name = vim.bo.ft end
						if name == "" then name = "---" end
						local displayName = #name < maxLength and name
							or vim.trim(name:sub(1, maxLength)) .. "…"

						local ok, icons = pcall(require, "mini.icons")
						if not ok then return displayName end
						local icon, _, isDefault = icons.get("file", name)
						if isDefault then icon = icons.get("filetype", vim.bo.ft) end
						if vim.bo.buftype == "help" then icon = "󰋖" end

						return icon .. " " .. displayName
					end,
				},
			},
			lualine_b = {
				{ require("personal-plugins.alt-alt").altFileStatusbar },
			},
			lualine_c = {
				{ require("personal-plugins.quickfix").quickfixCounterStatusbar },
			},
			lualine_x = {
				{
					"fileformat",
					icon = "󰌑",
					cond = function() return vim.bo.fileformat ~= "unix" end,
				},
				{
					"diagnostics",
					symbols = { error = "󰅚 ", warn = " ", info = "󰋽 ", hint = "󰘥 " },
					cond = function() return vim.diagnostic.is_enabled { bufnr = 0 } end,
				},
			},
			lualine_y = {
				{ -- line count
					function() return vim.api.nvim_buf_line_count(0) .. " " end,
					cond = function() return vim.bo.buftype == "" end,
				},
			},
			lualine_z = {
				{ "selectioncount", icon = "󰒆" },
				{ "location" },
			},
		},
	},
}
