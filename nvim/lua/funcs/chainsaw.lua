local M = {}
--------------------------------------------------------------------------------

---@class (exact) pluginConfig
---@field marker string
---@field beepEmojis string[]
---@field logStatements table<string, table<string, string|string[]>>

---@type pluginConfig
local config = {
	marker = "🪚", -- should be a short, unique string (.removeLogs() will remove any line with it)
	beepEmojis = { "🤖", "👽", "👾", "💣" }, -- to differentiate between beepLog statements
	logStatements = {
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
		objectLog = {
			nvim_lua = 'vim.notify("%s %s: " .. vim.inspect(%s))',
			typescript = 'console.log("%s %s:", %s)',
			javascript = 'console.log("%s %s:", JSON.stringify(%s))',
		},
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
		messageLog = {
			lua = 'print("%s ")',
			nvim_lua = 'vim.notify("%s ")', -- FIX for noice.nvim print-bug: https://github.com/folke/noice.nvim/issues/556
			python = 'print("%s ")',
			javascript = 'console.log("%s ");',
			typescript = 'console.log("%s ");',
			sh = 'echo "%s "',
			applescript = 'log "%s "',
		},
		assertLog = {
			lua = 'assert(%s, "%s %s")',
			nvim_lua = 'assert(%s, "%s %s")',
			python = 'assert %s, "%s %s"',
		},
		debugLog = {
			javascript = "debugger; // %s",
			typescript = "debugger; // %s",
			python = "breakpoint()  # %s", -- https://docs.python.org/3.11/library/functions.html?highlight=breakpoint#breakpoint
			sh = { -- https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
				"set -exuo pipefail # %s",
				"set +exuo pipefail # %s", -- re-enable, so it does not disturb stuff from interactive shell
			},
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

---append string below current line
---@param logLines string|string[]
---@param varsToInsert string[]
local function appendLines(logLines, varsToInsert)
	local ln = vim.api.nvim_win_get_cursor(0)[1]

	local indentBasedFts = { "python", "yaml", "elm" }
	local isIndentBased = vim.tbl_contains(indentBasedFts, vim.bo.ft)
	local indent = isIndentBased and vim.api.nvim_get_current_line():match("^%s*") or ""
	local action = isIndentBased and "j" or "j=="

	if type(logLines) == "string" then logLines = { logLines } end
	for _, line in pairs(logLines) do
		local toInsert = indent .. line:format(unpack(varsToInsert))
		vim.api.nvim_buf_set_lines(0, ln, ln, true, { toInsert })
		normal(action)
		ln = ln + 1
	end
end

---get template string, if it does not exist, return nil
---@param logType string
---@return string|string[]|nil
---@nodiscard
local function getTemplateStr(logType)
	local ft = vim.bo.filetype
	if vim.api.nvim_buf_get_name(0):find("nvim.*%.lua$") then ft = "nvim_lua" end
	local templateStr = config.logStatements[logType][ft]
	if not templateStr then
		local msg = ("%s does not support %s yet."):format(logType, ft)
		vim.notify(msg, vim.log.levels.WARN, { title = "Chainsaw" })
	end
	return templateStr
end

--------------------------------------------------------------------------------

function M.messageLog()
	local logLines = getTemplateStr("messageLog") 
	if not logLines then return end
	appendLines(logLines, { config.marker })
	normal('f";') -- goto insert mode at correct location
	vim.cmd.startinsert()
end

function M.variableLog()
	local varname = getVar()
	local logLines = getTemplateStr("variableLog") 
	if not logLines then return end
	appendLines(logLines, { config.marker, varname, varname })
end

function M.objectLog()
	local varname = getVar()
	local logLines = getTemplateStr("objectLog") 
	if not logLines then return end
	appendLines(logLines, { config.marker, varname, varname })
end

function M.assertLog()
	local varname = getVar()
	local logLines = getTemplateStr("assertLog") 
	if not logLines then return end
	appendLines(logLines, { varname, config.marker, varname })
	normal("f,") -- goto the comma to edit the condition
end

---adds simple "beep" log statement to check whether conditionals have been triggered
function M.beepLog()
	local logLines = getTemplateStr("beepLog") 
	if not logLines then return end
	local randomEmoji = config.beepEmojis[math.random(1, #config.beepEmojis)]
	appendLines(logLines, { config.marker, randomEmoji })
end

function M.timeLog()
	if vim.b.timeLogStart == nil then vim.b["timeLogStart"] = true end 

	local startOrStop = vim.b.timeLogStart and "timeLogStart" or "timeLogStop"
	local logLines = getTemplateStr(startOrStop)
	if not logLines then return end
	appendLines(logLines, { config.marker })

	vim.b["timeLogStart"] = not vim.b.timeLogStart 
end

-- simple debugger statement
function M.debugLog()
	local logLines = getTemplateStr("debugLog")
	if not logLines then return end
	appendLines(logLines, { config.marker })
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
