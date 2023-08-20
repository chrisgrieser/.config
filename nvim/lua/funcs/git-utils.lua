local M = {}
local fn = vim.fn

--------------------------------------------------------------------------------
-- HELPERS

---also notifies if not in git repo
---@nodiscard
---@return boolean
local function isInGitRepo()
	fn.system("git rev-parse --is-inside-work-tree")
	local inGitRepo = vim.v.shell_error == 0
	if not inGitRepo then vim.notify("Not a GitHub Repo.", vim.log.levels.WARN) end
	return inGitRepo
end

--NOTE this requires an outer-scope output variable which needs to be emptied
--before the run
local output = {}
local gitShellOpts = {
	stdout_buffered = true,
	stderr_buffered = true,
	detach = true, -- run even when quitting nvim
	on_stdout = function(_, data)
		if not (data[1] == "") then table.insert(output, data[1]) end
	end,
	on_stderr = function(_, data)
		if not (data[1] == "") then table.insert(output, data[1]) end
	end,
	on_exit = function()
		-- reload buffer if changed, e.g., due to linters or pandocvim
		-- (also requires opt.autoread being enabled)
		vim.cmd("silent checktime")
		os.execute("sketchybar --trigger repo-files-update") -- specific to my setup

		if #output == 0 then return end
		local out = table.concat(output, " \n ")

		local logLevel
		if out:lower():find("error") then
			logLevel = vim.log.levels.ERROR
			fn.system("afplay '/System/Library/Sounds/Basso.aiff' &")
		elseif out:lower():find("warning") then
			logLevel = vim.log.levels.WARN
			fn.system("afplay '/System/Library/Sounds/Basso.aiff' &")
		else
			logLevel = vim.log.levels.INFO
			-- stylua: ignore
			fn.system("afplay '/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/siri/jbl_confirm.caf' &")
		end
		vim.notify(out, logLevel)

		output = {} -- empty for next run
	end,
}

---process a commit message: less than 50 chars, not empty, adheres to
---conventional commits
---@param commitMsg string
---@nodiscard
---@return boolean is the commit message valid?
---@return string the (modified) commit message
local function processCommitMsg(commitMsg)
	-- ensure max 50 chars
	if #commitMsg > 50 then
		vim.notify("Commit Message too long.", vim.log.levels.WARN)
		local shortenedMsg = commitMsg:sub(1, 50)
		return false, shortenedMsg

	-- no commitMsg -> prefill just "chore"
	elseif commitMsg == "" then
		return true, "chore"
	end

	-- ensure conventional commits
	-- stylua: ignore
	local conventionalCommits = { "chore", "build", "test", "fix", "feat", "refactor", "perf", "style", "revert", "ci", "docs", "improv", "break" }
	local firstWord = commitMsg:match("^%w+")
	if not vim.tbl_contains(conventionalCommits, firstWord) then
		vim.notify("Not using a Conventional Commits keyword.", vim.log.levels.WARN)
		return false, commitMsg
	end

	-- message ok
	return true, commitMsg
end

---@param on boolean true = highlights on, false = highlights off
local function hlTooLongCommitMsgs(on)
	if on then
		vim.api.nvim_create_augroup("tooLongCommitMsg", {})
		vim.api.nvim_create_autocmd("FileType", {
			group = "tooLongCommitMsg",
			pattern = "DressingInput",
			callback = function()
				vim.g.matchid = fn.matchadd("commitmsg", [[.\{50}\zs.*\ze]])
				vim.opt_local.colorcolumn = "50"
				vim.cmd.highlight("commitmsg", "guibg=#E06C75")
			end,
		})
	else
		-- clear the previously setup hl again, so other Input fields are not affected
		-- also done early, so the highlight is even deleted on aborting the input
		vim.api.nvim_del_augroup_by_name("tooLongCommitMsg")
		pcall(function() fn.matchdelete(vim.g.matchid) end)
	end
end

--------------------------------------------------------------------------------

---@param commitMsg string
local function shimmeringFocusBuild(commitMsg)
	-- accessing build file directly, since passing arguments (the commit msg)
	-- via makefile is unnecessarily cumbersome
	local buildscriptLocation = vim.env.LOCAL_REPOS .. "/shimmering-focus/build.sh"
	vim.notify('󰊢 Building theme…\n"' .. commitMsg .. '"')
	output = {}
	local command = string.format("zsh '%s' '%s'", buildscriptLocation, commitMsg)
	fn.jobstart(command, gitShellOpts)
end

function M.amendNoEditPushForce()
	vim.cmd("silent update")
	if not isInGitRepo() then return end

	local lastCommitMsg = fn.system("git log -1 --pretty=%B"):gsub("%s+$", "")
	vim.notify('󰊢 Amend-No-Edit & Force Push…\n"' .. lastCommitMsg .. '"')
	fn.jobstart("git add -A && git commit --amend --no-edit ; git push -f", gitShellOpts)
end

---@param prefillMsg? string
function M.amendAndPushForce(prefillMsg)
	vim.cmd.update()
	if not isInGitRepo() then return end

	if not prefillMsg then
		local lastCommitMsg = fn.system("git log -1 --pretty=%B"):gsub("%s+$", "")
		prefillMsg = lastCommitMsg
	end
	hlTooLongCommitMsgs(true)

	vim.ui.input({ prompt = " 󰊢 Amend", default = prefillMsg }, function(commitMsg)
		hlTooLongCommitMsgs(false) -- early, so also done on cancellation
		if not commitMsg then return end -- aborted input modal
		local validMsg, newMsg = processCommitMsg(commitMsg)

		if not validMsg then -- if msg invalid, run again to fix the msg
			M.amendAndPushForce(newMsg)
			return
		end

		vim.notify('󰊢 Amend & Force Push…\n"' .. newMsg .. '"')
		fn.jobstart(
			"git add -A && git commit --amend -m '" .. newMsg .. "' ; git push --force",
			gitShellOpts
		)
	end)
end

---@param prefillMsg? string
function M.commit(prefillMsg)
	output = {}
	vim.cmd("silent update")
	if not isInGitRepo() then return end
	if not prefillMsg then prefillMsg = "" end
	hlTooLongCommitMsgs(true)

	vim.ui.input({ prompt = " 󰊢 Commit Message", default = prefillMsg }, function(commitMsg)
		hlTooLongCommitMsgs(false) -- early, so also done on cancellation
		if not commitMsg then return end -- aborted input modal
		local validMsg, newMsg = processCommitMsg(commitMsg)
		if not validMsg then -- if msg invalid, run again to fix the msg
			M.addCommitPush(newMsg)
			return
		end

		vim.notify('󰊢 git commit\n"' .. newMsg .. '"')
		fn.system { "git", "commit", "-m", newMsg }
	end)
end

---@param prefillMsg? string
function M.addCommitPush(prefillMsg)
	output = {}
	vim.cmd("silent update")
	if not isInGitRepo() then return end
	if not prefillMsg then prefillMsg = "" end
	hlTooLongCommitMsgs(true)

	vim.ui.input({ prompt = " 󰊢 Commit Message", default = prefillMsg }, function(commitMsg)
		hlTooLongCommitMsgs(false) -- early, so also done on cancellation
		if not commitMsg then return end -- aborted input modal
		local validMsg, newMsg = processCommitMsg(commitMsg)
		if not validMsg then -- if msg invalid, run again to fix the msg
			M.addCommitPush(newMsg)
			return
		end

		-- run Shimmering Focus specific actions instead
		if fn.expand("%") == "source.css" then
			shimmeringFocusBuild(newMsg)
			return
		end

		vim.notify('󰊢 git add-commit-push\n"' .. newMsg .. '"')
		fn.jobstart(
			"git add -A && git commit -m '" .. newMsg .. "' ; git pull ; git push --force",
			gitShellOpts
		)
	end)
end

---opens current buffer in the browser & copies the link to the clipboard
---normal mode: link to file
---visual mode: link to selected lines
function M.githubUrl()
	if not isInGitRepo() then return end

	local filepath = fn.expand("%:p")
	local gitroot = fn.system("git --no-optional-locks rev-parse --show-toplevel")
	local pathInRepo = filepath:sub(#gitroot + 1)
	local pathInRepoEncoded = pathInRepo:gsub("%s+", "%%20")
	local remote = fn.system("git --no-optional-locks remote -v"):gsub(".*:(.-)%.git.*", "%1")
	local hash = fn.system("git --no-optional-locks rev-parse HEAD"):gsub("\n$", "")

	local selStart = fn.line("v")
	local selEnd = fn.line(".")
	local isVisualMode = fn.mode():find("[Vv]")

	local location
	if not isVisualMode then
		location = "" -- link just the file itself
	elseif selStart == selEnd then -- one-line-selection
		location = "#L" .. tostring(selStart)
	elseif selStart < selEnd then
		location = "#L" .. tostring(selStart) .. "-L" .. tostring(selEnd)
	else
		location = "#L" .. tostring(selEnd) .. "-L" .. tostring(selStart)
	end

	-- example: https://github.com/chrisgrieser/.config/blob/4cc310490c4492be3fe144d572635012813c7822/nvim/lua/config/textobject-keymaps.lua#L8-L20
	local url = ("https://github.com/%s/blob/%s/%s%s"):format(remote, hash, pathInRepoEncoded, location)

	os.execute("open '" .. url .. "'") -- open in browser (macOS cli)
	fn.setreg("+", url) -- copy to clipboard
end

--------------------------------------------------------------------------------
return M
