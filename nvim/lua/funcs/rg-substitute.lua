local M = {}
-- DOCS https://docs.rs/regex/1.*/regex/#syntax
--------------------------------------------------------------------------------

local config = {
	win = {
		width = 50,
		border = vim.g.borderStyle,
	},
	keymaps = {
		confirm = "<CR>",
		abort = "q",
	},
	regexOptions = {
		pcre2 = true, -- enables lookarounds and backreferences, but slightly slower
		multiline = false, -- does not affect `.` (see rg's manpage on `--multiline`)
		-- By default, rg treats `$1a` as the named capture group "1a". When set
		-- to `true`, this behavior is disabled and `$1a` is the first capture
		-- followed by the letter "a" (see rg's manpage on `--replace`).
		simpleCaptureGroups = true,
	},
	notificationOnSuccess = true,
}

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = "rg substitute" })
end

-- jackpotbb
-- cc
-- XXXXXXXXXXXX
-- XXXXXXXXXXXX

---@param rgBuf integer temporary rg buffer
---@param targetBuf integer buffer where the output will be written
local function executeSubstitution(rgBuf, targetBuf)
	local toSearch, toReplace = unpack(vim.api.nvim_buf_get_lines(rgBuf, 0, -1, false))
	local file = vim.api.nvim_buf_get_name(targetBuf)

	-- HACK deal with annoying named capture groups (see `man rg` on `--replace`)
	if config.simpleCaptureGroups then toReplace = toReplace:gsub("%$(%d+)", "${%1}") end

	-- notify on count
	if config.notificationOnSuccess then
		local out = vim.system({
			"rg",
			toSearch,
			"--count",
			"--no-config",
			config.regexOptions.multiline and "--multiline" or nil,
			config.regexOptions.pcre2 and "--pcre2" or nil,
			"--",
			file,
		}):wait()
		if out.code == 0 then
			local count = tonumber(vim.trim(out.stdout))
			local pluralS = count == 1 and "" or "s"
			notify(("Replaced %s occurrence%s."):format(count, pluralS))
		end
	end

	-- substitute
	local rgResult = vim.system({
		"rg",
		toSearch,
		"--replace=" .. toReplace,
		"--passthrough",
		"--no-line-number",
		"--no-config",
		config.regexOptions.multiline and "--multiline" or nil,
		config.regexOptions.pcre2 and "--pcre2" or nil,
		"--",
		file,
	}):wait()
	if rgResult.code ~= 0 then
		notify(rgResult.stderr, "error")
		return
	end

	-- update
	local newLines = vim.split(rgResult.stdout, "\n")
	vim.api.nvim_buf_set_lines(targetBuf, 0, -1, false, newLines)
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

	local rgResult = vim.system({
		"rg",
		toSearch,
		"--line-number",
		"--column",
		"--only-matching",
		"--no-config",
		config.regexOptions.multiline and "--multiline" or nil,
		config.regexOptions.pcre2 and "--pcre2" or nil,
		"--",
		file,
	}):wait()
	-- TODO parse `--json` output for better handling of `--multiline`
	if rgResult.code ~= 0 then return end

	local viewportStart = vim.fn.line("w0", targetWin)
	local viewportEnd = vim.fn.line("w$", targetWin)

	local matches = vim.split(vim.trim(rgResult.stdout), "\n")
	vim.iter(matches)
		:filter(function(match) -- PERF only matches in viewport
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

function M.rgSubstitute()
	local targetBuf = vim.api.nvim_get_current_buf()
	local targetWin = vim.api.nvim_get_current_win()

	-- CREATE & PREFILL TEMP RG-BUFFER
	local searchPrefill
	if vim.fn.mode() == "n" then
		searchPrefill = vim.fn.expand("<cword>")
	else
		vim.cmd.normal { '"zy', bang = true }
		searchPrefill = vim.fn.getreg("z")
	end
	local rgBuf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(rgBuf, 0, -1, false, { searchPrefill, "" })
	-- adds syntax highlighting via treesitter `regex` parser
	vim.api.nvim_set_option_value("filetype", "regex", { buf = rgBuf })
	vim.api.nvim_buf_set_name(rgBuf, "rg substitute")

	-- CREATE WINDOW
	local winnr = vim.api.nvim_open_win(rgBuf, true, {
		relative = "win",
		row = vim.api.nvim_win_get_height(0) - 5,
		col = math.floor((vim.api.nvim_win_get_width(0) - config.win.width) / 2),
		width = config.win.width,
		height = 2,
		style = "minimal",
		border = config.win.border,
		title = "  rg substitute ",
		title_pos = "center",
	})
	vim.api.nvim_set_option_value("signcolumn", "no", { win = winnr })
	vim.api.nvim_set_option_value("number", false, { win = winnr })
	vim.api.nvim_set_option_value("sidescrolloff", 0, { win = winnr })
	vim.api.nvim_set_option_value("scrolloff", 0, { win = winnr })
	vim.cmd.startinsert { bang = true }

	-- VIRTUAL TEXT & HIGHLIGHTS
	local ns = vim.api.nvim_create_namespace("rg-substitute-virttext")
	vim.api.nvim_buf_set_extmark(rgBuf, ns, 0, 0, {
		virt_text = { { " Search", "DiagnosticVirtualTextInfo" } },
		virt_text_pos = "right_align",
	})
	vim.api.nvim_buf_set_extmark(rgBuf, ns, 1, 0, {
		virt_text = { { "Replace", "DiagnosticVirtualTextInfo" } },
		virt_text_pos = "right_align",
	})

	local matchHls = vim.api.nvim_create_namespace("rg-substitute-match-hls")
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = rgBuf,
		group = vim.api.nvim_create_augroup("rg-substitute", { clear = true }),
		callback = function() highlightMatches(matchHls, rgBuf, targetBuf, targetWin) end,
	})

	-- KEYMAPS
	local function closeRgWin()
		vim.api.nvim_win_close(winnr, true)
		vim.api.nvim_buf_delete(rgBuf, { force = true })
		vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
		vim.api.nvim_buf_clear_namespace(0, matchHls, 0, -1)
	end

	vim.keymap.set({ "n", "x" }, config.keymaps.abort, closeRgWin, { buffer = rgBuf, nowait = true })
	vim.keymap.set({ "n", "x" }, config.keymaps.confirm, function()
		executeSubstitution(rgBuf, targetBuf)
		closeRgWin()
	end, { buffer = rgBuf, nowait = true })
end

--------------------------------------------------------------------------------
return M





