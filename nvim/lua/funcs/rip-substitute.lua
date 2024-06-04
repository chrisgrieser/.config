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
		-- to `true`, that behavior is disabled and `$1a` is the first capture
		-- followed by the letter "a". (See also rg's manpage on `--replace`.)
		simpleCaptureGroups = true,
	},
	prefill = {
		normal = "cursorword", -- "cursorword"|false
		visual = "selectionFirstLine", -- "selectionFirstLine"|false
	},
	notificationOnSuccess = true,
}

local config = defaultConfig

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = "rg substitute" })
end

---@param parameters string[]
---@param file string
---@return vim.SystemCompleted
local function runRipgrep(parameters, file)
	local rgCmd = vim.list_extend({ "rg", "--no-config" }, parameters)
	vim.list_extend(rgCmd, { "--", file })
	return vim.system(rgCmd):wait()
end

---@param rgBuf integer temporary rg buffer
---@param targetBuf integer buffer where the output will be written
local function executeSubstitution(rgBuf, targetBuf)
	local toSearch, toReplace = unpack(vim.api.nvim_buf_get_lines(rgBuf, 0, -1, false))
	local file = vim.api.nvim_buf_get_name(targetBuf)
	local pcre2 = config.regexOptions.pcre2 and "--pcre2" or nil

	-- HACK deal with annoying named capture groups (see `man rg` on `--replace`)
	if config.simpleCaptureGroups then toReplace = toReplace:gsub("%$(%d+)", "${%1}") end

	-- notify on count
	if config.notificationOnSuccess then
		local out = runRipgrep({ toSearch, "--count", pcre2 }, file)
		if out.code == 0 then
			local count = tonumber(vim.trim(out.stdout))
			local pluralS = count == 1 and "" or "s"
			notify(("Replaced %s occurrence%s."):format(count, pluralS))
		end
	end

	-- substitute
	local rgResult =
		runRipgrep({ toSearch, "--replace=" .. toReplace, "--line-number", pcre2 }, file)
	if rgResult.code ~= 0 then
		notify(rgResult.stderr, "error")
		return
	end

	-- update lines
	-- (only change individual lines as opposed to whole buffer, as this
	-- preserves folds and marks as much as possible)
	local newLines = vim.split(vim.trim(rgResult.stdout), "\n")
	for _, repl in pairs(newLines) do
		local lineStr, newLine = repl:match("^(%d+):(.*)")
		local lnum = assert(tonumber(lineStr))
		vim.api.nvim_buf_set_lines(targetBuf, lnum - 1, lnum, false, { newLine })
	end
end

---@param ns number
---@param rgBuf number
---@param targetBuf number
---@param targetWin number
local function highlightMatches(ns, rgBuf, targetBuf, targetWin)
	vim.api.nvim_buf_clear_namespace(targetBuf, ns, 0, -1)

	local toSearch = vim.api.nvim_buf_get_lines(rgBuf, 0, -1, false)[1]
	if toSearch == "" then return end
	local file = vim.api.nvim_buf_get_name(targetBuf)
	local pcre2 = config.regexOptions.pcre2 and "--pcre2" or nil

	local rgResult =
		runRipgrep({ toSearch, "--line-number", "--column", "--only-matching", pcre2 }, file)
	if rgResult.code ~= 0 then return end

	local viewportStart = vim.fn.line("w0", targetWin)
	local viewportEnd = vim.fn.line("w$", targetWin)

	local matches = vim.split(vim.trim(rgResult.stdout), "\n")
	vim.iter(matches)
		:filter(function(match) -- PERF update only matches in viewport
			local line = tonumber(match:match("^(%d+):"))
			return (line >= viewportStart) and (line <= viewportEnd)
		end)
		:each(function(match)
			local lineStr, colStr, text = unpack(vim.split(match, ":"))
			local line = tonumber(lineStr) - 1
			local startCol = tonumber(colStr) - 1
			local endCol = startCol + #text
			vim.highlight.range(targetBuf, ns, "IncSearch", { line, startCol }, { line, endCol })
		end)
end

function M.ripSubstitute()
	local targetBuf = vim.api.nvim_get_current_buf()
	local targetWin = vim.api.nvim_get_current_win()
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
	local rgBuf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(rgBuf, 0, -1, false, { prefill, "" })
	-- adds syntax highlighting via treesitter `regex` parser
	vim.api.nvim_set_option_value("filetype", "regex", { buf = rgBuf })
	vim.api.nvim_buf_set_name(rgBuf, "rip substitute")

	-- CREATE WINDOW
	local winnr = vim.api.nvim_open_win(rgBuf, true, {
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
		vim.api.nvim_set_option_value(key, value, { win = winnr })
	end
	vim.cmd.startinsert { bang = true }

	-- VIRTUAL TEXT & HIGHLIGHTS
	local virtTextNs = vim.api.nvim_create_namespace("rip-substitute-virttext")
	vim.api.nvim_buf_set_extmark(rgBuf, virtTextNs, 0, 0, {
		virt_text = { { " Search", "DiagnosticVirtualTextInfo" } },
		virt_text_pos = "right_align",
	})
	vim.api.nvim_buf_set_extmark(rgBuf, virtTextNs, 1, 0, {
		virt_text = { { "Replace", "DiagnosticVirtualTextInfo" } },
		virt_text_pos = "right_align",
	})

	local matchHlNs = vim.api.nvim_create_namespace("rip-substitute-match-hls")
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = rgBuf,
		group = augroup,
		callback = function() highlightMatches(matchHlNs, rgBuf, targetBuf, targetWin) end,
	})

	-- POPUP CLOSING
	local function closeRgWin()
		if vim.api.nvim_win_is_valid(winnr) then vim.api.nvim_win_close(winnr, true) end
		if vim.api.nvim_buf_is_valid(rgBuf) then vim.api.nvim_buf_delete(rgBuf, { force = true }) end
		vim.api.nvim_buf_clear_namespace(0, virtTextNs, 0, -1)
		vim.api.nvim_buf_clear_namespace(0, matchHlNs, 0, -1)
	end
	-- also close the popup on leaving buffer, ensures there is not leftover
	-- buffer when user closes popup in a different way, such as `:close`.
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = rgBuf,
		group = augroup,
		once = true,
		callback = closeRgWin,
	})

	-- KEYMAPS
	vim.keymap.set({ "n", "x" }, config.keymaps.abort, closeRgWin, { buffer = rgBuf, nowait = true })
	vim.keymap.set({ "n", "x" }, config.keymaps.confirm, function()
		executeSubstitution(rgBuf, targetBuf)
		closeRgWin()
	end, { buffer = rgBuf, nowait = true })
end

--------------------------------------------------------------------------------
return M
