local M = {}
--------------------------------------------------------------------------------

-- CONFIG
local config = {
	marker = "🪚", -- should be a short, unique string (.removeLogs() will remove any line with it)
	beepEmojis = { "🤖", "👽", "👾", "💣" }, -- to differentiate between beepLog statements
	logStatements = {
		beepLog = {
			nvim_lua = 'vim.notify("%s beep %s")',
			lua = 'print("%s beep %s")',
			python = 'print("%s beep %s")',
			javascript = 'console.log("%s beep %s");',
			typescript = 'console.log("%s beep %s");',
			sh = 'echo "%s beep %s"',
			applescript = "beep -- %s",
			css = "outline: 2px solid red !important; /* %s */",
			scss = "outline: 2px solid red !important; /* %s */",
		},
		objectLog = {
			nvim_lua = 'vim.notify("%s %s: " .. vim.inspect(%s))',
			typescript = 'console.log("%s %s:", %s)',
			javascript = 'console.log("%s %s:", JSON.stringify(%s))',
		},
		assertLog = {
			lua = 'assert(%s, "%s %s")',
			nvim_lua = 'assert(%s, "%s %s")',
			python = 'assert %s, "%s %s"',
		},
		messageLog = {
			lua = 'print("%s ")',
			nvim_lua = 'vim.notify("%s ")', -- FIX for noice.nvim print-bug: https://github.com/folke/noice.nvim/issues/556
			python = 'print("%s ")',
			javascript = 'console.log("%s ");',
			typescript = 'console.log("%s ");',
			sh = 'echo "%s "',
			applescript = 'log "%s "',
		},
		variableLog = {
			lua = 'print("%s %s: ", %s)',
			nvim_lua = 'vim.notify("%s %s: " .. tostring(%s))', -- FIX for noice.nvim
			python = 'print(f"%s {%s = }")',
			javascript = 'console.log("%s %s:", %s);',
			typescript = 'console.log("%s %s:", %s);',
			sh = 'echo "%s %s: $%s"',
			applescript = 'log "%s %s:" & %s',
			css = "outline: 2px solid red !important; /* %s */",
			scss = "outline: 2px solid red !important; /* %s */",
		},
		debugLog = {
			javascript = "debugger; // %s",
			typescript = "debugger; // %s",
			python = "breakpoint()  # %s",
		},
		timeLogStart = {
			nvim_lua = "local timelogStart = os.time() -- %s",
			lua = "local timelogStart = os.time() -- %s",
			python = "local timelogStart = time.perf_counter()  # %s",
			javascript = "const timelogStart = +new Date(); // %s", -- not all JS engines support console.time()
			typescript = 'console.time("%s");',
			sh = "timelogStart=$(date +%%s) # %s",
		},
		timeLogStop = {
			nvim_lua = {
				"local durationSecs = os.difftime(os.time(), timelogStart) -- %s",
				'print("%s:", durationSecs, "s")',
			},
			lua = {
				"local durationSecs = os.difftime(os.time(), timelogStart) -- %s",
				'print("%s:", durationSecs, "s")',
			},
			python = {
				"durationSecs = round(time.perf_counter() - timelogStart, 3)  # %s",
				'print(f"%s: {durationSecs}s")',
			},
			javascript = {
				"const durationSecs = (+new Date() - timelogStart) / 1000; // %s",
				"console.log(`%s: ${durationSecs}s`);",
			},
			typescript = 'console.timeEnd("%s");',
			sh = {
				"timelogEnd=$(date +%%s) && durationSecs = $((timelogEnd - timelogStart)) # %s",
				'echo "%s ${durationSecs}s"',
			},
		},
	},
}

--------------------------------------------------------------------------------

local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---in normal mode, returns word under cursor, in visual mode, returns selection
---@return string
---@nodiscard
local function getVar()
	local varname
	local isVisualMode = vim.fn.mode():find("[Vv]")
	if isVisualMode then
		local prevReg = vim.fn.getreg("z")
		normal('"zy')
		varname = vim.fn.getreg("z"):gsub('"', '//"')
		vim.fn.setreg("z", prevReg)
		return varname
	end

	-- normal mode
	if not (vim.treesitter.get_node and vim.treesitter.get_node()) then
		return vim.fn.expand("<cword>")
	end
	local node = vim.treesitter.get_node() ---@cast node TSNode -- checked in condition above
	return vim.treesitter.get_node_text(node, 0)
end

---@param text string
local function appendLine(text)
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	local indent = vim.api.nvim_get_current_line():match("^%s*")
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. text })
end

---@param logType string
---@return string|string[]
---@nodiscard
local function getTemplateStr(logType)
	local ft = vim.bo.filetype
	if ft == "lua" and vim.fn.expand("%:p"):find("nvim") then ft = "nvim_lua" end
	local templateStr = config.logStatements[logType][ft]
	if not templateStr then
		local msg = ("%s does not support %s yet."):format(logType, ft)
		vim.notify(msg, vim.log.levels.WARN, { title = "Chainsaw" })
	end
	return templateStr
end

--------------------------------------------------------------------------------

function M.messageLog()
	local templateStr = getTemplateStr("messageLog") ---@cast templateStr string
	if not templateStr then return end

	local logStatement = templateStr:format(config.marker)
	appendLine(logStatement)

	-- goto insert mode at correct location
	normal('f";') -- goto second `"`
	vim.cmd.startinsert()
end

---log statement for variable under cursor, similar to the 'turbo console log' VS Code plugin
function M.variableLog()
	local templateStr = getTemplateStr("variableLog") ---@cast templateStr string
	if not templateStr then return end

	local varname = getVar()
	local logStatement = templateStr:format(config.marker, varname, varname)
	appendLine(logStatement)
end

function M.objectLog()
	local templateStr = getTemplateStr("objectLog") ---@cast templateStr string
	if not templateStr then return end

	local varname = getVar()
	local logStatement = templateStr:format(config.marker, varname, varname)
	appendLine(logStatement)
end

function M.assertLog()
	local templateStr = getTemplateStr("assertLog") ---@cast templateStr string
	if not templateStr then return end

	local varname = getVar()
	local logStatement = templateStr:format(varname, config.marker, varname)
	appendLine(logStatement)
	normal("f,") -- goto the comma to edit the condition
end

---adds simple "beep" log statement to check whether conditionals have been triggered
function M.beepLog()
	local templateStr = getTemplateStr("beepLog") ---@cast templateStr string
	if not templateStr then return end

	local randomEmoji = config.beepEmojis[math.random(1, #config.beepEmojis)]
	local logStatement = templateStr:format(config.marker, randomEmoji)
	appendLine(logStatement)
end

function M.timeLog()
	if vim.b.timeLogStart == nil then vim.b.timeLogStart = true end ---@diagnostic disable-line: inject-field

	local startOrStop = vim.b.timeLogStart and "timeLogStart" or "timeLogStop"
	local templateStr = getTemplateStr(startOrStop)
	if not templateStr then return end

	if type(templateStr) == "string" then templateStr = { templateStr } end
	for _, line in pairs(templateStr) do
		appendLine(line:format(config.marker))
	end
	vim.b.timeLogStart = not vim.b.timeLogStart ---@diagnostic disable-line: inject-field
end

-- simple debugger statement
function M.debugLog()
	local templateStr = getTemplateStr("debugLog") ---@cast templateStr string
	if not templateStr then return end

	appendLine(templateStr:format(config.marker))
end

---Remove all log statements in the current buffer
function M.removeLogs()
	local numOfLinesBefore = vim.api.nvim_buf_line_count(0)

	-- escape for vim regex, in case `[]()` are used in the marker
	local toRemove = config.marker:gsub("([%[%]()])", "\\%1")
	vim.cmd(("silent g/%s/d"):format(toRemove))
	vim.cmd.nohlsearch()

	local linesRemoved = numOfLinesBefore - vim.api.nvim_buf_line_count(0)
	local msg = ("Removed %s log statements."):format(linesRemoved)
	if linesRemoved == 1 then msg = msg:sub(1, -3) .. "." end -- 1 = singular
	vim.notify(msg, vim.log.levels.INFO, { title = "Chainsaw" })

	vim.b.timelogStart = false ---@diagnostic disable-line: inject-field
end

--------------------------------------------------------------------------------
return M
