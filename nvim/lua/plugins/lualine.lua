local bo = vim.bo
local fn = vim.fn
local u = require("config.utils")

--------------------------------------------------------------------------------

-- display irregular indentation and linebreaks
local function indentationAndLinebreaks()
	-- config
	local spaceFiletypes = { "python", "yaml" }
	local ignoredFiletypes = { "css", "markdown", "gitcommit" }
	local linebreakType = "unix" ---@type "unix" | "mac" | "dos"

	-- vars & guard
	local usesSpaces = bo.expandtab
	local usesTabs = not bo.expandtab
	local brUsed = bo.fileformat
	local ft = bo.filetype
	local tabwidth = bo.tabstop
	if vim.tbl_contains(ignoredFiletypes, ft) or fn.mode() ~= "n" or bo.buftype ~= "" then return "" end

	-- non-default indentation (e.g. changed via indent-o-matic)
	local nonDefault = ""
	if usesSpaces and not vim.tbl_contains(spaceFiletypes, ft) then
		nonDefault = " " .. tostring(tabwidth) .. "󱁐 "
	elseif usesTabs and vim.tbl_contains(spaceFiletypes, ft) then
		nonDefault = " 󰌒 (" .. tostring(tabwidth) .. ") "
	end

	-- mixed indentation
	local hasTabs = fn.search("^\t", "nw") > 0
	local hasSpaces = fn.search("^ ", "nw") > 0
	-- jsdocs: space not followed by "*"
	if bo.filetype == "javascript" then hasSpaces = fn.search([[^ \(\*\)\@!]], "nw") > 0 end
	local mixedIndent = ""
	if (usesTabs and hasSpaces) or (usesSpaces and hasTabs) then mixedIndent = " 󱁐 󰌒 " end

	-- line breaks
	local linebreaks = ""
   if and brUsed ~= linebreakType then

   end
	if brUsed == "unix" and brUsed ~= linebreakType then
		linebreaks = ""
	elseif brUsed == "mac" and brUsed ~= linebreakType then
		linebreaks = "󰌑 "
	elseif brUsed == "dos" and brUsed ~= linebreakType then
		linebreaks = "󰌑 "
	end

	return nonDefault .. mixedIndent .. linebreaks
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

--------------------------------------------------------------------------------

-- FIX Add missing buffer names for current file component
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lazy", "mason", "TelescopePrompt", "noice" },
	callback = function()
		local name = vim.fn.expand("<amatch>")
		name = name:sub(1, 1):upper() .. name:sub(2) -- capitalize
		pcall(vim.api.nvim_buf_set_name, 0, name)
	end,
})

---improves upon the default statusline components by having properly working icons
---@nodiscard
local function currentFile()
	local maxLen = 25

	local ext = fn.expand("%:e")
	local ft = bo.filetype
	local name = fn.expand("%:t")
	if ft == "octo" and name:find("^%d$") then
		name = "#" .. name
	elseif ft == "TelescopePrompt" then
		name = "Telescope"
	end

	local deviconsInstalled, devicons = pcall(require, "nvim-web-devicons")
	require("nvim-web-devicons").get_icon("bla.js", "js")
	local ftOrExt = ext ~= "" and ext or ft
	if ftOrExt == "javascript" then ftOrExt = "js" end
	if ftOrExt == "typescript" then ftOrExt = "ts" end
	if ftOrExt == "markdown" then ftOrExt = "md" end
	local icon = deviconsInstalled and devicons.get_icon(name, ftOrExt) or ""

	-- truncate
	local nameNoExt = name:gsub("%.%w+$", "")
	if #nameNoExt > maxLen then name = nameNoExt:sub(1, maxLen) .. "…" .. ext end

	if icon == "" then return name end
	return icon .. " " .. name
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
			{ currentFile },
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
			{ indentationAndLinebreaks },
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
	opts = lualineConfig,
}
