local M = {}
--------------------------------------------------------------------------------

local defaultConfig = {
	window = {
		width = 35,
		border = "single",
	},
	keymaps = {
		confirm = "<CR>",
		abort = "q",
	},
	regexOptions = {
		-- enables lookarounds and backreferences, but slower performance
		pcre2 = true,
		-- By default, rg treats `$1a` as the named capture group "1a". When set
		-- to `true`, and `$1a` is automatically changed to `${1}a` to ensure the
		-- capture group is correctly determined. Disable this setting, if you
		-- plan an using named capture groups.
		autoBraceSimpleCaptureGroups = true,
	},
	prefill = {
		normal = "cursorword", -- "cursorword"|false
		visual = "selectionFirstLine", -- "selectionFirstLine"|false
	},
	notificationOnSuccess = true,
}

local config = defaultConfig

--------------------------------------------------------------------------------

---@class (exact) ripSubstituteState
---@field rgBuf number
---@field targetBuf number
---@field targetWin number
---@field targetFile string
---@field virtTextNs number
---@field matchHlNs number
local state = {}

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = "rg substitute" })
end

---@param parameters string[]
---@return vim.SystemCompleted
local function runRipgrep(parameters)
	local rgCmd = vim.list_extend({ "rg", "--no-config" }, parameters)
	if config.regexOptions.pcre2 then table.insert(rgCmd, "--pcre2") end
	vim.list_extend(rgCmd, { "--", state.targetFile })
	return vim.system(rgCmd):wait()
end

--------------------------------------------------------------------------------

local function executeSubstitution()
	local toSearch, toReplace = unpack(vim.api.nvim_buf_get_lines(state.rgBuf, 0, -1, false))
	if config.autoBraceSimpleCaptureGroups then toReplace = toReplace:gsub("%$(%d+)", "${%1}") end

	-- notify on count
	if config.notificationOnSuccess then
		local out = runRipgrep { toSearch, "--count-matches" }
		if out.code == 0 then
			local count = tonumber(vim.trim(out.stdout))
			local pluralS = count == 1 and "" or "s"
			notify(("Replaced %s occurrence%s."):format(count, pluralS))
		end
	end

	-- substitute
	local rgResult = runRipgrep { toSearch, "--replace=" .. toReplace, "--line-number" }
	if rgResult.code ~= 0 then
		notify(rgResult.stderr, "error")
		return
	end

	-- UPDATE LINES
	-- (only change individual lines as opposed to whole buffer, as this
	-- preserves folds and marks as much as possible)
	local replacements = vim.split(vim.trim(rgResult.stdout), "\n")
	for _, repl in pairs(replacements) do
		local lineStr, newLine = repl:match("^(%d+):(.*)")
		local lnum = assert(tonumber(lineStr))
		vim.api.nvim_buf_set_lines(state.targetBuf, lnum - 1, lnum, false, { newLine })
	end
end

local function highlightMatches()
	vim.api.nvim_buf_clear_namespace(state.targetBuf, state.matchHlNs, 0, -1)
	local toSearch, toReplace = unpack(vim.api.nvim_buf_get_lines(state.rgBuf, 0, -1, false))
	if toSearch == "" then return end

	-- PERF Filters `rgResult` by only showing lines in the viewport of the `targetWin`
	---@param rgStdout string
	---@return Iter
	local function viewportLines(rgStdout)
		local rgLines = vim.split(vim.trim(rgStdout), "\n")
		local viewportStart = vim.fn.line("w0", state.targetWin)
		local viewportEnd = vim.fn.line("w$", state.targetWin)
		return vim.iter(rgLines):filter(function(line)
			local lnum = tonumber(line:match("^(%d+):"))
			return (lnum >= viewportStart) and (lnum <= viewportEnd)
		end)
	end

	-- only highlight search matches
	if toReplace == "" then
		local rgResult = runRipgrep { toSearch, "--line-number", "--column", "--only-matching" }
		if rgResult.code ~= 0 then return end

		viewportLines(rgResult.stdout):each(function(match)
			local lnumStr, colStr, text = match:match("^(%d+):(%d+):(.*)")
			local lnum = tonumber(lnumStr) - 1
			local startCol = tonumber(colStr) - 1
			local endCol = startCol + #text
			vim.highlight.range(
				state.targetBuf,
				state.matchHlNs,
				"IncSearch",
				{ lnum, startCol },
				{ lnum, endCol }
			)
		end)
	else
		local rgResult =
			runRipgrep { toSearch, "--replace=" .. toReplace, "--line-number", "--column" }
		if rgResult.code ~= 0 then return end
		viewportLines(rgResult.stdout):each(function(repl)
			local lnumStr, colStr, newLine = repl:match("^(%d+):(%d+):(.*)")
			local lnum = tonumber(lnumStr) - 1
			local startCol = tonumber(colStr) - 1
			vim.api.nvim_buf_set_extmark(state.targetBuf, state.matchHlNs, lnum, startCol, {
				virt_text = { { newLine, "IncSearch" } },
				virt_text_pos = "overlay",
			})
		end)
	end
end

local function setRgBufLabels()
	vim.api.nvim_buf_clear_namespace(state.rgBuf, state.virtTextNs, 0, -1)
	vim.api.nvim_buf_set_extmark(state.rgBuf, state.virtTextNs, 0, 0, {
		virt_text = { { " Search", "DiagnosticVirtualTextInfo" } },
		virt_text_pos = "right_align",
	})
	vim.api.nvim_buf_set_extmark(state.rgBuf, state.virtTextNs, 1, 0, {
		virt_text = { { "Replace", "DiagnosticVirtualTextInfo" } },
		virt_text_pos = "right_align",
	})
end

-- ensure buffer has only 2 lines
local function removeExtraLines()
	local lines = vim.api.nvim_buf_get_lines(state.rgBuf, 0, -1, true)
	if #lines == 2 then return end
	if #lines == 1 then
		lines[2] = ""
	elseif #lines > 2 then
		if lines[1] == "" then table.remove(lines, 1) end
		if lines[3] and lines[2] == "" then table.remove(lines, 2) end
	end
	vim.api.nvim_buf_set_lines(state.rgBuf, 0, -1, true, { lines[1], lines[2] })
	vim.cmd.normal { "zb", bang = true } -- enforce scroll position
end

function M.ripSubstitute()
	state = {
		targetBuf = vim.api.nvim_get_current_buf(),
		targetWin = vim.api.nvim_get_current_win(),
		virtTextNs = vim.api.nvim_create_namespace("rip-substitute-virttext"),
		matchHlNs = vim.api.nvim_create_namespace("rip-substitute-match-hls"),
		targetFile = vim.api.nvim_buf_get_name(0),
	}

	local augroup = vim.api.nvim_create_augroup("rip-substitute", { clear = true })

	-- PREFILL
	local prefill = ""
	local mode = vim.fn.mode()
	if mode == "n" and config.prefill.normal == "cursorword" then
		prefill = vim.fn.expand("<cword>")
	elseif mode:find("[Vv]") and config.prefill.visual == "selectionFirstLine" then
		vim.cmd.normal { '"zy', bang = true }
		prefill = vim.fn.getreg("z"):gsub("[\n\r].*", "")
	end
	prefill = prefill:gsub("[.(){}[%]*+?^$]", [[\%1]]) -- escape special chars

	-- CREATE RG-BUFFER
	state.rgBuf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(state.rgBuf, 0, -1, false, { prefill, "" })
	-- adds syntax highlighting via treesitter `regex` parser
	vim.api.nvim_set_option_value("filetype", "regex", { buf = state.rgBuf })
	vim.api.nvim_buf_set_name(state.rgBuf, "rip substitute")

	-- CREATE WINDOW
	local rgWin = vim.api.nvim_open_win(state.rgBuf, true, {
		relative = "win",
		row = vim.api.nvim_win_get_height(0) - 4,
		col = vim.api.nvim_win_get_width(0) - config.window.width - 2,
		width = config.window.width,
		height = 2,
		style = "minimal",
		border = config.window.border,
		title = "  rip substitute ",
		title_pos = "center",
	})
	local winOpts = {
		list = true,
		listchars = "multispace:·,tab:▸▸",
		signcolumn = "no",
		number = false,
		sidescrolloff = 0,
		scrolloff = 0,
	}
	for key, value in pairs(winOpts) do
		vim.api.nvim_set_option_value(key, value, { win = rgWin })
	end
	vim.defer_fn(function() vim.cmd.startinsert { bang = true } end, 1)

	-- VIRTUAL TEXT & HIGHLIGHTS
	setRgBufLabels()
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = state.rgBuf,
		group = augroup,
		callback = function()
			removeExtraLines()
			highlightMatches()
			setRgBufLabels()
		end,
	})

	-- POPUP CLOSING
	local function closeRgWin()
		if vim.api.nvim_win_is_valid(rgWin) then vim.api.nvim_win_close(rgWin, true) end
		if vim.api.nvim_buf_is_valid(state.rgBuf) then
			vim.api.nvim_buf_delete(state.rgBuf, { force = true })
		end
		vim.api.nvim_buf_clear_namespace(0, state.virtTextNs, 0, -1)
		vim.api.nvim_buf_clear_namespace(0, state.matchHlNs, 0, -1)
	end
	-- also close the popup on leaving buffer, ensures there is not leftover
	-- buffer when user closes popup in a different way, such as `:close`.
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = state.rgBuf,
		group = augroup,
		once = true,
		callback = closeRgWin,
	})

	-- KEYMAPS
	vim.keymap.set(
		{ "n", "x" },
		config.keymaps.abort,
		closeRgWin,
		{ buffer = state.rgBuf, nowait = true }
	)
	vim.keymap.set({ "n", "x" }, config.keymaps.confirm, function()
		executeSubstitution()
		closeRgWin()
	end, { buffer = state.rgBuf, nowait = true })
end

--------------------------------------------------------------------------------
return M
