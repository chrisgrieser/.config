local M = {}
--------------------------------------------------------------------------------
local fn = vim.fn
local bo = vim.bo

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---send notification
---@param funcname string
local function noSupportNotif(funcname)
	local msg = funcname .. " does not support " .. bo.filetype .. " yet."
	vim.notify(msg, vim.log.levels.WARN, { title = "Chainsaw" })
end

---in normal mode, returns word under cursor, in visual mode, returns selection
---@return string?
local function getVar()
	local varname
	local isVisualMode = fn.mode():find("[Vv]")
	if isVisualMode then
		local prevReg = fn.getreg("z")
		normal('"zy')
		varname = fn.getreg("z"):gsub('"', '//"')
		fn.setreg("z", prevReg)
	else
		local node = vim.treesitter.get_node()
		if not node then return "" end
		varname = vim.treesitter.get_node_text(node, 0)
	end
	return varname
end

---append string below current line
---@param text string
local function append(text)
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	local indent = vim.api.nvim_get_current_line():match("^%s*")
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. text })
end

local function getFiletype()
	local ft = bo.filetype
	if ft == "lua" and vim.fn.expand("%:p"):find("nvim") then ft = "nvim_lua" end
	return ft
end

--------------------------------------------------------------------------------

-- CONFIG
local config = {
	marker = "🪚",
	beepEmojis = { "🤖", "👽", "👾", "💣" },
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
			nvim_lua = 'vim.notify("%s %s: ".. tostring(%s))', -- FIX for noice.nvim print-bug: https://github.com/folke/noice.nvim/issues/556
			python = 'print(f"%s {%s = }")',
			javascript = 'console.log("%s %s:", %s);',
			typescript = 'console.log("%s %s:", %s);',
			sh = 'echo "%s %s: $%s"',
			applescript = 'log "%s %s:" & %s',
			css = "outline: 2px solid red !important; /* %s */",
			scss = "outline: 2px solid red !important; /* %s */",
		},
	},
}

function M.messageLog()
	local ft = getFiletype()
	local templateStr = config.logStatements.messageLog[ft]
	if not templateStr then
		noSupportNotif("Message Log")
		return
	end

	local logStatement = templateStr:format(config.marker)
	append(logStatement)
	-- goto insert mode at correct location
	normal('f";') -- goto second `"`
	vim.cmd.startinsert()
end

---log statement for variable under cursor, similar to the 'turbo console log'
---VS Code plugin. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.variableLog()
	local ft = getFiletype()
	local templateStr = config.logStatements.variableLog[ft]
	if not templateStr then
		noSupportNotif("Variable Log")
		return
	end

	local varname = getVar()
	local logStatement = templateStr:format(config.marker, varname, varname)
	append(logStatement)
end

function M.assertLog()
	local ft = getFiletype()
	local templateStr = config.logStatements.assertLog[ft]
	if not templateStr then
		noSupportNotif("Assert Log")
		return
	end

	local varname = getVar()
	local logStatement = templateStr:format(varname, config.marker, varname)
	append(logStatement)
	normal("f,") -- goto the comma to edit the condition
end

function M.objectLog()
	local ft = getFiletype()
	local templateStr = config.logStatements.objectLog[ft]
	if not templateStr then
		noSupportNotif("Object Log")
		return
	end

	local varname = getVar()
	local logStatement = templateStr:format(config.marker, varname, varname)
	append(logStatement)
end

---adds simple "beep" log statement to check whether conditionals have been triggered
function M.beepLog()
	local ft = getFiletype()
	local templateStr = config.logStatements.beepLog[ft]
	if not templateStr then
		noSupportNotif("Beep Log")
		return
	end

	local randomEmoji = config.beepEmojis[math.random(1, #config.beepEmojis)]
	local logStatement = templateStr:format(config.marker, randomEmoji)
	append(logStatement)
end

--------------------------------------------------------------------------------

function M.timeLog()
	if vim.b.timelogStart == nil then vim.b.timelogStart = true end ---@diagnostic disable-line: inject-field
	local start, stop
	local ft = bo.filetype

	if ft == "lua" then
		start = { "local timelogStart = os.time() -- %s" }
		stop = {
			"local durationSecs = os.difftime(os.time(), timelogStart) -- %s",
			'print("%s:", durationSecs, "s")',
		}
	elseif ft == "python" then
		start = { "timelogStart = time.perf_counter()  # %s" }
		stop = {
			"durationSecs = round(time.perf_counter() - timelogStart, 3)  # %s",
			'print(f"%s: {durationSecs}s")',
		}
	elseif ft == "javascript" then
		-- not all JS engines support console.time()
		start = { "const timelogStart = +new Date(); // %s" }
		stop = {
			"const durationSecs = (+new Date() - timelogStart) / 1000; // %s",
			"console.log(`%s: ${durationSecs}s`);",
		}
	elseif ft == "typescript" then
		start = { 'console.time("timelog"); // %s' }
		stop = { 'console.timeEnd("timelog"); // %s' }
	elseif ft == "bash" or ft == "zsh" or ft == "sh" then
		start = { "timelogStart=$(date +%%s) # %s" }
		stop = {
			"timelogEnd=$(date +%%s) && durationSecs = $((timelogEnd - timelogStart)) # %s",
			'echo "%s ${durationSecs}s"',
		}
	else
		noSupportNotif("Time Log")
		return
	end
	local statementToUse = vim.b.timelogStart and start or stop
	for _, line in pairs(statementToUse) do
		append(line:format(config.marker))
	end
	vim.b.timelogStart = not vim.b.timelogStart ---@diagnostic disable-line: inject-field
end

-- simple debug statement
function M.debugLog()
	local logStatement
	local ft = bo.filetype

		return
	end

	append(logStatement:format(config.marker))
end

---Remove all log statements in the current buffer
function M.removeLogs()
	local numOfLinesBefore = vim.api.nvim_buf_line_count(0)

	-- escape for vim regex, in case `[]` are used in the marker
	local toRemove = config.marker:gsub("%]", "\\]"):gsub("%[", "\\[")
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
