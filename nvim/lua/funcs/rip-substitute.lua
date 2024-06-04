local M = {}
--------------------------------------------------------------------------------

---@class ripSubstituteConfig
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
---@field targetBuf number
---@field targetWin number
---@field targetFile string
---@field labelNs number
---@field matchHlNs number
---@field rgBuf number
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

---@return string
---@return string
local function getSearchAndReplace()
	local toSearch, toReplace = unpack(vim.api.nvim_buf_get_lines(state.rgBuf, 0, -1, false))
	if config.regexOptions.autoBraceSimpleCaptureGroups then
		toReplace = toReplace:gsub("%$(%d+)", "${%1}")
	end
	return toSearch, toReplace
end

--------------------------------------------------------------------------------

local function executeSubstitution()
	local toSearch, toReplace = getSearchAndReplace()

	-- notify on count
	if config.notificationOnSuccess then
		local rgCount = runRipgrep { toSearch, "--count-matches" }
		if rgCount.code == 0 then
			local count = tonumber(vim.trim(rgCount.stdout))
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
	-- only update individual lines as opposed to whole buffer, as this
	-- preserves folds and marks
	local replacements = vim.split(vim.trim(rgResult.stdout), "\n")
	for _, repl in pairs(replacements) do
		local lineStr, newLine = repl:match("^(%d+):(.*)")
		local lnum = assert(tonumber(lineStr))
		vim.api.nvim_buf_set_lines(state.targetBuf, lnum - 1, lnum, false, { newLine })
	end
end

---@param rgArgs string[]
---@param callback function run only if non-zero rg exit code
local function onEachRgResultInViewport(rgArgs, callback)
	local rgResult = runRipgrep(rgArgs)
	if rgResult.code ~= 0 then return end
	local rgLines = vim.split(vim.trim(rgResult.stdout), "\n")
	local viewportStart = vim.fn.line("w0", state.targetWin)
	local viewportEnd = vim.fn.line("w$", state.targetWin)
	vim.iter(rgLines)
		:filter(function(line) -- PERF only in viewport
			local lnum = tonumber(line:match("^(%d+):"))
			return (lnum >= viewportStart) and (lnum <= viewportEnd)
		end)
		:map(function(line)
			local lnumStr, colStr, text = line:match("^(%d+):(%d+):(.*)")
			return {
				lnum = tonumber(lnumStr) - 1,
				col = tonumber(colStr) - 1,
				text = text,
			}
		end)
		:each(callback)
end

local function highlightMatches()
	vim.api.nvim_buf_clear_namespace(state.targetBuf, state.matchHlNs, 0, -1)
	local toSearch, toReplace = getSearchAndReplace()
	if toSearch == "" then return end

	-- highlight search matches
	local rgArgs = { toSearch, "--line-number", "--column", "--only-matching" }
	onEachRgResultInViewport(rgArgs, function(result)
		local endCol = result.col + #result.text
		vim.api.nvim_buf_add_highlight(
			state.targetBuf,
			state.matchHlNs,
			toReplace == "" and "IncSearch" or "LspInlayHint",
			result.lnum,
			result.col,
			endCol
		)
	end)

	-- insert replacements as virtual text
	if toReplace == "" then return end
	vim.list_extend(rgArgs, { "--replace=" .. toReplace })
	onEachRgResultInViewport(rgArgs, function(result)
		local virtText = { result.text, "IncSearch" }
		vim.api.nvim_buf_set_extmark(
			state.targetBuf,
			state.matchHlNs,
			result.lnum,
			result.col,
			{ virt_text = { virtText }, virt_text_pos = "inline" }
		)
	end)
end

local function setRgBufLabels()
	vim.api.nvim_buf_clear_namespace(state.rgBuf, state.labelNs, 0, -1)
	vim.api.nvim_buf_set_extmark(state.rgBuf, state.labelNs, 0, 0, {
		virt_text = { { " Search", "DiagnosticVirtualTextInfo" } },
		virt_text_pos = "right_align",
	})
	vim.api.nvim_buf_set_extmark(state.rgBuf, state.labelNs, 1, 0, {
		virt_text = { { "Replace", "DiagnosticVirtualTextInfo" } },
		virt_text_pos = "right_align",
	})
end

local function rgBufEnsureOnly2Lines()
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
		labelNs = vim.api.nvim_create_namespace("rip-substitute-virttext"),
		matchHlNs = vim.api.nvim_create_namespace("rip-substitute-match-hls"),
		targetFile = vim.api.nvim_buf_get_name(0),
		rgBuf = -999,
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
	local scrollbarOffset = 3

	-- CREATE WINDOW
	local footerStr = ("%s: Confirm   %s: Abort"):format(
		config.keymaps.confirm,
		config.keymaps.abort
	)
	local rgWin = vim.api.nvim_open_win(state.rgBuf, true, {
		relative = "win",
		row = vim.api.nvim_win_get_height(0) - 4,
		col = vim.api.nvim_win_get_width(0) - config.window.width - scrollbarOffset - 2,
		width = config.window.width,
		height = 2,
		style = "minimal",
		border = config.window.border,
		title = "  rip substitute ",
		title_pos = "center",
		zindex = 1, -- below nvim-notify
		footer = { { " " .. footerStr .. " ", "Comment" } },
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
	vim.cmd.startinsert { bang = true }

	-- VIRTUAL TEXT & HIGHLIGHTS
	setRgBufLabels()
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = state.rgBuf,
		group = augroup,
		callback = function()
			rgBufEnsureOnly2Lines()
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
		vim.api.nvim_buf_clear_namespace(0, state.matchHlNs, 0, -1)
	end
	-- also close the popup on leaving buffer, ensures there is not leftover
	-- buffer when user closes popup in a different way, such as `:close`.
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = state.rgBuf,
		group = augroup,
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
