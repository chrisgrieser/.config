require("utils")
--------------------------------------------------------------------------------

-- custom highlights
-- have to wrapped in function and regularly called due to auto-dark-mode
-- regularly resetting the theme
function customHighlights()
	local highlights = {
		"DiagnosticUnderlineError",
		"DiagnosticUnderlineWarn",
		"DiagnosticUnderlineHint",
		"DiagnosticUnderlineInfo",
		"SpellLocal",
		"SpellRare",
		"SpellCap",
		"SpellBad",
	}
	for _, v in pairs(highlights) do
		cmd("highlight " .. v .. " gui=underline")
	end

	-- active indent
	cmd [[highlight! def link IndentBlanklineContextChar Comment]]

	-- URLs
	cmd [[highlight urls cterm=underline term=underline gui=underline]]
	fn.matchadd("urls", [[http[s]\?:\/\/[[:alnum:]%\/_#.\-?:=&]*]])

	-- rainbow brackets without agressive red…
	cmd [[highlight rainbowcol1 guifg=#7e8a95]] -- no aggressively red brackets…

	-- treesittter refactor focus
	cmd [[highlight TSDefinition term=underline gui=underdotted]]
	cmd [[highlight TSDefinitionUsage term=underline gui=underdotted]]

	-- Custom Highlight-Group, used for various LSP Hints
	cmd [[highlight GhostText guifg=#7c7c7c]]

end

customHighlights()

-- mixed whitespace
cmd [[highlight! def link MixedWhiteSpace Folded]]
cmd [[call matchadd('MixedWhiteSpace', '^\(\t\+ \| \+\t\)[ \t]*')]]

-- Annotations
cmd [[highlight! def link myAnnotations Todo]] -- use same styling as "TODO"
cmd [[call matchadd('myAnnotations', '\<\(TODO\|INFO\|NOTE\|WARNING\|WARN\|REQUIRED\)\>') ]]

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
		Misc = {
			priority = 1,
			highlight = "Normal",
		},
	},
	excluded_filetypes = specialFiletypes,
}
require("scrollbar.handlers.gitsigns").setup()

-- custom scrollbar showing current location and last jump (if in same buffer)
-- https://github.com/petertriho/nvim-scrollbar#custom-handlers
require("scrollbar.handlers").register("lastjump", function(bufnr)
	local lastJump = fn.getjumplist()[2]
	local lastJumpPos = fn.getjumplist()[1][lastJump]
	local currentLnum = fn.line(".")
	local out = {{
		line = currentLnum,
		text = "ﱢ",
		type = "Misc",
		level = 6,
	}}
	if lastJumpPos.bufnr == bufnr then
		table.insert(out, {
			line = lastJumpPos.lnum,
			text = "▶️",
			type = "Misc",
			level = 6,
		})
	end
	return out
end)


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
-- STATUS LINE (LuaLine)

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
			{"searchcount", fmt = function(str) return str:sub(2, -2) end},
			"diagnostics",
			{mixedIndentation}
		},
		lualine_y = {
			"diff",
			{"branch", cond = isStandardBranch,}
		},
		lualine_z = {
			-- {"location", separator = ""},
			"location",
		},
	},
	options = {
		theme = "auto",
		globalstatus = true,
		component_separators = {left = "", right = ""},
		section_separators = secSeparators,
	},
}
