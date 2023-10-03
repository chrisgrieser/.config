local M = {}
local u = require("config.utils")
local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

--------------------------------------------------------------------------------
-- CONFIG
local commentHrChar = "─"
local commentWidth = vim.opt_local.textwidth:get()
local toggleSigns = {
	["="] = "!",
	["|"] = "&",
	[","] = ";",
	["'"] = '"',
	["^"] = "$",
	["/"] = "*",
	["+"] = "-",
	["("] = ")",
	["["] = "]",
	["{"] = "}",
	["<"] = ">",
}

--------------------------------------------------------------------------------

-- https://github.com/numToStr/Comment.nvim/issues/22#issuecomment-1272569139
function M.commented_lines_textobject()
	local U = require("Comment.utils")
	local cl = vim.api.nvim_win_get_cursor(0)[1] -- current line
	local range = { srow = cl, scol = 0, erow = cl, ecol = 0 }
	local ctx = { ctype = U.ctype.linewise, range = range }
	local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
	local ll, rr = U.unwrap_cstr(cstr)
	local padding = true
	local is_commented = U.is_commented(ll, rr, padding)
	local line = vim.api.nvim_buf_get_lines(0, cl - 1, cl, false)
	if next(line) == nil or not is_commented(line[1]) then return end
	local rs, re = cl, cl -- range start and end
	repeat
		rs = rs - 1
		line = vim.api.nvim_buf_get_lines(0, rs - 1, rs, false)
	until next(line) == nil or not is_commented(line[1])
	rs = rs + 1
	repeat
		re = re + 1
		line = vim.api.nvim_buf_get_lines(0, re - 1, re, false)
	until next(line) == nil or not is_commented(line[1])
	re = re - 1
	vim.fn.execute("normal! " .. rs .. "GV" .. re .. "G")
end

function M.commentHr()
	local wasOnBlank = vim.api.nvim_get_current_line() == ""
	local indent = vim.fn.indent(".") ---@diagnostic disable-line: param-type-mismatch
	local comStr = vim.bo.commentstring
	local ft = vim.bo.filetype
	local comStrLength = #(comStr:gsub(" ?%%s ?", ""))

	if comStr == "" then
		u.notify("No commentstring for this filetype available.", "warn")
		return
	end
	if comStr:find("-") then commentHrChar = "-" end

	local linelength = commentWidth - indent - comStrLength

	-- the common formatters (black and stylelint) demand extra spaces
	local fullLine
	if ft == "css" then
		fullLine = " " .. commentHrChar:rep(linelength - 2) .. " "
	elseif ft == "python" then
		fullLine = " " .. commentHrChar:rep(linelength - 1)
	else
		fullLine = commentHrChar:rep(linelength)
	end

	-- set HR
	local hr = comStr:gsub(" ?%%s ?", fullLine)
	if ft == "markdown" then hr = "---" end

	local linesToAppend = { "", hr, "" }
	if wasOnBlank then linesToAppend = { hr, "" } end

	vim.fn.append(".", linesToAppend) ---@diagnostic disable-line: param-type-mismatch

	-- shorten if it was on blank line, since fn.indent() does not return indent
	-- line would have if it has content
	if wasOnBlank then
		normal("j==")
		local hrIndent = vim.fn.indent(".") ---@diagnostic disable-line: param-type-mismatch

		-- cannot use simply :sub, since it assumes one-byte-size chars
		local hrLine = vim.api.nvim_get_current_line()
		hrLine = hrLine:gsub(commentHrChar, "", hrIndent)
		vim.api.nvim_set_current_line(hrLine)
	else
		normal("jj==")
	end
end

--------------------------------------------------------------------------------

function M.openAlfredPref()
	local parentFolder = vim.fn.expand("%:p:h")
	if not parentFolder:find("Alfred%.alfredpreferences") then
		u.notify("", "Not in an Alfred directory.", "warn")
		return
	end
	-- URI seems more reliable than JXA when called via nvim https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local workflowId = parentFolder:match("Alfred%.alfredpreferences/workflows/([^/]+)")
	vim.fn.system { "open", "alfredpreferences://navigateto/workflows>workflow>" .. workflowId }
	-- in case the right workflow is already open, Alfred is not focused.
	-- Therefore manually focusing in addition to that here as well.
	vim.fn.system { "open", "-a", "Alfred Preferences" }
end

function M.toggleCase()
	local col = vim.fn.col(".") -- fn.col correctly considers tab-indentation
	local charUnderCursor = vim.api.nvim_get_current_line():sub(col, col)
	local isLetter = charUnderCursor:find("^%a$")
	if isLetter then
		normal("~h")
		return
	end
	for left, right in pairs(toggleSigns) do
		if charUnderCursor == left then normal("r" .. right) end
		if charUnderCursor == right then normal("r" .. left) end
	end
end

function M.openNewScope()
	local line = vim.api.nvim_get_current_line()
	local trailChar = line:match(",? *$")
	line = line:gsub(" *,? *$", "") .. " {" -- edit current line
	vim.api.nvim_set_current_line(line)
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	local indent = line:match("^%s*")
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. "\t", indent .. "}" .. trailChar })
	vim.api.nvim_win_set_cursor(0, { ln + 1, 1 }) -- go line down
	vim.cmd.startinsert { bang = true }
end

--------------------------------------------------------------------------------

---@param toMode "on"|"off"|"toggle"
function M.wrap(toMode)
	local turnOn = (toMode == "toggle" and not vim.opt_local.wrap:get()) or toMode == "on"
	local turnOff = (toMode == "toggle" and vim.opt_local.wrap:get()) or toMode == "off"

	if turnOn then
		vim.opt_local.wrap = true
		vim.opt_local.colorcolumn = ""
		vim.keymap.set("n", "A", "g$a", { buffer = true })
		vim.keymap.set("n", "I", "g^i", { buffer = true })
		vim.keymap.set("n", "H", "g^", { buffer = true })
		vim.keymap.set("n", "L", "g$", { buffer = true })
	elseif turnOff then
		vim.opt_local.wrap = false
		vim.opt_local.colorcolumn = vim.opt.colorcolumn:get()
		pcall(vim.keymap.del, "n", "A", { buffer = true })
		pcall(vim.keymap.del, "n", "I", { buffer = true })
		pcall(vim.keymap.del, "n", "H", { buffer = true })
		pcall(vim.keymap.del, "n", "L", { buffer = true })
	end
end

--------------------------------------------------------------------------------

function M.openAtRegex101()
	-- keymaps assume a/ and i/ mapped as regex textobj via treesitter textobj
	vim.cmd.normal { '"zya/', bang = false } -- yank outer regex
	vim.cmd.normal { "vi/", bang = false } -- select inner regex for easy replacement

	local regex = vim.fn.getreg("z")
	local pattern = regex:match("/(.*)/")
	local flags = regex:match("/.*/(%l*)")
	local replacement = vim.api.nvim_get_current_line():match('replace ?%(/.*/.*, ?"(.-)"')

	-- https://github.com/firasdib/Regex101/wiki/FAQ#how-to-prefill-the-fields-on-the-interface-via-url
	local url = "https://regex101.com/?regex=" .. pattern .. "&flags=" .. flags
	if replacement then url = url .. "&subst=" .. replacement end

	vim.fn.system { "open", url }
end

--------------------------------------------------------------------------------

local pinWinNr

---Toggles pin-window
function M.pinWin()
	-- CONFIG
	local width = 0.45
	local height = 0.35

	-- if already open, just close is
	local pinWinOpen = vim.tbl_contains(vim.api.nvim_list_wins(), pinWinNr)
	if pinWinOpen then
		vim.api.nvim_win_close(pinWinNr, true)
		return
	end

	-- create pin window
	local bufnr = 0 -- current buffer
	pinWinNr = vim.api.nvim_open_win(bufnr, false, {
		relative = "win",
		width = math.floor(vim.api.nvim_win_get_width(0) * width),
		height = math.floor(vim.api.nvim_win_get_height(0) * height),
		anchor = "NE",
		row = 0,
		col = vim.api.nvim_win_get_width(0),
		style = "minimal",
		border = u.borderStyle,
		title = "  " .. vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)) .. " ",
		title_pos = "center",
	})
	vim.api.nvim_win_set_option(pinWinNr, "scrolloff", 2)
	vim.api.nvim_win_set_option(pinWinNr, "sidescrolloff", 2)
	vim.api.nvim_win_set_option(pinWinNr, "signcolumn", "no")
end

--------------------------------------------------------------------------------

return M
