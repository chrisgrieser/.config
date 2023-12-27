local bo = vim.bo
--------------------------------------------------------------------------------

local function irregularWhitespace()
	if bo.buftype ~= "" then return "" end

	-- CONFIG
	local spaceFiletypes = { python = 4, yaml = 2, query = 2 }

	local spaceFtsOnly = vim.tbl_keys(spaceFiletypes)
	local spacesInsteadOfTabs = bo.expandtab and not vim.tbl_contains(spaceFtsOnly, bo.ft)
	local differentSpaceAmount = bo.expandtab and spaceFiletypes[bo.ft] ~= bo.shiftwidth
	local tabsInsteadOfSpaces = not bo.expandtab and vim.tbl_contains(spaceFtsOnly, bo.ft)

	if spacesInsteadOfTabs or differentSpaceAmount then
		return "󱁐 " .. tostring(bo.shiftwidth)
	elseif tabsInsteadOfSpaces then
		return "󰌒 " .. tostring(bo.shiftwidth)
	end
	return ""
end

local function quickfixCounter()
	local totalQfItems = #vim.fn.getqflist()
	if totalQfItems == 0 then return "" end
	local qfData = vim.fn.getqflist { idx = 0, title = true }
	local title = qfData.title
		:gsub("^Live Grep: .- %((.*)%)", ' "%1"')
		:gsub("^Find Word %((.-)%) ?%(?%)?", ' "%1"')
		:gsub(" ?%(%)", "")
	local index = qfData.idx
	return (" %s/%s %s"):format(index, totalQfItems, title)
end

--------------------------------------------------------------------------------

local lualineConfig = {
	sections = {
		lualine_a = {
			{
				"branch",
				cond = function()
					if bo.buftype ~= "" then return false end
					local curBranch = require("lualine.components.branch.git_branch").get_branch()
					return curBranch ~= "main" and curBranch ~= "master"
				end,
			},
			{
				function() return "󱥒 " .. vim.fs.basename(vim.env.VIRTUAL_ENV) end,
				cond = function() return vim.env.VIRTUAL_ENV and vim.bo.ft == "python" end,
			},
			{
				"filetype",
				icon_only = true,
				colored = false,
				padding = { right = 0, left = 1 },
				component_separators = { left = "", right = "" },
			},
			{ "filename", file_status = false, shortening_target = 30 },
		},
		lualine_b = {
			{ require("funcs.alt-alt").altFileStatus },
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
			{ "diff" },
		},
		lualine_z = {
			{ "selectioncount", fmt = function(str) return str ~= "" and "礪" .. str or "" end },
			{ "location" },
			{
				"datetime",
				style = "%H:%M",
				cond = function() return vim.o.columns > 110 end,
				fmt = function(time)
					local timeWithBlinkingColon = os.time() % 2 == 0 and time or time:gsub(":", " ")
					return "󰅐 " .. timeWithBlinkingColon
				end,
			},
			{
				function() return "" end,
				cond = function() return vim.fn.has("gui_running") == 1 end, -- glyph not supported by wezterm yet
				padding = { left = 0, right = 1 },
			},
		},
	},
	options = {
		globalstatus = true,
		always_divide_middle = false,
		-- nerdfont-powerline icons prefix: ple-
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		-- stylua: ignore
		ignore_focus = {
			"DressingInput", "DressingSelect", "lspinfo", "ccc-ui", "TelescopePrompt",
			"checkhealth", "noice", "lazy", "mason", "qf",
		},
	},
}

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	event = "UIEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = lualineConfig,
}
