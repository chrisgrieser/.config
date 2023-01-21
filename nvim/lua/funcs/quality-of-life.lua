local M = {}
--------------------------------------------------------------------------------
local bo = vim.bo
local b = vim.b
local fn = vim.fn
local cmd = vim.cmd
local lineNo = vim.fn.line
local colNo = vim.fn.col
local expand = vim.fn.expand

local logWarn = vim.log.levels.WARN
local logError = vim.log.levels.ERROR
local logInfo = vim.log.levels.INFO

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

--------------------------------------------------------------------------------

---switches words under the cursor from `true` to `false` and similar cases
function M.wordSwitch()
	local iskeywBefore = opt.iskeyword:get()
	opt.iskeyword:remove { "_", "-", "." }

	local words = {
		{ "true", "false" },
		{ "<=", ">=" },
		{ "on", "off" },
		{ "yes", "no" },
		{ "disable", "enable" },
		{ "disabled", "enabled" },
		{ "show", "hide" },
		{ "right", "left" },
		{ "top", "bottom" },
		{ "width", "height" },
		{ "relative", "absolute" },
		{ "dark", "light" },
		{ "and", "or" },
		{ "next", "prev" },
	}
	local ft = bo.filetype
	local ftWords -- 3rd item false if 2nd item shouldn't also switch to first
	if ft == "lua" then
		ftWords = {
			{ "~=", "==" },
			{ "if", "elseif", false },
			{ "elseif", "else", false },
			{ "else", "if", false },
			{ "function", "local function", false },
			{ "pairs", "ipairs" },
		}
	elseif ft == "python" then
		ftWords = {
			{ "True", "False" },
		}
	elseif ft == "bash" or ft == "zsh" or ft == "sh" then
		ftWords = {
			{ "if", "elif", false },
			{ "elif", "else", false },
			{ "else", "if", false },
			{ "echo", "print" },
			{ "exit", "return" },
		}
	elseif ft == "javascript" or ft == "typescript" then
		ftWords = {
			{ "if", "else if", false },
			{ "else", "if", false },
			{ "const", "let" },
			{ "replace", "replaceAll" },
		}
	end
	if ftWords then
		for _, item in pairs(ftWords) do
			table.insert(words, item)
		end
	end

	local cword = expand("<cword>")
	local newWord = nil
	for _, pair in pairs(words) do
		if cword == pair[1] then
			newWord = pair[2]
			break
		elseif cword == pair[2] and pair[3] ~= false then
			newWord = pair[1]
			break
		end
	end

	if newWord then
		fn.setreg("z", newWord) -- HACK no idea why, but ciw does not work well with normal, therefore pasting instead
		normal([[viw"zP]])
	else
		vim.notify("Word under cursor cannot be switched.", vim.log.levels.WARN)
	end

	opt.iskeyword = iskeywBefore
end

--------------------------------------------------------------------------------
-- UNDO

-- Save Open time
augroup("undoTimeMarker", {})
autocmd("BufReadPost", {
	group = "undoTimeMarker",
	callback = function() b.timeOpened = os.time() end,
})

---select between undoing the last 1h, 4h, or 24h
function M.undoDuration()
	local now = os.time() -- saved in epoch secs
	local minsPassed = math.floor((now - b.timeOpened) / 60)
	local resetLabel = "last open (~" .. tostring(minsPassed) .. "m ago)"
	local selection = { resetLabel, "15m", "1h", "4h", "24h", " present" }

	vim.ui.select(selection, { prompt = "Undo…" }, function(choice)
		if not choice then
			return
		elseif choice:find("ago") then
			cmd.earlier(minsPassed .. "m")
		elseif choice:find("present") then
			cmd.later(tostring(opt.undolevels:get())) -- redo as much as there are undolevels
		else
			cmd.earlier(choice)
		end
	end)
end

--------------------------------------------------------------------------------

---enables overscrolling for that action when close to the last line, depending
---on 'scrolloff' option
---@param action string The motion to be executed when not at the EOF
function M.overscroll(action)
	if bo.filetype ~= "DressingSelect" then
		local curLine = lineNo(".")
		local lastLine = lineNo("$")
		if (lastLine - curLine) <= vim.wo.scrolloff then normal("zz") end
	end

	local usedCount = vim.v.count1
	local actionCount = action:match("%d+") -- if action includes a count
	if actionCount then
		action = action:gsub("%d+", "")
		usedCount = tonumber(actionCount) * usedCount
	end
	normal(tostring(usedCount) .. action)
end

---toggle wrap, colorcolumn, and hjkl visual/logical maps in one go
function M.toggleWrap()
	local wrapOn = opt_local.wrap:get()
	local opts = { buffer = true }

	if wrapOn then
		opt_local.wrap = false
		opt_local.colorcolumn = opt.colorcolumn:get()

		local del = vim.keymap.del
		del({ "n", "x" }, "H", opts)
		del({ "n", "x" }, "L", opts)
		del({ "n", "x" }, "J", opts)
		del({ "n", "x" }, "K", opts)
		del({ "n", "x" }, "k", opts)
		del({ "n", "x" }, "j", opts)
	else
		opt_local.wrap = true
		opt_local.colorcolumn = ""

		local keymap = vim.keymap.set
		keymap({ "n", "x" }, "H", "g^", opts)
		keymap({ "n", "x" }, "L", "g$", opts)
		keymap({ "n", "x" }, "J", function() M.overscroll("6gj") end, opts)
		keymap({ "n", "x" }, "K", "6gk", opts)
		keymap({ "n", "x" }, "k", "gk", opts)
		keymap({ "n", "x" }, "j", function() M.overscroll("gj") end, opts)
	end
end

--------------------------------------------------------------------------------
-- GIT

---@param commitMsg string
---@param gitShellOpts table
local function shimmeringFocusBuild(commitMsg, gitShellOpts)
	vim.notify(' Building theme…\n"' .. commitMsg .. '"')
	local buildScript =
		expand("~/Library/Mobile Documents/com~apple~CloudDocs/Repos/shimmering-focus/build.sh")
	fn.jobstart('zsh "' .. buildScript .. '" "' .. commitMsg .. '"', gitShellOpts)
end

---@param prefillMsg? string
function M.addCommitPush(prefillMsg)
	if not prefillMsg then prefillMsg = "" end

	local output = {}
	local gitShellOpts = {
		stdout_buffered = true,
		stderr_buffered = true,
		detach = true,
		on_stdout = function(_, data)
			for _, d in pairs(data) do
				if not (d[1] == "" and #d == 1) then table.insert(output, d) end
			end
		end,
		on_stderr = function(_, data)
			for _, d in pairs(data) do
				if not (d[1] == "" and #d == 1) then table.insert(output, d) end
			end
		end,
		on_exit = function()
			if #output == 0 then return end
			local out = table.concat(output, " \n "):gsub("%s*$", "")
			local logLevel = logInfo
			if out:lower():find("error") then
				logLevel = logError
			elseif out:lower():find("warning") then
				logLevel = logWarn
			end
			vim.notify(out, logLevel)
			-- HACK for linters writing the current file, and autoread failing, preventing to
			-- quit the file. Requires manual reloading via `:edit`.
			if bo.modifiable then
				cmd.mkview(1)
				cmd.edit()
				cmd.loadview(1)
			end
			-- specific to my setup
			os.execute("sketchybar --trigger repo-files-update")
		end,
	}

	-- uses dressing + cmp + omnifunc for autocompletion of filenames
	vim.ui.input(
		{ prompt = "Commit Message", default = prefillMsg, completion = "file" },
		function(commitMsg)
			if not commitMsg then
				return
			elseif #commitMsg > 50 then
				vim.notify("Commit Message too long.", logWarn)
				M.addCommitPush(commitMsg:sub(1, 50))
				return
			elseif commitMsg == "" then
				commitMsg = "chore"
			end

			local cc = {
				"chore",
				"build",
				"test",
				"fix",
				"feat",
				"refactor",
				"perf",
				"style",
				"revert",
				"ci",
				"docs",
			}
			local firstWord = commitMsg:match("^%w+")
			if not vim.tbl_contains(cc, firstWord) then
				vim.notify("Not using a Conventional Commits keyword.", logWarn)
				M.addCommitPush(commitMsg)
				return
			end

			-- Shimmering Focus specific actions instead
			if expand("%:p"):find("themes/Shimmering Focus/theme.css$") then
				shimmeringFocusBuild(commitMsg, gitShellOpts)
				return
			end

			vim.notify(' git add-commit-push\n"' .. commitMsg .. '"')
			fn.jobstart(
				"git add -A && git commit -m '" .. commitMsg .. "' ; git pull ; git push",
				gitShellOpts
			)
		end
	)
end

---normal mode: link to file
---visual mode: link to selected lines
function M.gitLink()
	local repo = fn.system([[git --no-optional-locks remote -v]]):gsub(".*:(.-)%.git .*", "%1")
	local branch = fn.system([[git --no-optional-locks branch --show-current]]):gsub("\n", "")
	if branch:find("^fatal: not a git repository") then
		vim.notify("Not a git repository.", logWarn)
		return
	end
	local filepath = expand("%:p")
	local gitroot = fn.system([[git --no-optional-locks rev-parse --show-toplevel]])
	local pathInRepo = filepath:sub(#gitroot)

	local location
	local selStart = fn.line("v")
	local selEnd = fn.line(".")
	local notVisualMode = not (fn.mode():find("[Vv]"))
	if notVisualMode then
		location = "" -- link just the file itself
	elseif selStart == selEnd then -- one-line-selection
		location = "#L" .. tostring(selStart)
	elseif selStart < selEnd then
		location = "#L" .. tostring(selStart) .. "-L" .. tostring(selEnd)
	else
		location = "#L" .. tostring(selEnd) .. "-L" .. tostring(selStart)
	end

	local gitRemote = "https://github.com/" .. repo .. "/blob/" .. branch .. pathInRepo .. location

	os.execute("open '" .. gitRemote .. "'")
	fn.setreg("+", gitRemote)
end

--------------------------------------------------------------------------------
-- MOVEMENT
-- performed via `:normal` makes them less glitchy

local function leaveVisualMode()
	-- https://github.com/neovim/neovim/issues/17735#issuecomment-1068525617
	local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
	vim.api.nvim_feedkeys(escKey, "nx", false)
end

function M.moveLineDown()
	if lineNo(".") == lineNo("$") then return end
	cmd([[. move +1]])
	if bo.filetype ~= "yaml" then normal("==") end
end

function M.moveLineUp()
	if lineNo(".") == 1 then return end
	cmd([[. move -2]])
	if bo.filetype ~= "yaml" then normal("==") end
end

function M.moveCharRight()
	if colNo(".") >= colNo("$") - 1 then return end
	normal('"zx"zp')
end

function M.moveCharLeft()
	if colNo(".") == 1 then return end
	normal('"zdh"zph')
end

function M.moveSelectionDown()
	leaveVisualMode()
	cmd([['<,'> move '>+1]])
	normal("gv=gv")
end

function M.moveSelectionUp()
	leaveVisualMode()
	cmd([['<,'> move '<-2]])
	normal("gv=gv")
end

function M.moveSelectionRight() normal('"zx"zpgvlolo') end

function M.moveSelectionLeft() normal('"zdh"zPgvhoho') end

--------------------------------------------------------------------------------

return M
