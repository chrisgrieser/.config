local bo = vim.bo
local u = require("config.utils")
--------------------------------------------------------------------------------

-- lightweight replacement for fidget.nvim
local progressText = ""
local function lspProgress() return progressText end

vim.api.nvim_create_autocmd("LspProgress", {
	callback = function(ctx)
		local clientName = vim.lsp.get_client_by_id(ctx.data.client_id).name
		local progress = ctx.data.params.value ---@type {percentage: number, title?: string, kind: string, message?: string}
		if not (progress and progress.title) then return end

		local icons = { "󰪞", "󰪟", "󰪠", "󰪡", "󰪢", "󰪣", "󰪤", "󰪥" }
		local idx = math.floor(#icons / 2)
		if progress.percentage == 0 then idx = 1 end
		if progress.percentage and progress.percentage > 0 then
			idx = math.ceil(progress.percentage / 100 * #icons)
		end
		local firstWord = vim.split(progress.title, " ")[1]:lower()

		local text = ("%s %s %s"):format(icons[idx], clientName, firstWord)
		progressText = progress.kind == "end" and "" or text
	end,
})

--------------------------------------------------------------------------------

local function irregularWhitespace()
	if bo.buftype ~= "" then return "" end

	-- CONFIG
	local spaceFiletypes = { python = 4, yaml = 2, query = 2, just = 4 }

	local spaceFtsOnly = vim.tbl_keys(spaceFiletypes)
	local spacesInsteadOfTabs = bo.expandtab and not vim.tbl_contains(spaceFtsOnly, bo.ft)
	local differentSpaceAmount = bo.expandtab and spaceFiletypes[bo.ft] ~= bo.shiftwidth
	local tabsInsteadOfSpaces = not bo.expandtab and vim.tbl_contains(spaceFtsOnly, bo.ft)

	if spacesInsteadOfTabs or differentSpaceAmount then
		return "󱁐 " .. bo.shiftwidth
	elseif tabsInsteadOfSpaces then
		return "󰌒 " .. bo.shiftwidth
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
		:gsub("^Find Word %((.-)%) %b()", "%1")
		:gsub(" %(%)", "") -- empty brackets
		:gsub("%-%-[%w-_]+ ?", "") -- remove flags from `makeprg`
	return (' %s/%s "%s"'):format(qf.idx, #qf.items, qf.title) .. fileStr
end

--------------------------------------------------------------------------------

local lualineConfig = {
	options = {
		refresh = { statusline = 500 },
		globalstatus = true,
		always_divide_middle = false,
		section_separators = { left = "", right = "" }, -- nerdfont-powerline icons prefix: `ple-`
		component_separators = { left = "", right = "" },
		-- stylua: ignore
		ignore_focus = {
			"DressingInput", "DressingSelect", "lspinfo", "ccc-ui", "TelescopePrompt",
			"checkhealth", "noice", "lazy", "mason", "qf", "regex"
		},
	},
	tabline = {
		lualine_a = {
			{ -- clock if window is maximized
				"datetime",
				style = " %H:%M:%S",
				cond = function() return vim.o.columns > 120 end,
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
	},
	sections = {
		lualine_a = {
			{ -- branch, but only if not on main or master
				"branch",
				cond = function()
					if bo.buftype ~= "" then return false end
					local curBranch = require("lualine.components.branch.git_branch").get_branch()
					return curBranch ~= "main" and curBranch ~= "master"
				end,
			},
			{ -- .venv indicator
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
			{ require("funcs.magnet").altFileStatus },
		},
		lualine_c = {
			{ quickfixCounter },
		},
		lualine_x = {
			{ -- recording status
				function() return "雷Recording…" end,
				cond = function() return vim.fn.reg_recording() ~= "" end,
				color = function() return { fg = u.getHighlightValue("Error", "fg") } end,
			},
			{ lspProgress },
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
			{ -- line count
				function() return vim.api.nvim_buf_line_count(0) .. " " end,
				cond = function() return vim.bo.buftype == "" end,
			},
		},
		lualine_z = {
			{ "selectioncount", fmt = function(str) return str ~= "" and "礪" .. str or "" end },
			{ "location" },
			{ function() return "" end, padding = { left = 0, right = 1 } },
		},
	},
}

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = lualineConfig,
}
