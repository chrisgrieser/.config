require("utils")
--------------------------------------------------------------------------------

-- Annotations
cmd.highlight {"def link myAnnotations Todo", bang = true} -- use same styling as "TODO"
fn.matchadd("myAnnotations", [[\<\(BUG\|WTF\|HACK\|TODO\|INFO\|NOTE\|WARNING\)\>]])

--------------------------------------------------------------------------------
-- Indentation
require("indent_blankline").setup {
	show_current_context = true,
	use_treesitter = true,
	strict_tabs = false,
	filetype_exclude = specialFiletypes,
}

--------------------------------------------------------------------------------
-- SCROLLBAR
require("scrollview").setup {
	current_only = false,
	winblend = 0,
	column = 1,
	excluded_filetypes = specialFiletypes,
}

--------------------------------------------------------------------------------
-- NOTIFICATIONS
if isGui() then
	opt.termguicolors = true
	vim.notify = require("notify") -- use notify.nvim for all vim notifications
	require("notify").setup {
		render = "minimal",
		stages = "slide",
		level = 0, -- minimum severity level to display (0 = display all)
		max_height = 15,
		max_width = 50,
		minimum_width = 10,
		timeout = 4000,
		top_down = false,
	}
end

-- replace lua's print message with notify.nvim → https://www.reddit.com/r/neovim/comments/xv3v68/tip_nvimnotify_can_be_used_to_display_print/
-- selene: allow(incorrect_standard_library_use)
print = function(...)
	local print_safe_args = {}
	local _ = {...}
	for i = 1, #_ do
		table.insert(print_safe_args, tostring(_[i]))
	end
	vim.notify(table.concat(print_safe_args, " "), vim.log.levels.INFO)
end

--------------------------------------------------------------------------------
-- DRESSING
require("dressing").setup {
	input = {
		border = borderStyle,
		relative = "win",
		insert_only = false,
		win_options = {sidescrolloff = 0},
	},
	select = {
		backend = {"nui", "builtin"}, -- Priority list of preferred vim.select implementations
		trim_prompt = true, -- Trim trailing `:` from prompt
		builtin = {
			border = borderStyle,
			relative = "cursor",
			max_width = 60,
			min_width = 18,
			max_height = 12,
			min_height = 4,
		},
	},
}

--------------------------------------------------------------------------------
-- GUTTER
require("gitsigns").setup {
	max_file_length = 10000,
	preview_config = {border = borderStyle},
}

--------------------------------------------------------------------------------

-- PRETTY FOLD
require("pretty-fold").setup {
	sections = {
		left = {"content"},
		right = {"  ﬔ  ", "number_of_folded_lines"},
	},
	fill_char = "",
	process_comment_signs = false,
	keep_indentation = true,
}

--------------------------------------------------------------------------------
-- AUTO-RESIZE WINDOWS/SPLITS
require("windows").setup {
	autowidth = {
		enable = true,
		winwidth = 15,
	},
	ignore = {filetype = {"Mundo", "MundoDiff", "netrw"}}
}

--------------------------------------------------------------------------------
-- STATUS LINE (LUALINE)

-- simple alternative to fidget.nvim, via https://www.reddit.com/r/neovim/comments/o4bguk/comment/h2kcjxa/
local function lsp_progress()
	local messages = vim.lsp.util.get_progress_messages()
	if #messages == 0 then return "" end
	local client = messages[1].name and messages[1].name .. ": " or ""
	if client:find("null%-ls") then return "" end

	local progress = messages[1].percentage or 0
	local task = messages[1].title or ""
	task = task:gsub("^(%w+).*", "%1") -- only first word
	local spinners = {"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}
	local ms = vim.loop.hrtime() / 1000000
	local frame = math.floor(ms / 120) % #spinners
	return client .. progress .. "%% " .. task .. " " .. spinners[frame + 1]
end

local function readOnly()
	if bo.modifiable then
		return ""
	else
		return ""
	end
end

local function alternateFile()
	local maxLen = 15
	local altFile = fn.expand("#:t")
	local curFile = fn.expand("%:t")
	local altPath = fn.expand("#:p")
	local curPath = fn.expand("%:p")
	if altPath == curPath or altFile == "" then
		return ""
	elseif curFile == altFile then
		local altParent = fn.expand("#:p:h:t")
		if #altParent > maxLen then altParent = altParent:sub(1, maxLen) .. "…" end
		return altParent .. "/" .. altFile
	end
	return "# " .. altFile
end

local function currentFile() -- using this function instead of default filename, since this does not show "[No Name]" for Telescope
	local maxLen = 15
	local altFile = fn.expand("#:t")
	local curFile = fn.expand("%:t")
	local altPath = fn.expand("#:p")
	local curPath = fn.expand("%:p")
	if curFile == altFile and not (altPath == curPath) then
		local curParent = fn.expand("%:p:h:t")
		if #curParent > maxLen then curParent = curParent:sub(1, maxLen) .. "…" end
		return curParent .. "/" .. curFile
	end
	return "%% " .. curFile -- "%" is lua's escape character and therefore needs to be escaped itself
end

local function mixedIndentation()
	local ft = bo.filetype
	if vim.tbl_contains(specialFiletypes, ft) or ft == "css" or ft == "markdown" then
		return ""
	end

	local hasTabs = fn.search("^\t", "nw") > 0
	local hasSpaces = fn.search("^ ", "nw") > 0
	local mixed = fn.search([[^\(\t\+ \| \+\t\)]], "nw") ~= 0

	if (hasSpaces and hasTabs) or mixed then
		return "  mixed"
	elseif hasSpaces and not (bo.expandtab) then
		return " et"
	elseif hasTabs and bo.expandtab then
		return " noet"
	end
	return ""
end

-- show branch info only when not on main/master
augroup("branchChange", {})
autocmd({"BufEnter", "FocusGained"}, {
	group = "branchChange",
	callback = function()
		g.cur_branch = trim(fn.system("git branch --show-current"))
	end
})

local function isStandardBranch() -- not checking for branch here, since running the condition check too often results in lock files and also makes the cursor glitch for whatever reason…
	local branch = g.cur_branch
	local notMainBranch = branch ~= "main" and branch ~= "master"
	local validFiletype = bo.filetype ~= "help" -- vim help files are located in a git repo
	return notMainBranch and validFiletype
end

local function debuggerStatus()
	local dapStatus = require("dap").status()
	if dapStatus ~= "" then
		return "  " .. dapStatus
	else
		return ""
	end
end

-- NAVIC
local navic = require("nvim-navic")
navic.setup {
	icons = {Object = "ﴯ "},
	separator = "  ",
	depth_limit = 8,
	depth_limit_indicator = "…",
}

local function showBreadcrumbs()
	return navic.is_available() and not (bo.filetype == "css")
end

local function selectionCount()
	if not (fn.mode():find("[vV]")) then return "" end
	local starts = fn.line("v")
	local ends = fn.line(".")
	local lines = starts <= ends and ends - starts + 1 or starts - ends + 1
	return tostring(lines) .. "l " .. tostring(fn.wordcount().visual_chars) .. "c"
end

--------------------------------------------------------------------------------

local secSeparators
if isGui() then
	secSeparators = {left = " ", right = " "} -- nerdfont: 'nf-ple'
	winSecSeparators = {left = "", right = ""}
else
	secSeparators = {left = "", right = ""} -- separators look off in Terminal
	winSecSeparators = {left = "", right = ""}
end

require("lualine").setup {
	sections = {
		lualine_a = {"mode"},
		lualine_b = {
			{readOnly},
			{currentFile},
		},
		lualine_c = {{alternateFile}},
		lualine_x = {
			{"searchcount", fmt = function(str)
				if str == "" then return "" end
				return " " .. str:sub(2, -2)
			end},
			"diagnostics",
			{lsp_progress},
			{mixedIndentation},
		},
		lualine_y = {
			"diff",
			{"branch", cond = isStandardBranch},
		},
		lualine_z = {
			"location",
			{selectionCount},
		},
	},
	winbar = {
		lualine_b = {{
			navic.get_location,
			cond = showBreadcrumbs,
			section_separators = winSecSeparators,
		}},
		lualine_c = {{
			function() return " " end, -- dummy to avoid bar appearing and disappearing
			cond = showBreadcrumbs,
		}},
		lualine_z = {
			{debuggerStatus, section_separators = winSecSeparators},
			{require("recorder").recordingStatus, section_separators = winSecSeparators},
		},
	},
	options = {
		theme = "auto",
		ignore_focus = specialFiletypes,
		globalstatus = true,
		component_separators = {left = "", right = ""},
		section_separators = secSeparators,
		extensions = {"nvim-dap-ui"},
		disabled_filetypes = {
			statusline = specialFiletypes,
			-- winbar = specialFiletypes,
		},
	},
}
