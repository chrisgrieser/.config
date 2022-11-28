require("utils")
--------------------------------------------------------------------------------

-- mixed whitespace
cmd [[highlight! def link MixedWhiteSpace Folded]]
cmd [[call matchadd('MixedWhiteSpace', '^\(\t\+ \| \+\t\)')]]

-- Annotations
cmd [[highlight! def link myAnnotations Todo]] -- use same styling as "TODO"
cmd [[call matchadd('myAnnotations', '\<\(HACK\|TODO\|INFO\|NOTE\|WARNING\|WARN\|REQUIRED\)\>') ]]

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
require("scrollbar").setup {
	handle = {highlight = "Folded"}, -- bit darker
	handlers = {cursor = false},
	marks = {
		GitChange = {text = "┃"},
		GitAdd = {text = "┃"},
		Error = {text = {signIcons.Error}},
		Warn = {text = {signIcons.Warn}},
		Info = {text = {signIcons.Info}},
		Hint = {text = {signIcons.Hint}},
		Cursor = {highlight = "Comment"}, -- less dark
		Misc = {
			priority = 1,
			highlight = "Normal",
			text = "", -- no "=" at the top of the file
		},
	},
	excluded_filetypes = specialFiletypes,
}
require("scrollbar.handlers.gitsigns").setup()


-- Custom Scrollbar Handlers https://github.com/petertriho/nvim-scrollbar#custom-handlers

-- last jumplocation
require("scrollbar.handlers").register("lastjumploc", function(bufnr)
	local lastJump = fn.getjumplist()[2]
	local lastJumpPos = fn.getjumplist()[1][lastJump]
	if lastJumpPos.bufnr == bufnr and lastJumpPos.lnum > 1 then
		return {{
			line = lastJumpPos.lnum,
			text = "▶️",
			type = "Misc",
			level = 6,
		}}
	end
	return {{line = 0, text = ""}} -- dummy element to prevent error
end)

-- marks in scrollbar
require("scrollbar.handlers").register("marksmarks", function(bufnr)
	local excluded_marks = "z"

	local marks = fn.getmarklist(bufnr)
	local marksGlobal = fn.getmarklist()
	concatTables(marks, marksGlobal)

	local out = {}
	table.insert(out, {line = 0, text = ""}) -- ensure at least one dummy element in return list to prevent errors when there is no valid mark
	for _, markObj in pairs(marks) do
		local markName = markObj.mark:sub(2, 2)

		local isLetter = markName:lower() ~= markName:upper()
		local isGlobalMark = markObj.file
		local markIsInThisFile = true
		if isGlobalMark then
			local pathOfMark = markObj.file:gsub("~", home)
			local curBufPath = fn.expand("%:p")
			markIsInThisFile = pathOfMark == curBufPath
		end

		if isLetter and not (excluded_marks:find(markName)) and markIsInThisFile then
			table.insert(out, {
				line = markObj.pos[2],
				text = markName,
				type = "Info",
				level = 6,
			})
		end
	end
	return out
end)


-- HACK workaround due to neovim's `:delmarks` not persistently deleting marks
-- https://www.reddit.com/r/neovim/comments/qliuid/the_overly_persistent_marks_problem/
-- https://github.com/neovim/neovim/issues/4295
augroup("delmarksFix", {})
autocmd("BufReadPost", {
	group = "delmarksFix",
	command = "delmarks a-zA-LN-Z",
})

--------------------------------------------------------------------------------
-- Notifications
if isGui() then
	opt.termguicolors = true
	vim.notify = require("notify") -- use notify.nvim for all vim notifications
	require("notify").setup {
		render = "minimal",
		stages = "slide",
		minimum_width = 25,
		max_height = 15,
		timeout = 4000,
		top_down = false,
	}
end

-- replace lua's print message with notify.nvim → https://www.reddit.com/r/neovim/comments/xv3v68/tip_nvimnotify_can_be_used_to_display_print/
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
		winblend = 4, -- % transparency
		relative = "win",
		insert_only = false,
	},
	select = {
		backend = {"builtin", "nui"}, -- Priority list of preferred vim.select implementations
		trim_prompt = true, -- Trim trailing `:` from prompt
		builtin = {
			border = borderStyle,
			relative = "cursor",
			winblend = 4,
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
-- FIDGET
require("fidget").setup {
	-- https://github.com/j-hui/fidget.nvim/blob/main/lua/fidget/spinners.lua
	text = {spinner = "dots"},
	fmt = {
		stack_upwards = false, -- false = title on top
	},
	sources = {
		["null-ls"] = {ignore = true}
	}
}

--------------------------------------------------------------------------------
-- STATUS LINE (LUALINE)

local function recordingStatus()
	if fn.reg_recording() ~= "" then return " RECORDING"
	else return "" end
end

local function alternateFile()
	local maxLen = 15
	local altFile = fn.expand("#:t")
	local curFile = fn.expand("%:t")
	if altFile == "" then
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
	if curFile == "" then
		return ""
	elseif curFile == altFile then
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

local secSeparators
if isGui() then
	secSeparators = {left = " ", right = " "} -- nerdfont: 'nf-ple'
	winSecSeparators = {left = "", right = ""}
else
	secSeparators = {left = "", right = ""} -- separators look off in Terminal
	winSecSeparators = {left = "", right = ""}
end

augroup("branchChange", {})
autocmd({"BufEnter", "FocusGained"}, {
	group = "branchChange",
	callback = function()
		g.cur_branch = trim(fn.system("git branch --show-current"))
	end
})

function isStandardBranch() -- not checking for branch here, since running the condition check too often results in lock files and also makes the cursor glitch for whatever reason…
	local branch = g.cur_branch
	local notMainBranch = branch ~= "main" and branch ~= "master"
	local validFiletype = bo.filetype ~= "help" -- vim help files are located in a git repo
	return notMainBranch and validFiletype
end

function debuggerStatus()
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
	icons = {
		Object = "ﴯ ",
	},
	separator = "  ",
	depth_limit = 10,
	depth_limit_indicator = "…",
	highlight = false,
}

local function showBreadcrumbs()
	-- breadcrumbs not useful in css, but winbar still needed for recordings
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

require("lualine").setup {
	sections = {
		lualine_a = {"mode"},
		lualine_b = {{currentFile}},
		lualine_c = {{alternateFile}},
		lualine_x = {
			{"searchcount", fmt = function(str)
				if str == "" then return "" end
				return " " .. str:sub(2, -2)
			end},
			"diagnostics",
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
			{recordingStatus, section_separators = winSecSeparators},
		},
	},
	options = {
		theme = "auto",
		ignore_focus = specialFiletypes,
		globalstatus = true,
		component_separators = {left = "", right = ""},
		section_separators = secSeparators,
	},
}
