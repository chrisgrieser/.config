-- DOCS https://github.com/nvim-lualine/lualine.nvim#default-configuration-----------------------------------------------------------------------------

---Adds a component lualine was already set up. This enables lazy-loading
---plugins that add statusline components.
---(Accessed via `vim.g`, as this file's exports are used by `lazy.nvim`.)
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

local function countLspRefs()
	local icon = "󰈿" -- CONFIG
	local client = vim.lsp.get_clients({ method = "textDocument/references", bufnr = 0 })[1]
	if not client then
		vim.b.lspReferenceCount = nil
		return
	end
	local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
	params.context = { includeDeclaration = true } ---@diagnostic disable-line: inject-field
	local thisFile = params.textDocument.uri

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local sameCursorPos = row == vim.b.lspReferenceLastPos[1] and col == vim.b.lspReferenceLastPos[2]

	if not sameCursorPos then
		vim.b.lspReferenceLastRow = row
		client:request("textDocument/references", params, function(error, refs)
			if error or not refs then
				vim.b.lspReferenceCount = nil
				return
			end
			local inWorkspace = #refs
			local inFile =
				#vim.iter(refs):filter(function(ref) return thisFile == ref.uri end):totable()
			local out = icon .. " " .. inFile
			if inFile ~= inWorkspace then out = out .. "(" .. inWorkspace .. ")" end
			vim.b.lspReferenceCount = out
		end)
	end

	-- returns empty string at first and later the updated count
	return vim.b.lspReferenceCount or ""
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
			section_separators = { left = "", right = "" }, -- save space
			component_separators = { left = "", right = "" }, -- │

			-- so current file name is still visible when renaming/selecting
			ignore_focus = { "snacks_input", "snacks_picker_input" },
		},
		tabline = {
			lualine_a = {
				{
					"datetime",
					style = "%H:%M:%S",
					-- make the `:` blink
					fmt = function(time) return os.time() % 2 == 0 and time or time:gsub(":", " ") end,
					-- only if window is maximized
					cond = function() return vim.o.columns > 120 end,
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
				{ require("personal-plugins.alt-alt").mostChangedFileStatusbar },
				{ countLspRefs },
			},
			lualine_x = {
				{ -- Quickfix counter
					function()
						local qf = vim.fn.getqflist { idx = 0, title = true, items = true }
						if #qf.items == 0 then return "" end
						-- remove empty brackets and/or flags from `makeprg`
						local title = qf.title:gsub(" %(%)", ""):gsub("%-%-[%w-_]+ ?", "")
						return (" %d/%d %s"):format(qf.idx, #qf.items, title)
					end,
				},
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
				{
					"lsp_status",
					icon = "",
					ignore_lsp = { "typos_lsp", "efm" },
					-- only show component if LSP is active
					cond = function()
						if vim.g.lualine_lsp_active == nil then
							vim.g.lualine_lsp_active = false -- default
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
			lualine_y = {
				{ -- line count
					function() return vim.api.nvim_buf_line_count(0) .. " " end,
					cond = function() return vim.bo.buftype == "" end,
				},
				{ -- foldlevel
					function() return vim.o.foldlevel end,
					icon = "󰘖",
					cond = function() return vim.o.foldlevel > 0 and vim.o.foldlevel ~= 99 end,
				},
			},
			lualine_z = {
				{ "selectioncount", icon = "󰒆" },
				{ "location" },
			},
		},
	},
}
