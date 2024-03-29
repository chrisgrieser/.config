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
	local qf = vim.fn.getqflist { idx = 0, title = true, items = true }
	if #qf.items == 0 then return "" end

	local qfBuffers = vim.tbl_map(function(item) return item.bufnr end, qf.items)
	local fileCount = #vim.fn.uniq(qfBuffers) -- qf-Buffers are already sorted
	local fileStr = fileCount > 1 and (" 「%s  」"):format(fileCount) or ""

	qf.title = qf
		.title -- prettify telescope's title output
		:gsub("^Live Grep: .-%((.+)%)", "%1")
		:gsub("^Find Files: .-%((.+)%)", "%1")
		:gsub("^Find Word %((.-)%) %(.-%)", "%1")
		:gsub(" %(%)", "") -- empty brackets
		:gsub("%-%-[%w-_]+ ?", "") -- remove flags from `makeprg`
	return (' %s/%s "%s"'):format(qf.idx, #qf.items, qf.title) .. fileStr
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

-- Never show tabline, since we are showing it ourself on the winbar.
-- Cannot place the component in the tabline, since when empty, vim places its
-- ugly tabline there instead.
vim.opt.showtabline = 0

local lualineConfig = {
	winbar = {
		lualine_b = {
			{ -- using lualine's tab display, cause it looks much better than vim's
				"tabs",
				mode = 1,
				cond = function() return vim.fn.tabpagenr("$") > 1 end,
			},
		},
		lualine_c = {
			{ -- clock if window is maximized
				"datetime",
				style = " %H:%M:%S",
				cond = function()
					local maximized = vim.o.columns > 120
					local x, y = unpack(vim.api.nvim_win_get_position(0))
					local isTopLeftWin = x == 0 and y == 0
					return maximized and isTopLeftWin
				end,
				fmt = function(time)
					local timeWithBlinkingColon = os.time() % 2 == 0 and time or time:gsub(":", " ")
					return timeWithBlinkingColon
				end,
			},
		},
	},
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
			{ -- VENV indicator
				function() return "󱥒" end,
				cond = function() return vim.env.VIRTUAL_ENV and vim.bo.ft == "python" end,
				padding = { left = 1, right = 0 },
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
			-- line count
			{
				function() return vim.api.nvim_buf_line_count(0) .. " " end,
				cond = function() return vim.bo.buftype == "" end,
			},
		},
		lualine_z = {
			{ "selectioncount", fmt = function(str) return str ~= "" and "礪" .. str or "" end },
			{ "location" },
			{ -- neovim icon
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

-- always use winbar
lualineConfig.inactive_winbar = lualineConfig.winbar
--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	event = "UIEnter",
	dependencies = "nvim-tree/nvim-web-devicons",
	external_dependencies = "git",
	opts = lualineConfig,
}
