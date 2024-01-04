-- A bunch of commands that are too small to be published as plugins, but too
-- big to put in the main config, where they would crowd the actual
-- configuration. Every function is self-contained (except the helper
-- functions here), and should be binded to a keymap.
--------------------------------------------------------------------------------
local M = {}

---@param cmd string
local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

---@param msg string
---@param title string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(title, msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = title })
end

--------------------------------------------------------------------------------

---Convenience wrapper around `:cdo`, replaces nvim-spectre
function M.cdoSubstitute()
	-- GUARD
	local qf = vim.fn.getqflist { items = true, title = true }
	local quickfixQuery = qf.title:match("%((..-)%)") or ""
	if #qf.items == 0 then
		notify("Quickfix", "List empty.", "warn")
		return
	end
	vim.cmd("copen 15") -- to preview locations

	-- no g-flag, as rg returns one entry per match, even in same line
	local cmd = (":cdo s/%s//I"):format(quickfixQuery) -- prefill
	vim.api.nvim_feedkeys(cmd, "i", true)
	-- position cursor in cmdline
	local left2x = vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true)
	vim.defer_fn(function() vim.api.nvim_feedkeys(left2x, "i", false) end, 100)

	vim.api.nvim_create_autocmd("CmdlineLeave", {
		once = true,
		callback = function()
			vim.defer_fn(function()
				vim.cmd.cclose()
				vim.cmd.cfirst() -- move cursor back
				vim.cmd.cexpr("[]") -- clear quickfix
				vim.cmd.cfdo("silent update")
			end, 1)
		end,
	})
end

--------------------------------------------------------------------------------

function M.openAlfredPref()
	local parentFolder = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	if not parentFolder:find("Alfred%.alfredpreferences") then
		notify("", "Not in an Alfred directory.", "warn")
		return
	end
	-- URI seems more reliable than JXA when called via nvim https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local workflowId = parentFolder:match("Alfred%.alfredpreferences/workflows/([^/]+)")
	vim.fn.system { "open", "alfredpreferences://navigateto/workflows>workflow>" .. workflowId }
	-- in case the right workflow is already open, Alfred is not focused.
	-- Therefore manually focusing in addition to that here as well.
	vim.fn.system { "open", "-a", "Alfred Preferences" }
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

--- open the next regex at https://regex101.com/
function M.openAtRegex101()
	local lang = vim.bo.filetype
	local text, pattern, replace, flags

	if lang == "javascript" or lang == "typescript" then
		vim.cmd.TSTextobjectSelect("@regex.outer")
		normal('"zy')
		vim.cmd.TSTextobjectSelect("@regex.inner") -- reselect for easier pasting
		text = vim.fn.getreg("z")
		pattern = text:match("/(.*)/")
		flags = text:match("/.*/(%l*)") or "gm"
		replace = vim.api.nvim_get_current_line():match('replace ?%(/.*/.*, ?"(.-)"')
	elseif lang == "python" then
		normal('"zyi"vi"') -- yank & reselect inside quotes
		pattern = vim.fn.getreg("z")
		flags = "gm" -- TODO retrieve flags in a smarter way
	else
		notify("", "Unsupported filetype.", "warn")
		return
	end

	-- DOCS https://github.com/firasdib/Regex101/wiki/FAQ#how-to-prefill-the-fields-on-the-interface-via-url
	local url = ("https://regex101.com/?regex=%s&subst=%s&flags=%s&flavor=%s"):format(
		pattern,
		(replace and "&subst=" .. replace or ""),
		flags,
		lang
	)
	vim.fn.system { "open", url }
end

-- simple task selector from makefile
function M.selectMake()
	-- GUARD
	local makefile = vim.loop.cwd() .. "/Makefile"
	local fileExists = vim.loop.fs_stat(makefile)
	if not fileExists then
		notify("", "Makefile not found", "warn")
		return
	end

	local recipes = {}
	for line in io.lines(makefile) do
		local recipe = line:match("^[%w_]+")
		if recipe then table.insert(recipes, recipe) end
	end

	vim.ui.select(recipes, { prompt = " make" }, function(selection)
		if not selection then return end
		vim.cmd("silent! update")
		vim.cmd.lmake(selection)
	end)
end

-- Increment or toggle if cursorword is true/false. Simplified implementation
-- of dial.nvim. (requires `expr = true` for the keymap)
function M.toggleOrIncrement()
	local cword = vim.fn.expand("<cword>")
	local bool = { ["true"] = "false", ["True"] = "False" } -- capitalized for python
	local toggle
	for word, opposite in pairs(bool) do
		if cword == word then toggle = opposite end
		if cword == opposite then toggle = word end
		if toggle then return "mzciw" .. toggle .. "<Esc>`z" end
	end
	return "<C-a>"
end

-- simplified implementation of neogen.nvim
-- * requires nvim-treesitter-textobjects
-- * lsp usually provides better prefills for docstrings
function M.docstring()
	local function leaveVisualMode()
		local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
		vim.api.nvim_feedkeys(escKey, "nx", false)
	end

	local supportedFts = { "lua", "python", "javascript" }
	if not vim.tbl_contains(supportedFts, vim.bo.filetype) then
		notify("", "Unsupported filetype.", "warn")
		return
	end

	local ft = vim.bo.filetype
	vim.cmd.TSTextobjectGotoPreviousStart("@function.outer")

	local indent = vim.api.nvim_get_current_line():match("^%s*")
	local ln = vim.api.nvim_win_get_cursor(0)[1]

	if ft == "python" then
		indent = indent .. (" "):rep(4)
		vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. ('"'):rep(6) })
		vim.api.nvim_win_set_cursor(0, { ln + 1, #indent + 3 })
		vim.cmd.startinsert()
	elseif ft == "lua" then
		vim.api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, { "---" })
		vim.api.nvim_win_set_cursor(0, { ln, 0 })
		vim.cmd.startinsert { bang = true }
		-- HACK to trigger the `@param;@return` luadoc completion from lua-ls
		vim.defer_fn(function()
			require("cmp").complete()
			require("cmp").confirm { select = true }
		end, 150)
		vim.defer_fn(vim.api.nvim_del_current_line, 900) -- remove `---comment`
		vim.defer_fn(leaveVisualMode, 950)
	elseif ft == "javascript" then
		normal("t)") -- go to parameter, since cursor has to be on diagnostic for code action
		vim.lsp.buf.code_action {
			filter = function(action) return action.title == "Infer parameter types from usage" end,
			apply = true,
		}
		-- goto docstring (delayed, so code action can finish first)
		vim.defer_fn(function()
			vim.api.nvim_win_set_cursor(0, { ln + 1, 0 })
			normal("t}")
		end, 100)
	end
end

-- 1. in addition to toggling case of letters, also toggls some common characters
-- 2. does not mvoe the cursor to the left, useful for vertical changes
function M.betterTilde()
	local toggleSigns =
		{ ["'"] = '"', ["+"] = "-", ["("] = ")", ["["] = "]", ["{"] = "}", ["<"] = ">" }
	local col = vim.fn.col(".") -- fn.col correctly considers tab-indentation
	local charUnderCursor = vim.api.nvim_get_current_line():sub(col, col)
	local isLetter = charUnderCursor:lower() ~= charUnderCursor:upper() -- so it works with diacritics
	if isLetter then
		normal("v~") -- (`v~` instead of `~h` so dot-repetition also doesn't move the cursor)
	else
		for left, right in pairs(toggleSigns) do
			if charUnderCursor == left then normal("r" .. right) end
			if charUnderCursor == right then normal("r" .. left) end
		end
	end
end

---simplified implementation of tabout.nvim
---(should be mapped in insert-mode to `<Tab>`)
function M.tabout()
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local charsBefore = line:sub(1, col)
	local onlyWhitespaceBeforeCursor = charsBefore:match("^%s*$")
	local frontOfMarkdownList = vim.bo.ft == "markdown" and charsBefore:match("^[%s-*+]*$")

	if onlyWhitespaceBeforeCursor or frontOfMarkdownList then
		-- using feedkeys instead of `expr = true`, since the cmp mapping
		-- does not work with `expr = true`
		local keyCode = vim.api.nvim_replace_termcodes("<C-t>", true, false, true)
		vim.api.nvim_feedkeys(keyCode, "i", false)
	elseif vim.bo.ft == "gitcommit" then
		vim.cmd.startinsert { bang = true }
	else
		local closingPairs = "[%]\"'`)}>]"
		local nextClosingPairPos = line:find(closingPairs, col + 1)
		if not nextClosingPairPos then return end

		-- INFO nvim_win_set_cursor does not work in insert mode, therefore
		-- temporarily switching to normal mode
		vim.cmd.stopinsert()
		vim.defer_fn(function()
			vim.api.nvim_win_set_cursor(0, { row, nextClosingPairPos })
			local isEndOfLine = nextClosingPairPos == #line
			vim.cmd.startinsert { bang = isEndOfLine }
		end, 1)
	end
end

---like <C-o>/<C-i>, but restricts jumpts to current buffer
---@param direction "back"|"forward"
function M.jumpInBuffer(direction)
	local currentBuf = vim.api.nvim_get_current_buf()
	local key = direction == "back" and "<C-o>" or "<C-i>"
	local jumpListEnd = direction == "back" and 0 or #vim.fn.getjumplist(0)[1]
	repeat
		vim.cmd.execute(([["normal \%s"]]):format(key)) -- SIC must be double-quoted
		local jumpPos = vim.fn.getjumplist(0)[2]
		if jumpPos == jumpListEnd then
			vim.cmd("keepjumps buffer " .. tostring(currentBuf))
			return
		end
	until currentBuf == vim.api.nvim_get_current_buf()
end

--------------------------------------------------------------------------------
return M
