-- lightweight replacement for fidget.nvim
local progressText = ""
local function lspProgress() return progressText end

vim.api.nvim_create_autocmd("LspProgress", {
	callback = function(ctx)
		local clientName = vim.lsp.get_client_by_id(ctx.data.client_id).name
		local progress = ctx.data.params.value ---@type {percentage: number, title?: string, kind: string, message?: string}
		if not (progress and progress.title) then return end

		local icons = { "󰫃", "󰫄", "󰫅", "󰫆", "󰫇", "󰫈" } -- CONFIG
		local idx = math.floor(#icons / 2)
		if progress.percentage == 0 then idx = 1 end
		if progress.percentage and progress.percentage > 0 then
			idx = math.ceil(progress.percentage / 100 * #icons)
		end
		local firstWord = vim.split(progress.title, " ")[1]:lower()

		local text = table.concat({ icons[idx], clientName, firstWord }, " ")
		progressText = progress.kind == "end" and "" or text
	end,
})

--------------------------------------------------------------------------------

local function irregularWhitespace()
	if vim.bo.buftype ~= "" then return "" end

	-- CONFIG
	local spaceFiletypes = { python = 4, yaml = 2, query = 2, just = 4 }

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

local function quickfixCounter()
	local qf = vim.fn.getqflist { idx = 0, title = true, items = true }
	if #qf.items == 0 then return "" end

	qf.title = qf -- prettify telescope's title output
		.title
		:gsub("^Live Grep: .-%((.+)%)", "%1") -- remove telescope prefixes
		:gsub("^Find Files: .-%((.+)%)", "%1")
		:gsub("^Find Word %((.-)%) %b()", "%1")
		:gsub(" %(%)", "") -- empty brackets
		:gsub("%-%-[%w-_]+ ?", "") -- remove flags from `makeprg`
	return (" %s/%s %q"):format(qf.idx, #qf.items, qf.title)
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
	return "󰌑 ?"
end

--------------------------------------------------------------------------------

local lualineConfig = {
	options = {
		globalstatus = true,
		always_divide_middle = false,
		section_separators = { left = "", right = "" }, -- nerdfont-powerline icons prefix: `ple-`
		component_separators = { left = "", right = "" },
		-- stylua: ignore
		ignore_focus = {
			"DressingInput", "DressingSelect", "lspinfo", "ccc-ui", "TelescopePrompt",
			"checkhealth", "noice", "mason", "qf", "lazy",
		},
	},
	tabline = {
		lualine_a = {
			{
				"datetime",
				style = " %H:%M:%S",
				cond = function() return vim.o.columns > 120 end, -- if window is maximized
				fmt = function(time)
					local timeWithBlinkingColon = os.time() % 2 == 0 and time or time:gsub(":", " ")
					return timeWithBlinkingColon
				end,
				padding = { left = 0, right = 1 },
			},
		},
		lualine_c = {
			-- HACK spacer so the tabline is never empty (in which case vim adds its ugly tabline)
			{ function() return " " end, padding = { left = 0, right = 0 } },
		},
		lualine_z = {
			{ -- recording status
				function() return "雷Recording…" end,
				cond = function() return vim.fn.reg_recording() ~= "" end,
				color = function() return "DiagnosticError" end,
			},
		},
	},
	sections = {
		lualine_a = {
			{
				"branch",
				cond = function()
					-- only if not on main or master
					local curBranch = require("lualine.components.branch.git_branch").get_branch()
					return curBranch ~= "main" and curBranch ~= "master" and vim.bo.buftype == ""
				end,
			},
			{ -- .venv indicator
				function() return "󱥒" end,
				cond = function() return vim.env.VIRTUAL_ENV and vim.bo.ft == "python" end,
				padding = { left = 1, right = 0 },
			},
			{ filenameAndIcon },
		},
		lualine_b = {
			{ require("funcs.alt-alt").altFileStatus },
		},
		lualine_c = {
			{ quickfixCounter },
		},
		lualine_x = {
			{ lspProgress },
			{
				"diagnostics",
				symbols = { error = "󰅚 ", warn = " ", info = "󰋽 ", hint = "󰘥 " },
			},
			{ newlineCharIfNotUnix },
			{ irregularWhitespace },
		},
		lualine_y = {
			{ "diff" },
			{ -- line count
				function() return vim.api.nvim_buf_line_count(0) .. " " end,
				cond = function() return vim.bo.buftype == "" end,
			},
		},
		lualine_z = {
			{ "selectioncount", fmt = function(str) return str ~= "" and "礪" .. str or "" end },
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
---@param whereInSection? "before"|"after" defaults to "after"
vim.g.lualine_add = function(whichBar, whichSection, component, whereInSection)
	local ok, lualine = pcall(require, "lualine")
	if not ok then return end
	local sectionConfig = lualine.get_config()[whichBar][whichSection] or {}

	local componentObj = type(component) == "table" and component or { component }
	if whereInSection == "before" then
		table.insert(sectionConfig, 1, componentObj)
	else
		table.insert(sectionConfig, componentObj)
	end
	lualine.setup { [whichBar] = { [whichSection] = sectionConfig } }

	-- Theming needs to be re-applied, since the lualine-styling can change
	require("config.theme-customization").themeModifications()
end

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	lazy = false, -- at once, so UI does not flicker
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = lualineConfig,
}
