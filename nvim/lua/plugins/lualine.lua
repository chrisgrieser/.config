local bo = vim.bo
local fn = vim.fn
local u = require("config.utils")

--------------------------------------------------------------------------------

local function indentation()
	local out = ""
	local usesSpaces = bo.expandtab
	local usesTabs = not bo.expandtab
	local ft = bo.filetype
	local tabwidth = bo.tabstop
	local spaceFiletypes = { "python", "yaml" }
	local ignoredFiletypes = { "css", "markdown", "gitcommit" }
	if vim.tbl_contains(ignoredFiletypes, ft) or fn.mode() ~= "n" or bo.buftype ~= "" then return "" end

	-- non-default indentation (e.g. changed via indent-o-matic)
	if usesSpaces and not vim.tbl_contains(spaceFiletypes, ft) then
		out = out .. tostring(tabwidth) .. "󱁐"
	elseif usesTabs and vim.tbl_contains(spaceFiletypes, ft) then
		out = out .. "↹ (" .. tostring(tabwidth) .. ")"
	elseif usesTabs and vim.opt_global.tabstop:get() ~= tabwidth then
		out = out .. " ↹ " .. tostring(tabwidth)
	end

	-- mixed indentation
	local hasTabs = fn.search("^\t", "nw") > 0
	local hasSpaces = fn.search("^ ", "nw") > 0
	-- jsdocs: space not followed by "*"
	if bo.filetype == "javascript" then hasSpaces = fn.search([[^ \(\*\)\@!]], "nw") > 0 end

	if usesTabs and hasSpaces then
		out = out .. " 󱁐"
	elseif usesSpaces and hasTabs then
		out = out .. " ↹ "
	end
	if out ~= "" then out = "󰉶 " .. out end
	return out
end

--------------------------------------------------------------------------------

-- show branch info only when *not* on main/master
vim.api.nvim_create_autocmd({ "BufReadPost", "FocusGained", "UiEnter" }, {
	callback = function()
		vim.b.cur_branch = fn.system("git --no-optional-locks branch --show-current"):gsub("\n$", "")
	end,
})

---@nodiscard
---@return boolean
local function isStandardBranch() -- not checking for branch here, since running the condition check too often results in lock files and also makes the cursor glitch for whatever reason…
	local notMainBranch = vim.b.cur_branch ~= "main" and vim.b.cur_branch ~= "master"
	local validFiletype = bo.filetype ~= "help" -- vim help files are located in a git repo
	local notSpecialBuffer = not (bo.buftype ~= "") -- statusline already shows branch
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

-- shows global mark M
local function markM()
	local markObj = vim.api.nvim_get_mark("M", {})
	local markLn = markObj[1]
	local markBufname = vim.fs.basename(markObj[4])
	if markBufname == "" then return "" end -- mark not set
	return " " .. markBufname .. ":" .. markLn
end
vim.api.nvim_del_mark("M") -- reset on session start

-- only show the clock when fullscreen (= it covers the menubar clock)
local function clock()
	if vim.opt.columns:get() < 110 or vim.opt.lines:get() < 25 then return "" end

	local time = tostring(os.date()):sub(12, 16)
	if os.time() % 2 == 1 then time = time:gsub(":", " ") end -- make the `:` blink
	return time
end

-- return available plugin updates when above a certain threshold
local function pluginUpdates()
	local threshold = 20
	if not require("lazy.status").has_updates() then return "" end
	local numberOfUpdates = require("lazy.status").updates()
	if numberOfUpdates < threshold then return "" end
	return " " .. numberOfUpdates
end

-- wrapper to not require navic directly
local function navicBreadcrumbs()
	if bo.filetype == "css" or not require("nvim-navic").is_available() then return "" end
	return require("nvim-navic").get_location()
end

-- show newlineChar, when it is *not* unix
local function newlineChars()
	if bo.fileformat == "unix" then
		return ""
	elseif bo.fileformat == "mac" then
		return "󰌑 "
	elseif bo.fileformat == "dos" then
		return "󰌑 "
	end
	return "󰌑 ?"
end

--------------------------------------------------------------------------------

-- nerdfont: powerline icons have the prefix 'ple-'
local bottomSeparators = { left = "", right = "" }
local topSeparators = { left = "", right = "" }
local emptySeparators = { left = "", right = "" }

local lualineConfig = {
	-- INFO using the tabline will override vim's default tabline, so the tabline
	-- should always include the tab element
	tabline = {
		lualine_a = {
			-- INFO setting different section separators in the same components has
			-- yanky results, they should have the same separator
			-- searchcounter at the top, so it work with cmdheight=0
			{ clock, section_separators = emptySeparators },
			{
				"tabs",
				mode = 1,
				max_length = vim.o.columns * 0.7,
				section_separators = emptySeparators,
				cond = function() return fn.tabpagenr("$") > 1 end,
			},
		},
		lualine_b = {
			{ navicBreadcrumbs, section_separators = topSeparators },
		},
		lualine_c = {},
		lualine_x = {
			{
				pluginUpdates,
				color = function() return { fg = u.getHighlightValue("NonText", "fg") } end,
			},
		},
		-- INFO dap and recording status defined in the respective plugin configs
		-- for lualine_y and lualine_z for their lazy loading
		lualine_y = {
			{ markM },
		},
		lualine_z = {},
	},
	sections = {
		lualine_a = {
			{
				"filetype",
				colored = false,
				padding = { left = 1, right = 0 },
				icon_only = true,
			},
			{
				"filename",
				file_status = false,
			},
		},
		lualine_b = {
			{ require("funcs.alt-alt").altFileStatusline },
		},
		lualine_c = {
			{ require("funcs.quickfix").counter },
			{
				require("dr-lsp").lspCount,
				cond = function() return vim.v.hlsearch == 0 end,
				-- needs the highlight value, since setting the hlgroup directly
				-- results in bg color being inherited from main editor
				color = function() return { fg = u.getHighlightValue("Comment", "fg") } end,
				fmt = function(str) return str:gsub("R", ""):gsub("D", " 󰄾"):gsub("LSP:", "󰈿") end,
			},
		},
		lualine_x = {
			{
				"diagnostics",
				symbols = { error = "󰅚 ", warn = " ", info = "󰋽 ", hint = "󰘥 " },
			},
			{ indentation },
			{ newlineChars },
			{ require("dr-lsp").lspProgress },
		},
		lualine_y = {
			"diff",
			{ "branch", cond = isStandardBranch },
		},
		lualine_z = {
			{ selectionCount, padding = { left = 0, right = 1 } },
			"location",
		},
	},
	options = {
		refresh = { statusline = 1000 },
		ignore_focus = {
			"TelescopePrompt",
			"DressingInput",
			"DressingSelect",
			"ccc-ui",
		},
		globalstatus = true,
		component_separators = { left = "", right = "" },
		section_separators = bottomSeparators,
	},
}

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	lazy = false, -- so there is less flickering of the UI on startup
	opts = lualineConfig,
}
