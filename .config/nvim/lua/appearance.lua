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

	cmd [[highlight! def link IndentBlanklineContextChar Comment]]

	-- URLs
	cmd [[highlight urls cterm=underline term=underline gui=underline]]
	fn.matchadd("urls", [[http[s]\?:\/\/[[:alnum:]%\/_#.\-?:=&]*]])

	-- rainbow brackets without agressive red…
	cmd [[highlight rainbowcol1 guifg=#7e8a95]] -- no aggressively red brackets…
end

customHighlights()

-- mixed whitespace
cmd [[highlight! def link MixedWhiteSpace Folded]]
cmd [[call matchadd('MixedWhiteSpace', '^\(\t\+ \| \+\t\)[ \t]*')]]

-- Annotations
cmd [[highlight! def link myAnnotations Todo]] -- use same styling as "TODO"
cmd [[call matchadd('myAnnotations', '\<\(INFO\|NOTE\|WARNING\|WARN\|REQUIRED\)\>') ]]

-- Indention
require("indent_blankline").setup {
	show_current_context = true,
	use_treesitter = true,
	strict_tabs = false,
	filetype_exclude = specialFiletypes,
}

--------------------------------------------------------------------------------
-- pending on: https://github.com/folke/zen-mode.nvim/issues/47
-- ZEN MODE plugin
-- require("zen-mode").setup{
-- 	window = {
-- 		backdrop = 1,
-- 		width = 80,
-- 		height = 1, -- 1 = 100%
-- 	},
-- 	plugins = {
-- 		gitsigns = { enabled = true },
-- 		options = {
-- 			showcmd = true,
-- 			ruler = true,
-- 		},
-- 	},
-- 	on_open = customHighlights,
-- 	on_close = customHighlights,
-- }
--
-- augroup("markdownZen", {})
-- autocmd("BufEnter", {
-- 	group = "markdownZen",
-- 	pattern = "*.md",
-- 	command = [[ZenMode]],
-- })
-- autocmd("BufLeave", {
-- 	group = "markdownZen",
-- 	pattern = "*.md",
-- 	command = [[ZenMode]],
-- })

--------------------------------------------------------------------------------

-- GUTTER
opt.signcolumn = "yes:1"

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
	local altFile = api.nvim_exec('echo expand("#:t")', true)
	local curFile = api.nvim_exec('echo expand("%:t")', true)
	if altFile == curFile or altFile == "" then return "" end
	return "# " .. altFile
end

local function currentFile() -- using this function instead of default filename, since this does not show "[No Name]" for Telescope
	local curFile = api.nvim_exec('echo expand("%:t")', true)
	if not (curFile) or curFile == "" then return "" end
	return "%% " .. curFile -- "%" is lua's escape character and therefore needs to be escaped itself
end

local function mixedIndentation()
	if bo.filetype == "css" or bo.filetype == "markdown" or vim.tbl_contains(specialFiletypes, bo.filetype) then return "" end

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
	return not (branch == "main" or branch == "master")
end

require("lualine").setup {
	sections = {
		lualine_a = {"mode"},
		lualine_b = {{currentFile}},
		lualine_c = {{alternateFile}},
		lualine_x = {"searchcount", "diagnostics", {mixedIndentation}},
		lualine_y = {"diff", {"branch", cond = isStandardBranch}},
		lualine_z = {{"location", separator = ""}, "progress"},
	},
	options = {
		theme = "auto",
		globalstatus = true,
		component_separators = {left = "", right = ""},
		section_separators = secSeparators,
	},
}
