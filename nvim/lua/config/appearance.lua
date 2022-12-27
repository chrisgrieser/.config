require("config/utils")
--------------------------------------------------------------------------------

-- Annotations
cmd.highlight { "def link myAnnotations Todo", bang = true } -- use same styling as "TODO"
fn.matchadd(
	"myAnnotations",
	[[\<\(BUG\|WIP\|TODO\|WTF\|HACK\|INFO\|NOTE\|WARNING\|FIX\|REQUIRED\)\>]]
)

--------------------------------------------------------------------------------

-- INDENTATION
require("indent_blankline").setup {
	show_current_context = true,
	use_treesitter = true,
	strict_tabs = false,
	filetype_exclude = {},
}

--------------------------------------------------------------------------------
-- CyBu (Cycle Buffer)
require("cybu").setup {
	display_time = 1000,
	position = {
		anchor = "bottomcenter",
		max_win_height = 12,
		vertical_offset = 3,
	},
	style = {
		border = borderStyle,
		padding = 7,
		path = "tail",
		hide_buffer_id = true,
		highlights = {
			current_buffer = "CursorLine",
			adjacent_buffers = "Normal",
		},
	},
	behavior = {
		mode = {
			default = {
				switch = "immediate",
				view = "paging",
			},
		},
	},
	exclude = {},
}

--------------------------------------------------------------------------------
-- SCROLLBAR
require("satellite").setup {
	current_only = true,
	winblend = 30,
	excluded_filetypes = {},
	handlers = {
		marks = { enable = false },
	},
}

--------------------------------------------------------------------------------
-- virtual color column --- '│'
g.virtcolumn_char = "║"

--------------------------------------------------------------------------------
-- NOTIFICATIONS
if isGui() then
	local notifyWidth = 55

	opt.termguicolors = true
	require("notify").setup {
		render = "minimal",
		stages = "slide",
		level = 0, -- minimum severity level to display (0 = display all)
		max_height = 25,
		max_width = notifyWidth, -- HACK see below
		minimum_width = 13,
		timeout = 4000,
		top_down = false,
		on_open = function(win)
			if api.nvim_win_is_valid(win) then
				api.nvim_win_set_config(win, { border = borderStyle })
			end
		end,
	}

	-- HACK requires custom wrapping setup https://github.com/rcarriga/nvim-notify/issues/129
	-- replaces vim.notify = require("notify")
	local function split_length(text, length)
		local lines = {}
		local next_line
		while true do
			if #text == 0 then return lines end
			next_line, text = text:sub(1, length), text:sub(length)
			lines[#lines + 1] = next_line
		end
	end

	vim.notify = function(msg, level, opts) ---@diagnostic disable-line: duplicate-set-field
		if type(msg) == "string" then msg = vim.split(msg, "\n", { trimepty = true }) end
		local truncated = {}
		for _, line in pairs(msg) do
			local new_lines = split_length(line, notifyWidth)
			for _, nl in ipairs(new_lines) do
				table.insert(truncated, " " .. trim(nl) .. " ")
			end
		end
		return require("notify")(truncated, level, opts)
	end
end

-- replace lua's print message with notify.nvim → https://www.reddit.com/r/neovim/comments/xv3v68/tip_nvimnotify_can_be_used_to_display_print/
-- selene: allow(incorrect_standard_library_use)
print = function(...)
	local print_safe_args = {}
	local _ = { ... }
	for i = 1, #_ do
		table.insert(print_safe_args, tostring(_[i]))
	end
	vim.notify(table.concat(print_safe_args, " "), vim.log.levels.INFO, { timeout = 10000 })
end

--------------------------------------------------------------------------------
-- DRESSING
require("dressing").setup {
	input = {
		border = borderStyle,
		relative = "win",
		max_width = 50, -- length git commit msg
		min_width = 50,
		win_options = {
			sidescrolloff = 0,
			winblend = 0,
		},
		insert_only = false, -- enable normal mode
		mappings = {
			n = { ["q"] = "Close" },
		},
	},
	select = {
		backend = { "builtin" }, -- Priority list of preferred vim.select implementations
		trim_prompt = true, -- Trim trailing `:` from prompt
		builtin = {
			border = borderStyle,
			relative = "cursor",
			max_width = 60,
			min_width = 18,
			max_height = 12,
			min_height = 4,
			mappings = {
				["q"] = "Close",
				["Esc"] = "Close",
			},
		},
	},
}

--------------------------------------------------------------------------------
-- GUTTER
require("gitsigns").setup {
	max_file_length = 10000,
	preview_config = { border = borderStyle },
}

--------------------------------------------------------------------------------
-- AUTO-RESIZE WINDOWS/SPLITS
require("windows").setup {
	autowidth = {
		enable = true,
		winwidth = 0.7, -- active window gets 70% of total width
	},
	ignore = {
		filetype = { "netrw" }, -- BUG https://github.com/anuvyklack/windows.nvim/issues/30
	},
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
	local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
	local ms = vim.loop.hrtime() / 1000000
	local frame = math.floor(ms / 120) % #spinners
	return client .. progress .. "%% " .. task .. " " .. spinners[frame + 1]
end

local function alternateFile()
	local maxLen = 15
	local altFile = expand("#:t")
	local curFile = expand("%:t")
	local altPath = expand("#:p")
	local curPath = expand("%:p")
	if altPath == curPath then
		return ""	
	elseif altFile == "" then
		local lastOldfile = vim.v.oldfiles[2]:gsub(".*/", "") -- 1 is the current file
		return "# ("..lastOldfile..")"
	elseif curFile == altFile then
		local altParent = expand("#:p:h:t")
		if #altParent > maxLen then altParent = altParent:sub(1, maxLen) .. "…" end
		return altParent .. "/" .. altFile
	end
	return "# " .. altFile
end

local function currentFile() -- using this function instead of default filename, since this does not show "[No Name]" for Telescope
	local readOnly = bo.modifiable and "" or " "
	local maxLen = 15
	local altFile = expand("#:t")
	local curFile = expand("%:t")
	if curFile == altFile then
		local curParent = expand("%:p:h:t")
		if #curParent > maxLen then curParent = curParent:sub(1, maxLen) .. "…" end
		return curParent .. "/" .. curFile
	end
	return "%% " .. curFile .. readOnly
end

local function mixedIndentation()
	if fn.mode() == "i" then return "" end
	local ft = bo.filetype
	local ignoredFts = { "css", "markdown", "sh", "" }
	if vim.tbl_contains(ignoredFts, ft) then return "" end

	local hasTabs = fn.search("^\t", "nw") > 0
	local hasSpaces = fn.search("^ ", "nw") > 0
	local mixed = fn.search([[^\(\t\+ \| \+\t\)]], "nw") ~= 0

	if (hasSpaces and hasTabs) or mixed then
		return "  mixed"
	elseif hasSpaces and not bo.expandtab then
		return "  et"
	elseif hasTabs and bo.expandtab then
		return "  noet"
	end
	return ""
end

-- show branch info only when not on main/master
augroup("branchChange", {})
autocmd({ "BufEnter", "FocusGained", "WinEnter", "TabEnter" }, {
	group = "branchChange",
	callback = function() g.cur_branch = trim(fn.system("git branch --show-current")) end,
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
	return "/  " .. tostring(lines) .. "l " .. tostring(fn.wordcount().visual_chars) .. "c"
end

--------------------------------------------------------------------------------

-- nerdfont: 'nf-ple'; since separators look off in Terminal
local secSeparators = isGui() and { left = " ", right = " " } or { left = "", right = "" }
local winSecSeparators = isGui() and { left = "", right = "" } or { left = "", right = "" }

require("lualine").setup {
	sections = {
		lualine_a = { { currentFile } },
		lualine_b = { { alternateFile } },
		lualine_c = {
			{ lsp_progress },
			{
				"searchcount",
				fmt = function(str)
					if str == "" or str == "[0/0]" then return "" end
					return " " .. str:sub(2, -2)
				end,
			},
		},
		lualine_x = {
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
				section_separators = winSecSeparators,
			},
		},
		lualine_c = {
			{
				function() return " " end, -- dummy to avoid bar appearing and disappearing
				cond = showBreadcrumbs,
			},
		},
		lualine_x = {},
		lualine_y = {
			{ debuggerStatus, section_separators = winSecSeparators },
		},
		lualine_z = {
			{ require("recorder").recordingStatus, section_separators = winSecSeparators },
			{ require("recorder").displaySlots, section_separators = winSecSeparators },
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
		section_separators = secSeparators,
		extensions = { "nvim-dap-ui" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
	},
}
