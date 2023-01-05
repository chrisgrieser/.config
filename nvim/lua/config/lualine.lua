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
	callback = function()
		g.cur_branch = fn.system("git --no-optional-locks branch --show-current"):gsub("\n$", "")
	end,
})

local function isStandardBranch() -- not checking for branch here, since running the condition check too often results in lock files and also makes the cursor glitch for whatever reason…
	local branch = g.cur_branch
	local notMainBranch = branch ~= "main" and branch ~= "master"
	local validFiletype = bo.filetype ~= "help" -- vim help files are located in a git repo
	return notMainBranch and validFiletype
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
	local isVisualMode = fn.mode():find("[Vv]")
	if not isVisualMode then return "" end
	local starts = fn.line("v")
	local ends = fn.line(".")
	local lines = starts <= ends and ends - starts + 1 or starts - ends + 1
	return "/  " .. tostring(lines) .. "L " .. tostring(fn.wordcount().visual_chars) .. "c"
end

local function searchCounter()
	if fn.mode() ~= "n" or vim.v.hlsearch == 0 then return "" end
	local total = fn.searchcount().total
	local current = fn.searchcount().current
	local searchTerm = fn.getreg("/")
	local isStarSearch = searchTerm:find([[^\<.*\>$]])
	if isStarSearch then searchTerm = "*" .. searchTerm:sub(3, -3) end
	return " " .. current .. "/" .. total .. " " .. searchTerm
end

local function currentFile()
	local maxLen = 15
	local altFile = expand("#:t")
	local curFile = expand("%:t")
	local icon = bo.modifiable and "%% " or " "
	local ft = bo.filetype
	if bo.buftype == "terminal" then
		local mode = fn.mode() == "t" and "[T]" or "[N]"
		return " Terminal " .. mode
	elseif bo.buftype == "nofile" then
		return " " .. curFile -- e.g. Codi
	elseif curFile == "" and ft ~= "" then
		return " " .. ft 
	elseif curFile == "" and ft == "" then
		return "%% [New]"
	elseif curFile == altFile then
		local curParent = expand("%:p:h:t")
		if #curParent > maxLen then curParent = curParent:sub(1, maxLen) .. "…" end
		return "%% " .. curParent .. "/" .. curFile
	end
	return icon .. curFile
end

--------------------------------------------------------------------------------


-- nerdfont: 'nf-ple'; since separators look off in Terminal
local bottomSeparators = isGui() and { left = " ", right = " " } or { left = "", right = "" }
local topSeparators = isGui() and { left = "", right = "" } or { left = "", right = "" }

require("lualine").setup {
	sections = {
		lualine_a = { { currentFile } },
		lualine_b = { { require("funcs.alt-alt-file").altFileStatusline } },
		lualine_c = {
			{ searchCounter },
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
					return numberOfUpdates > 5
				end,
				color = "NonText",
			},
		},
		lualine_y = {
			{ require("recorder").displaySlots, section_separators = topSeparators },
		},
		lualine_z = {
			{ require("recorder").recordingStatus, section_separators = topSeparators },
		},
	},
	options = {
		refresh = {
			statusline = 2000, -- less often, so it interferes less with git processes
		},
		ignore_focus = {
			"TelescopePrompt",
			"DressingInput",
			"DressingSelect",
			"Mason",
			"ccc-ui",
			"",
		},
		globalstatus = true,
		component_separators = { left = "", right = "" },
		section_separators = bottomSeparators,
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
	},
}
