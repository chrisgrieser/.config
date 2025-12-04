-- DOCS https://github.com/nvim-lualine/lualine.nvim#default-configuration
--------------------------------------------------------------------------------

---Adds a component lualine was already set up. This enables lazy-loading
---plugins that add statusline components.
---(Accessed via `vim.g`, as this file's exports are used by `lazy.nvim`.)
---@param whichBar "tabline"|"winbar"|"inactive_winbar"|"sections"
---@param whichSection "lualine_a"|"lualine_b"|"lualine_c"|"lualine_x"|"lualine_y"|"lualine_z"
---@param component function|table the component forming the lualine
---@param where "after"|"before"? defaults to "after"
vim.g.lualineAdd = function(whichBar, whichSection, component, where) ---@diagnostic disable-line: duplicate-set-field for the empty functions in `lazy.nvim` setup
	vim.defer_fn(function() -- deferred so other plugins do not load lualine too early
		local componentObj = type(component) == "table" and component or { component }
		local sectionConfig = require("lualine").get_config()[whichBar][whichSection] or {}
		local pos = where == "before" and 1 or #sectionConfig + 1
		table.insert(sectionConfig, pos, componentObj)
		require("lualine").setup { [whichBar] = { [whichSection] = sectionConfig } }
	end, 1000)
end

local function hasSplit()
	if vim.bo.buftype ~= "" then return false end
	local winsInTab = vim.api.nvim_tabpage_list_wins(0)
	local splits = vim.iter(winsInTab)
		:filter(function(win) return vim.api.nvim_win_get_config(win).split ~= nil end)
		:totable()
	return #splits > 1
end

-- not using lualins's component since it reqquires `web-devicons`
local function addFiletypeIcon(filename)
	if filename == "[No Name]" and vim.bo.ft ~= "" then filename = vim.bo.ft end -- fix name for special buffers
	local ok, icons = pcall(require, "mini.icons")
	if not ok then return filename end
	local icon, _, isDefault = icons.get("file", filename)
	if isDefault then icon = icons.get("filetype", vim.bo.ft) end
	return icon .. " " .. filename
end

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = "echasnovski/mini.icons",
	opts = {
		options = {
			globalstatus = true, -- false = one statusline per window
			always_divide_middle = false,
			section_separators = { left = "", right = "" }, -- save space
			component_separators = { left = "", right = "" },
			ignore_focus = { "snacks_input", "snacks_picker_input" },
		},
		--------------------------------------------------------------------------
		winbar = {
			lualine_b = {
				{ "filename", fmt = addFiletypeIcon, cond = hasSplit, file_status = false },
			},
		},
		inactive_winbar = {
			lualine_c = {
				{ "filename", fmt = addFiletypeIcon, cond = hasSplit, file_status = false },
			},
		},
		--------------------------------------------------------------------------
		tabline = {
			lualine_a = {
				{
					"datetime",
					style = "%H:%M:%S",
					-- make the `:` blink
					fmt = function(time) return time:gsub(":", os.time() % 2 == 0 and " " or ":") end,
					cond = function() return vim.o.columns > 120 end, -- only if window is maximized
				},
			},
			lualine_x = {
				-- HACK dummy, so tabline is never empty (in which case vim adds its ugly tabline)
				{ function() return " " end },
			},
			lualine_z = {
				{
					function() return "Recording…" end,
					icon = "󰃽",
					cond = function() return vim.fn.reg_recording() ~= "" end,
				},
			},

		},
		--------------------------------------------------------------------------
		sections = {
			lualine_a = {
				{
					"branch",
					icon = "",
					cond = function() -- only if not on `main` or `master`
						local curBranch = require("lualine.components.branch.git_branch").get_branch()
						return curBranch ~= "main" and curBranch ~= "master"
					end,
				},
				{
					"filename",
					fmt = addFiletypeIcon,
					shorting_target = 30,
					file_status = false, -- modification status irrelevant, since auto-saving
					newfile_status = true,
				},
			},
			lualine_b = {
				{ require("personal-plugins.magnet").altFileStatusbar },
			},
			lualine_c = {
				{ require("personal-plugins.magnet").mostChangedFileStatusbar },
			},
			lualine_x = {
				{ -- Quickfix counter
					function()
						local qf = vim.fn.getqflist { idx = 0, title = true, size = true }
						if qf.size == 0 then return "" end
						return ("%d/%d (%s)"):format(qf.idx, qf.size, qf.title)
					end,
					icon = "",
				},
				{
					"fileformat",
					icon = "󰌑",
					cond = function() return vim.bo.fileformat ~= "unix" end,
				},
				{
					"diagnostics",
					cond = function() return vim.diagnostic.is_enabled { bufnr = 0 } end,
					symbols = (function() -- use icons from `vim.diagnostic.config()`
						local icons = vim.diagnostic.config().signs.text or { "E", "W", "I", "H" }
						return { error = icons[1], warn = icons[2], info = icons[3], hint = icons[4] }
					end)(),
				},
				{
					"lsp_status",
					ignore_lsp = { "typos_lsp", "efm", "stylua" },
					cond = function() -- only show component if LSP is active
						if vim.g.lualine_lsp_active == nil then -- create autocmd only once
							vim.g.lualine_lsp_active = false
							vim.api.nvim_create_autocmd("LspProgress", {
								desc = "User: Hide LSP progress component after 2s",
								callback = function()
									vim.g.lualine_lsp_active = true
									vim.defer_fn(function() vim.g.lualine_lsp_active = false end, 2000)
								end,
							})
						end
						return vim.g.lualine_lsp_active
					end,
				},
			},
			lualine_y = {}, -- empty to remove %-progress in file
			lualine_z = {
				{ "selectioncount", icon = "󰒆" },
				{ -- line count
					function() return vim.api.nvim_buf_line_count(0) end,
					icon = "",
					cond = function() return vim.bo.buftype == "" end,
				},
				{ "location" },
			},
		},
	},
}
