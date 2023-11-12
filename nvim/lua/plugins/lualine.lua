--# selene: allow(mixed_table) -- lazy.nvim uses them
local bo = vim.bo
local fn = vim.fn
--------------------------------------------------------------------------------

local function irregularWhitespace()
	if bo.buftype ~= "" then return "" end

	-- CONFIG
	local spaceFiletypes = { python = 4, yaml = 2, query = 2 }

	local spaceFtsOnly = vim.tbl_keys(spaceFiletypes)
	local spacesInsteadOfTabs = bo.expandtab and not vim.tbl_contains(spaceFtsOnly, bo.ft)
	local differentSpaceAmount = bo.expandtab and spaceFiletypes[bo.ft] ~= bo.tabstop
	local tabsInsteadOfSpaces = not bo.expandtab and vim.tbl_contains(spaceFtsOnly, bo.ft)

	if spacesInsteadOfTabs or differentSpaceAmount then
		return "󱁐 " .. tostring(bo.tabstop)
	elseif tabsInsteadOfSpaces then
		return "󰌒 " .. tostring(bo.tabstop)
	end
	return ""
end

local function quickfixCounter()
	local totalQfItems = #vim.fn.getqflist()
	if totalQfItems == 0 then return "" end
	local qfData = vim.fn.getqflist { idx = 0, title = true }
	local title = qfData.title
		:gsub("^Live Grep: .- %((.*)%)", 'Grep: "%1"')
		:gsub("^Find Word %((.-)%) ?%(?%)?", 'Grep: "%1"')
	local index = qfData.idx
	return (" %s/%s (%s)"):format(index, totalQfItems, title)
end

--------------------------------------------------------------------------------

local bottomSep = { left = "", right = "" } -- nerdfont-powerline icons have prefix 'ple-'
local topSep = { left = "", right = "" }

local lualineConfig = {
	tabline = {
		-- INFO using the tabline will override vim's default tabline, so the tabline
		-- should always include the tab element
		lualine_a = {
			{
				"datetime",
				style = "%H:%M",
				cond = function() return vim.o.columns > 110 and vim.o.lines > 25 end,
				section_separators = topSep,
				-- make the `:` blink
				fmt = function(time) return os.time() % 2 == 0 and time or time:gsub(":", " ") end,
			},
			{
				"tabs",
				mode = 1,
				max_length = vim.o.columns * 0.6,
				section_separators = topSep,
				cond = function() return fn.tabpagenr("$") > 1 end,
			},
		},
		lualine_b = {
			{
				"navic",
				cond = function() return bo.filetype ~= "css" end,
				section_separators = topSep,
			},
		},
	},
	sections = {
		lualine_a = {
			{
				"branch",
				cond = function()
					-- show branch only when not in main/master
					local curBranch = require("lualine.components.branch.git_branch").get_branch()
					local notMainBranch = curBranch ~= "main" and curBranch ~= "master"
					local notSpecialBuffer = bo.buftype == ""
					return notMainBranch and notSpecialBuffer
				end,
			},
			{ "filetype", icon_only = true, colored = false, padding = { right = 0, left = 1 } },
			{ "filename", file_status = false, shortening_target = 30 },
		},
		lualine_b = {
			{ function() return require("funcs.alt-alt").altFileStatusline { maxLen = 20 } end },
		},
		lualine_c = {
			{ quickfixCounter },
		},
		lualine_x = {
			{
				"diagnostics",
				symbols = { error = "󰅚 ", warn = " ", info = "󰋽 ", hint = "󰘥 " },
			},
			{
				"fileformat",
				cond = function() return bo.fileformat ~= "unix" end,
				fmt = function(str) return str .. " 󰌑" end,
			},
			{ irregularWhitespace },
		},
		lualine_y = {
			"diff",
		},
		lualine_z = {
			{ "selectioncount", fmt = function(str) return str ~= "" and "礪" .. str or "" end },
			"location",
		},
	},
	options = {
		refresh = { statusline = 1000 },
		globalstatus = true,
		component_separators = { left = "", right = "" },
		section_separators = bottomSep,
		-- stylua: ignore
		ignore_focus = {
			"DressingInput", "DressingSelect", "lspinfo", "aerial",
			"ccc-ui", "TelescopePrompt", "checkhealth",
			"noice", "lazy", "mason", "qf", "toggleterm",
		},
	},
}

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	lazy = false, -- no flickering on startup
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = lualineConfig,
}
