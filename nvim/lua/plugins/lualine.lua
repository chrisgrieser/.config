local bo = vim.bo
local fn = vim.fn
--------------------------------------------------------------------------------

-- displays irregular indentation and linebreaks, displays nothing when all is good
local function irregularWhitespace()
	if bo.buftype ~= "" then return "" end
	local out = {}

	-- CONFIG
	-- filetypes and the number of spaces they use. Omit or set to nil to use tabs for that filetype.
	local spaceFiletypes = { python = 4, yaml = 2, query = 2 }
	local ignoredFiletypes = { "css" }
	local linebreakType = "unix" ---@type "unix"|"mac"|"dos"
	local icons = { unix = "", mac = "", dos = "", space = "󱁐", tab = "󰌒" }

	-- non-default indentation setting (e.g. changed via guessIndent or editorconfig)
	local ft = bo.filetype
	local spaceFtsOnly = vim.tbl_keys(spaceFiletypes)
	local spacesInsteadOfTabs = bo.expandtab and not vim.tbl_contains(spaceFtsOnly, ft)
	local differentSpaceAmount = bo.expandtab and spaceFiletypes[ft] ~= bo.tabstop
	local tabsInsteadOfSpaces = not bo.expandtab and vim.tbl_contains(spaceFtsOnly, ft)
	if spacesInsteadOfTabs or differentSpaceAmount then
		out.indentation = icons.space .. " " .. tostring(bo.tabstop)
	elseif tabsInsteadOfSpaces then
		out.indentation = icons.tab .. " " .. tostring(bo.tabstop)
	end
	if vim.tbl_contains(ignoredFiletypes, ft) then out.indentation = nil end

	-- line breaks
	local irregularLinebreak = bo.fileformat ~= linebreakType
	if irregularLinebreak then out.linebreak = "󰌑 " .. icons[bo.fileformat] .. " " end

	-- out
	return table.concat(vim.tbl_values(out), " ")
end

--------------------------------------------------------------------------------

--- https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/components/branch/git_branch.lua#L118
local function isStandardBranch()
	-- checking via lualine API, to not call git outself
	local curBranch = require("lualine.components.branch.git_branch").get_branch()
	local notMainBranch = curBranch ~= "main" and curBranch ~= "master"
	local validFiletype = bo.filetype ~= "help" -- vim help files are located in a git repo
	local notSpecialBuffer = bo.buftype == ""
	return notMainBranch and validFiletype and notSpecialBuffer
end

--------------------------------------------------------------------------------

local function selectionCount()
	local isVisualMode = fn.mode():find("[Vv]")
	if not isVisualMode then return "" end
	local starts = fn.line("v")
	local ends = fn.line(".")
	local lines = starts <= ends and ends - starts + 1 or starts - ends + 1
	return " " .. tostring(lines) .. "L " .. tostring(fn.wordcount().visual_chars) .. "C"
end

-- only show the clock when fullscreen (= it covers the menubar clock)
local function clock()
	if vim.opt.columns:get() < 110 or vim.opt.lines:get() < 25 then return "" end
	local time = tostring(os.date("%H:%M"))
	if os.date("%S") % 2 == 1 then time = time:gsub(":", " ") end -- make the `:` blink
	return time
end

-- wrapper to not require navic directly
local function navicBreadcrumbs()
	if bo.filetype == "css" or not require("nvim-navic").is_available() then return "" end
	return require("nvim-navic").get_location()
end

local function quickfixCounter()
	local totalQfItems = #vim.fn.getqflist()
	if totalQfItems == 0 then return "" end
	local qfData = vim.fn.getqflist { idx = 0, title = true }
	local title = qfData.title:gsub("^Live Grep: .- %((.*)%)", "Grep: %1")
	local index = qfData.idx
	return (" %s/%s (%s)"):format(index, totalQfItems, title)
end

---improves upon the default statusline components by having properly working icons
local function currentFile()
	local maxLen = 25

	local ext = fn.expand("%:e")
	local ft = bo.filetype
	local name = fn.expand("%:t")

	local deviconsInstalled, devicons = pcall(require, "nvim-web-devicons")
	local ftOrExt = ext ~= "" and ext or ft
	if ftOrExt == "javascript" then ftOrExt = "js" end
	if ftOrExt == "typescript" then ftOrExt = "ts" end
	if ftOrExt == "markdown" then ftOrExt = "md" end
	if ftOrExt == "vimrc" then ftOrExt = "vim" end
	local icon = deviconsInstalled and devicons.get_icon(name, ftOrExt) or ""
	-- add sourcegraph icon for clarity
	if fn.expand("%"):find("^sg") then icon = "󰓁 " .. icon end

	-- truncate
	local nameNoExt = name:gsub("%.%w+$", "")
	if #nameNoExt > maxLen then name = nameNoExt:sub(1, maxLen) .. "…" .. ext end

	if icon == "" then return name end
	return icon .. " " .. name
end

--------------------------------------------------------------------------------

-- FIX Add missing buffer names for current file component
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lazy", "mason", "TelescopePrompt", "noice", "checkhealth", "lspinfo", "qf" },
	callback = function(ctx)
		local ft = ctx.match
		local name = ft:sub(1, 1):upper() .. ft:sub(2) -- capitalize
		if ft == "qf" then name = vim.fn.getqflist({ title = true }).title end
		pcall(vim.api.nvim_buf_set_name, 0, name)
	end,
})

-- nerdfont: powerline icons have the prefix 'ple-'
local bottomSeparators = { left = "", right = "" }
local topSeparators = { left = "", right = "" }

local lualineConfig = {
	tabline = {
		-- INFO using the tabline will override vim's default tabline, so the tabline
		-- should always include the tab element
		lualine_a = {
			-- INFO setting different section separators in the same components has
			-- yanky results, they should have the same separator
			{ clock, section_separators = topSeparators },
			{
				"tabs",
				mode = 1,
				max_length = vim.o.columns * 0.7,
				section_separators = topSeparators,
				cond = function() return fn.tabpagenr("$") > 1 end,
			},
		},
		lualine_b = {
			{ navicBreadcrumbs, section_separators = topSeparators },
		},
		lualine_c = {},
		lualine_x = {},
		-- INFO dap and recording status defined in the respective plugin configs
		-- for lualine_y and lualine_z for their lazy loading
		lualine_y = {},
		lualine_z = {},
	},
	sections = {
		lualine_a = {
			{ "branch", cond = isStandardBranch },
			{ currentFile },
		},
		lualine_b = {
			{ require("funcs.alt-alt").altFileStatusline },
		},
		lualine_c = {
			{ quickfixCounter },
		},
		lualine_x = {
			{
				"diagnostics",
				symbols = { error = "󰅚 ", warn = " ", info = "󰋽 ", hint = "󰘥 " },
			},
			{ irregularWhitespace },
		},
		lualine_y = {
			"diff",
		},
		lualine_z = {
			{ selectionCount, padding = { left = 0, right = 1 } },
			"location",
		},
	},
	options = {
		refresh = { statusline = 1000 },
		ignore_focus = { "DressingInput", "DressingSelect", "ccc-ui" },
		globalstatus = true,
		component_separators = { left = "", right = "" },
		section_separators = bottomSeparators,
	},
}

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	lazy = false, -- load immediately so there is no flickering
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = lualineConfig,
}
