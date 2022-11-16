require("utils")
--------------------------------------------------------------------------------

-- mixed whitespace
cmd [[highlight! def link MixedWhiteSpace Folded]]
cmd [[call matchadd('MixedWhiteSpace', '^\(\t\+ \| \+\t\)[ \t]*')]]

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
	marks = {
		GitChange = {text = "┃"},
		GitAdd = {text = "┃"},
		Cursor = {highlight = "Comment"}, -- less dark
		Misc = {
			priority = 1,
			highlight = "Normal",
		},
	},
	excluded_filetypes = specialFiletypes,
}
require("scrollbar.handlers.gitsigns").setup()


-- Custom Scrollbar Handlers https://github.com/petertriho/nvim-scrollbar#custom-handlers
-- HACK using one custom function instead of two due to https://github.com/petertriho/nvim-scrollbar/issues/66
require("scrollbar.handlers").register("marksmarks", function(bufnr)
	-- marks in scrollbar
	local excluded_marks = "z"
	local marks = fn.getmarklist(bufnr) ---@diagnostic disable-line: param-type-mismatch
	local out = {}
	table.insert(out, {line = 0, text = ""}) -- ensure at least one dummy element in return list to prevent errors when there is no valid mark
	for _, markObj in pairs(marks) do
		local mark = markObj.mark:sub(2, 2)
		local isLetter = mark:lower() ~= mark:upper()
		if isLetter and not (excluded_marks:find(mark)) then
			table.insert(out, {
				line = markObj.pos[2],
				text = mark,
				type = "Info",
				level = 6,
			})
		end
	end

	-- last jumplocation
	local lastJump = fn.getjumplist()[2]
	local lastJumpPos = fn.getjumplist()[1][lastJump]
	if lastJumpPos.bufnr == bufnr and lastJumpPos.lnum > 1 then
		table.insert(out, {
			line = lastJumpPos.lnum,
			text = "▶️",
			type = "Misc",
			level = 6,
		})
	end

	return out
end)

-- HACK workaround due to neovim's `:delmarks` not persistently deleting marks
-- https://www.reddit.com/r/neovim/comments/qliuid/the_overly_persistent_marks_problem/
-- https://github.com/neovim/neovim/issues/4295
augroup("delmarksFix", {})
autocmd("BufReadPost", {
	group = "delmarksFix",
	command = "delmarks a-z",
})

--------------------------------------------------------------------------------
-- Notifications
opt.termguicolors = true
vim.notify = require("notify") -- use notify.nvim for all vim notifications

require("notify").setup {
	icons = {WARN = ""},
	render = "minimal", -- styles, "default"|"minimal"|"simple"
	minimum_width = 25,
	timeout = 4000,
	top_down = false,
}

-- replace lua's print message with notify.nvim → https://www.reddit.com/r/neovim/comments/xv3v68/tip_nvimnotify_can_be_used_to_display_print/
print = function(...)
	local print_safe_args = {}
	local _ = {...}
	for i = 1, #_ do
		table.insert(print_safe_args, tostring(_[i]))
	end
	vim.notify(table.concat(print_safe_args, " "), "info") ---@diagnostic disable-line: param-type-mismatch
end

--------------------------------------------------------------------------------
-- DRESSING
require("dressing").setup {
	input = {
		border = borderStyle,
		winblend = 4, -- % transparency
		relative = "win",
	},
	select = {
		backend = {"builtin", "telescope", "nui"}, -- Priority list of preferred vim.select implementations
		trim_prompt = true, -- Trim trailing `:` from prompt
		builtin = {
			border = borderStyle,
			relative = "cursor",
			winblend = 4,
			max_width = 80,
			min_width = 18,
			max_height = 12,
			min_height = 4,
		},
		telescope = {
			initial_mode = "normal",
			prompt_prefix = "  ",
			layout_strategy = "cursor",
			results_title = "",
			sorting_strategy = "ascending",
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
-- DIAGNOSTICS

-- ▪︎▴• ▲  
-- https://www.reddit.com/r/neovim/comments/qpymbb/lsp_sign_in_sign_columngutter/
local signs = {
	Error = "",
	Warn = "▲",
	Info = "",
	Hint = "",
}
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl}) ---@diagnostic disable-line: redundant-parameter, param-type-mismatch
end

--------------------------------------------------------------------------------
-- STATUS LINE (LUALINE)

local function lsp_progress()
	-- https://www.reddit.com/r/neovim/comments/o4bguk/comment/h2kcjxa/?utm_source=share&utm_medium=web2x&context=3
	local messages = vim.lsp.util.get_progress_messages()
	if #messages == 0 then return "" end
	local progess = messages[1].percentage or 0
	local task = messages[1].title or ""
	task = task:gsub("^(%w+).*", "%1") -- only first word

	local spinners = {"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}
	local ms = vim.loop.hrtime() / 1000000
	local frame = math.floor(ms / 120) % #spinners
	return progess .. "%% " .. task .. " " .. spinners[frame + 1]
end

local function recordingStatus()
	if g.isRecording then return "[ REC]"
	else return "" end
end

local function alternateFile()
	local altPath = fn.expand("#:p")
	local curPath = fn.expand("%:p")
	local altFile = fn.expand("#:t")
	if altPath == curPath or altFile == "" then return "" end
	return "# " .. altFile
end

local function currentFile() -- using this function instead of default filename, since this does not show "[No Name]" for Telescope
	local curFile = fn.expand("%:t")
	if curFile == "" then return "" end
	return "%% " .. curFile -- "%" is lua's escape character and therefore needs to be escaped itself
end

local function mixedIndentation()
	local ft = bo.filetype
	if vim.tbl_contains(specialFiletypes, ft) or ft == "css" or ft == "markdown" then
		return ""
	end

	local hasTabs = fn.search("^\t", "nw") ~= 0
	local hasSpaces = fn.search("^ ", "nw") ~= 0
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
else
	secSeparators = {left = "", right = ""} -- separators look off in Terminal
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

require("lualine").setup {
	sections = {
		lualine_a = {"mode"},
		lualine_b = {{currentFile}},
		lualine_c = {{alternateFile}},
		lualine_x = {
			{recordingStatus},
			{"searchcount", fmt = function(str)
				if str == "" then return "" end
				return " " .. str:sub(2, -2)
			end},
			{lsp_progress},
			"diagnostics",
			{mixedIndentation},
		},
		lualine_y = {
			"diff",
			{"branch", cond = isStandardBranch,},
		},
		lualine_z = {"location"},
	},
	options = {
		theme = "auto",
		globalstatus = true,
		component_separators = {left = "", right = ""},
		section_separators = secSeparators,
	},
}
