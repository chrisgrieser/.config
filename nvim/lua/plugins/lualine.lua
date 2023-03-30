local function indentation()
	local out = ""
	local usesSpaces = vim.bo.expandtab
	local usesTabs = not vim.bo.expandtab
	local ft = vim.bo.filetype
	local tabwidth = vim.bo.tabstop
	local spaceFiletypes = { "python", "yaml" }
	local ignoredFiletypes = { "css", "markdown", "gitcommit" }
	if vim.tbl_contains(ignoredFiletypes, ft) or vim.fn.mode() ~= "n" or vim.bo.buftype ~= "" then
		return ""
	end

	-- non-default indentation (e.g. changed via indent-o-matic)
	if usesSpaces and not vim.tbl_contains(spaceFiletypes, ft) then
		out = out .. tostring(tabwidth) .. "󱁐"
	elseif usesTabs and vim.tbl_contains(spaceFiletypes, ft) then
		out = out .. "↹ (" .. tostring(tabwidth) .. ")"
	elseif usesTabs and vim.opt_global.tabstop:get() ~= tabwidth then
		out = out .. " ↹ " .. tostring(tabwidth)
	end

	-- mixed indentation
	local hasTabs = vim.fn.search("^\t", "nw") > 0
	local hasSpaces = vim.fn.search("^ ", "nw") > 0
	local mixed = vim.fn.search([[^\(\t\+ \| \+\t\)]], "nw") ~= 0

	if (hasSpaces and hasTabs) or mixed then
		out = out .. " mixed"
	elseif usesTabs and hasSpaces then
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
		vim.b.cur_branch = vim.fn.system("git --no-optional-locks branch --show-current"):gsub("\n$", "")
	end,
})

---@nodiscard
---@return boolean
local function isStandardBranch() -- not checking for branch here, since running the condition check too often results in lock files and also makes the cursor glitch for whatever reason…
	local notMainBranch = vim.b.cur_branch ~= "main" and vim.b.cur_branch ~= "master"
	local validFiletype = vim.bo.filetype ~= "help" -- vim help files are located in a git repo
	local notSpecialBuffer = not (vim.bo.buftype ~= "") -- statusline already shows branch
	return notMainBranch and validFiletype and notSpecialBuffer
end

--------------------------------------------------------------------------------

local function selectionCount()
	local isVisualMode = vim.fn.mode():find("[Vv]")
	if not isVisualMode then return "" end
	local starts = vim.fn.line("v")
	local ends = vim.fn.line(".")
	local lines = starts <= ends and ends - starts + 1 or starts - ends + 1
	return " " .. tostring(lines) .. "L " .. tostring(vim.fn.wordcount().visual_chars) .. "C"
end

local function searchCounter()
	if vim.fn.mode() ~= "n" or vim.v.hlsearch == 0 then return "" end
	local total = vim.fn.searchcount().total
	local current = vim.fn.searchcount().current
	local searchTerm = vim.fn.getreg("/")
	local isStarSearch = searchTerm:find([[^\<.*\>$]])
	if isStarSearch then searchTerm = "*" .. searchTerm:sub(3, -3) end
	if total == 0 then return " 0 " .. searchTerm end
	return (" %s/%s %s"):format(current, total, searchTerm)
end

local function visualMultiCursorCount()
	---@diagnostic disable: undefined-field -- defined by visual multi plugin
	if not vim.b.VM_Selection then return "" end
	local cursors = vim.b.VM_Selection.Regions
	if not cursors then return "" end
	return "󰇀 " .. tostring(#cursors)
	---@diagnostic enable: undefined-field
end

local function clock()
	if vim.opt.columns:get() < 110 then return "" end -- only show the clock when it covers the menubar clock
	local time = tostring(os.date()):sub(12, 16)
	if os.time() % 2 == 1 then time = time:gsub(":", " ") end -- make the `:` blink
	return time
end

--------------------------------------------------------------------------------

---returns a harpoon icon if the current file is marked in Harpoon. Does not
---`require` itself, so won't load Harpoon (for when lazyloading Harpoon)
function UpdateHarpoonIndicator()
	vim.b.harpoonMark = "" -- empty by default
	local harpoonJsonPath = vim.fn.stdpath("data") .. "/harpoon.json"
	local fileExists = vim.fn.filereadable(harpoonJsonPath) ~= 0
	if not fileExists then return end
	local harpoonJson = ReadFile(harpoonJsonPath)
	if not harpoonJson then return end

	local harpoonData = vim.json.decode(harpoonJson)
	local pwd = vim.loop.cwd()
	if not pwd then return end
	local currentProject = harpoonData.projects[pwd]
	if not currentProject then return end
	local markedFiles = currentProject.mark.marks
	local currentFile = vim.fn.expand("%")

	for _, file in pairs(markedFiles) do
		if file.filename == currentFile then vim.b.harpoonMark = "󰛢" end
	end
end

local function harpoonStatusline() return vim.b.harpoonMark or "" end

-- so the harpoon state is only checked once on buffer enter and not every second
-- also, the command is called on marking a new file
vim.api.nvim_create_autocmd({ "BufReadPost", "UiEnter" }, {
	pattern = "*",
	callback = UpdateHarpoonIndicator,
})

--------------------------------------------------------------------------------

-- simple alternative to fidget.nvim
local function lsp_progress()
	-- via https://www.reddit.com/r/neovim/comments/o4bguk/comment/h2kcjxa/
	local messages = vim.lsp.util.get_progress_messages()
	if #messages == 0 then return "" end
	local client = messages[1].name and messages[1].name .. ": " or ""
	if client:find("null%-ls") then return "" end
	local progress = messages[1].percentage or 0
	local task = messages[1].title or ""
	task = task:gsub("^(%w+).*", "%1") -- only first word

	local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
	local ms = vim.loop.hrtime() / 1000000
	local frame = math.floor(ms / 120) % #spinners
	return spinners[frame + 1] .. " " .. client .. progress .. "%% " .. task
end

-- return available plugin updates when above a certain threshold
local function pluginUpdates()
	if not require("lazy.status").has_updates() then return "" end
	local numberOfUpdates = require("lazy.status").updates()
	if numberOfUpdates < UpdateCounterThreshhold then return "" end
	return numberOfUpdates
end

--------------------------------------------------------------------------------

-- wrapper to not require navic directly
local function navicBreadcrumbs()
	if not require("nvim-navic").is_available() then return "" end
	return require("nvim-navic").get_location()
end

-- simple barbecue,nvim replacement
local function pathToProjectRoot()
	if not require("nvim-navic").is_available() then return "" end
	local parentPath = vim.fn.expand("%:p:h")
	local projectRelPath = parentPath:sub(#vim.loop.cwd() + 2)
	local nicerDisplay = projectRelPath:gsub("/", "  ") -- same separator as navic
	return "󰝰 " .. nicerDisplay
end

--------------------------------------------------------------------------------

-- nerdfont: icons with prefix 'ple-'
-- stylua: ignore start
local bottomSeparators = vim.g.neovide and { left = " ", right = " " } or { left = "", right = "" }
local topSeparators = vim.g.neovide and { left = " ", right = " " } or { left = "", right = "" }
-- stylua: ignore end

local lualineConfig = {
	sections = {
		lualine_a = {
			{
				harpoonStatusline,
				padding = { left = 1, right = 0 },
			},
			{
				"filetype",
				colored = false,
				padding = { left = 1, right = 0 },
				icon_only = true,
			},
			{
				"filename",
				file_status = false,
				fmt = function(str) return str:gsub("%w+;#toggleterm#.*", "Toggleterm") end,
			},
		},
		lualine_b = { { require("funcs.alt-alt").altFileStatusline } },
		lualine_c = {
			{ require("funcs.quickfix").counter },
			{ searchCounter },
			{
				require("funcs.lsp-count").statusline,
				cond = function() return vim.v.hlsearch == 0 end,
				-- needs the highlight value, since setting the hlgroup directly
				-- results in bg color being inherited from main editor
				color = function() return { fg = GetHighlightValue("Comment", "foreground") } end,
			},
		},
		lualine_x = {
			{
				"diagnostics",
				symbols = { error = "󰅚 ", warn = " ", info = "󰋽 ", hint = "󰘥 " },
			},
			{ indentation },
			{ lsp_progress },
		},
		lualine_y = {
			"diff",
			{ "branch", cond = isStandardBranch },
		},
		lualine_z = {
			{ visualMultiCursorCount },
			{ selectionCount, padding = { left = 0, right = 1 } },
			"location",
		},
	},
	-- INFO using the tabline will override vim's default tabline, so the tabline
	-- should always include the tab element
	tabline = {
		lualine_a = {
			{ clock, section_separators = topSeparators },
			{
				"tabs",
				mode = 2,
				max_length = vim.o.columns * 0.7,
				cond = function() return vim.fn.tabpagenr("$") > 1 end,
			},
		},
		lualine_b = {
			{
				pathToProjectRoot,
				section_separators = topSeparators,
				cond = function() return vim.fn.tabpagenr("$") == 1 end,
			},
		},
		lualine_c = {
			-- "draw_empty" to prevent glitching if its the only one in winbar
			{ navicBreadcrumbs, section_separators = topSeparators, draw_empty = true },
		},
		lualine_x = {
			{
				pluginUpdates,
				color = function() return { fg = GetHighlightValue("NonText", "foreground") } end,
			},
		},
		-- INFO dap and recording status defined in the respective plugin configs
		-- for lualine_y and lualine_z for their lazy loading
	},
	options = {
		refresh = { statusline = 1000 },
		ignore_focus = {
			"TelescopePrompt",
			"DressingInput",
			"DressingSelect",
			"Mason",
			"harpoon",
			"ccc-ui",
			"",
		},
		globalstatus = true,
		component_separators = { left = "", right = "" },
		section_separators = bottomSeparators,
		disabled_filetypes = {
			winbar = { "toggleterm", "gitcommit" },
		},
	},
}

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	event = "VimEnter",
	opts = lualineConfig,
}
