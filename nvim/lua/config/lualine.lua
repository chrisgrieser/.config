require("config.utils")
--------------------------------------------------------------------------------

-- simple alternative to fidget.nvim, via https://www.reddit.com/r/neovim/comments/o4bguk/comment/h2kcjxa/
local function lsp_progress()
	local messages = vim.lsp.util.get_progress_messages()
	if #messages == 0 then return "" end
	local client = messages[1].name and messages[1].name .. ": " or ""
	if client:find("null%-ls") then return "" end
	local progress = messages[1].percentage or 0
	local task = messages[1].title or ""
	task = task:gsub("^(%w+).*", "%1") -- only first word
	return client .. progress .. "%% " .. task
end

local function mixedIndentation()
	local ignoredFts = { "css", "markdown", "sh", "lazy", "" }
	if vim.tbl_contains(ignoredFts, bo.filetype) or fn.mode() == "i" or bo.buftype == "terminal" then
		return ""
	end

	local hasTabs = fn.search("^\t", "nw") > 0
	local hasSpaces = fn.search("^ ", "nw") > 0
	local mixed = fn.search([[^\(\t\+ \| \+\t\)]], "nw") ~= 0

	if (hasSpaces and hasTabs) or mixed then
		return " mixed"
	elseif hasSpaces and not bo.expandtab then
		return " tabs"
	elseif hasTabs and bo.expandtab then
		return " spaces"
	end
	return ""
end

-- show branch info only when not on main/master
augroup("branchChange", {})
autocmd({ "BufEnter", "FocusGained", "WinEnter", "TabEnter" }, {
	group = "branchChange",
	callback = function() g.cur_branch = fn.system("git --no-optional-locks branch --show-current"):gsub("\n$", "") end,
})

local function isStandardBranch() -- not checking for branch here, since running the condition check too often results in lock files and also makes the cursor glitch for whatever reason…
	local branch = g.cur_branch
	local notMainBranch = branch ~= "main" and branch ~= "master"
	local validFiletype = bo.filetype ~= "help" -- vim help files are located in a git repo
	return notMainBranch and validFiletype
end

local function debuggerStatus()
	local dapStatus = require("dap").status()
	if dapStatus == "" then return "" end
	return "  " .. dapStatus
end

-- NAVIC
local navic = require("nvim-navic")
navic.setup {
	icons = { Object = "ﴯ " },
	separator = "  ",
	depth_limit = 8,
	depth_limit_indicator = "…",
}

local function showBreadcrumbs() return navic.is_available() and not (bo.filetype == "css") end

local function selectionCount()
	if not fn.mode():find("[vV]") then return "" end
	local starts = fn.line("v")
	local ends = fn.line(".")
	local lines = starts <= ends and ends - starts + 1 or starts - ends + 1
	return "/  " .. tostring(lines) .. "L " .. tostring(fn.wordcount().visual_chars) .. "c"
end

--------------------------------------------------------------------------------

-- nerdfont: 'nf-ple'; since separators look off in Terminal
local bottomSeparators = isGui() and { left = " ", right = " " } or { left = "", right = "" }
local topSeparators = isGui() and { left = "", right = "" } or { left = "", right = "" }

require("lualine").setup {
	sections = {
		lualine_a = { { qol.currentFileStatusline } },
		lualine_b = { { qol.alternateFileStatusline } },
		lualine_c = {
			{
				"searchcount",
				fmt = function(str)
					if str == "" or str == "[0/0]" then return "" end
					local count = "" .. str:sub(2, -2) .. ""
					local term = fn.getreg("/")
					return "  " ..term .. " ".. count
				end,
				cond = function () return fn.mode() == "n" end,
			},
		},
		lualine_x = {
			{ lsp_progress },
			"diagnostics",
			{ mixedIndentation },
		},
		lualine_y = {
			"diff",
			{ "branch", cond = isStandardBranch },
		},
		lualine_z = {
			"location",
			{ selectionCount },
		},
	},
	winbar = {
		lualine_b = {
			{
				navic.get_location,
				cond = showBreadcrumbs,
				section_separators = topSeparators,
			},
		},
		lualine_c = {
			{
				function() return " " end, -- dummy to avoid bar appearing and disappearing
				cond = showBreadcrumbs,
			},
		},
		lualine_x = {
			{
				require("lazy.status").updates,
				cond = function()
					if not require("lazy.status").has_updates() then return false end
					local numberOfUpdates = tonumber(require("lazy.status").updates():match("%d+"))
					return numberOfUpdates > 15
				end,
				color = "NonText",
			},
		},
		lualine_y = {
			{ require("recorder").displaySlots, section_separators = topSeparators },
		},
		lualine_z = {
			{ require("recorder").recordingStatus, section_separators = topSeparators },
			{ debuggerStatus, section_separators = topSeparators },
		},
	},
	options = {
		refresh = {
			statusline = 2000, -- less often, so it interferes less with git processes
		},
		ignore_focus = {
			"TelescopePrompt",
			"DressingInput",
			"Mason",
			"ccc-ui",
			"",
		},
		globalstatus = true,
		component_separators = { left = "", right = "" },
		section_separators = bottomSeparators,
		extensions = { "nvim-dap-ui" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
	},
}
