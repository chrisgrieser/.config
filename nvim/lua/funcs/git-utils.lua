local M = {}
local fn = vim.fn

--------------------------------------------------------------------------------
-- HELPERS

---also notifies if not in git repo
---@nodiscard
---@return boolean
local function isInGitRepo()
	fn.system("git rev-parse --is-inside-work-tree")
	if vim.v.shell_error ~= 0 then
		vim.notify("Not a GitHub Repo.", vim.log.levels.WARN)
		return false
	end
	return true
end

--NOTE this requires an outer-scope output variable which needs to be emptied
--before the run
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
		-- reload buffer if changed, e.g., due to linters or pandocvim
		-- (also requires opt.autoread being enabled)
		vim.cmd.checktime()
		os.execute("sketchybar --trigger repo-files-update") -- specific to my setup

		if #output == 0 then return end
		local out = table.concat(output, " \n "):gsub("%s*$", ""):gsub("\r", "\n")

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
	local conventionalCommits = { "chore", "build", "test", "fix", "feat", "refactor", "perf", "style", "revert", "ci", "docs" }
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

---Choose a GitHub issues from the current repo to open in the browser. Due to
---GitHub API liminations, only the last 100 issues are shown.
---@param state "open"|"closed"|"all"
function M.issueSearch(state)
	if not isInGitRepo() then return end

	local repo = fn.system("git remote -v | head -n1"):match(":.*%."):sub(2, -2)

	-- TODO figure out how to make a proper http request in nvim
	local rawJSON = fn.system(
		([[curl -sL "https://api.github.com/repos/%s/issues?per_page=100&state=%s"]]):format(repo, state)
	)
	local issues = vim.json.decode(rawJSON)

	if not issues or #issues == 0 then
		local type = state .. " "
		if state == "all" then type = "" end
		vim.notify(("There are no %sissues or PRs for this repo."):format(type), vim.log.levels.WARN)
		return
	end

	local function formatter(issue)
		local isPR = issue.pull_request ~= nil
		local merged = isPR and issue.pull_request.merged_at ~= nil

		local icon
		if issue.state == "open" and isPR then
			icon = "🟦 "
		elseif issue.state == "closed" and isPR and merged then
			icon = "🟨 "
		elseif issue.state == "closed" and isPR and not merged then
			icon = "🟥 "
		elseif issue.state == "closed" and not isPR then
			icon = "🟣 "
		elseif issue.state == "open" and not isPR then
			icon = "🟢 "
		end
		if issue.title:lower():find("request") or issue.title:find("FR") then icon = icon .. "🙏 " end
		if issue.title:lower():find("bug") then icon = icon .. "🪲 " end

		return icon .. "#" .. issue.number .. " " .. issue.title
	end

	vim.ui.select(
		issues,
		{ prompt = "Select Issue:", kind = "github_issue", format_item = formatter },
		function(choice)
			if not choice then return end
			fn.system("open '" .. choice.html_url .. "'")
		end
	)
end

---@param commitMsg string
local function shimmeringFocusBuild(commitMsg)
	local buildscriptLocation = vim.env.LOCAL_REPOS .. "/shimmering-focus/build.sh"

	vim.notify('󰊢 Building theme…\n"' .. commitMsg .. '"')
	output = {}
	local command = string.format("zsh '%s' '%s'", buildscriptLocation, commitMsg)
	fn.jobstart(command, gitShellOpts)
end

function M.amendNoEditPushForce()
	vim.cmd.update()
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
function M.addCommitPush(prefillMsg)
	output = {}
	vim.cmd.update()
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
	local gitroot = fn.system([[git --no-optional-locks rev-parse --show-toplevel]])
	local pathInRepo = filepath:sub(#gitroot + 1)
	local remote = fn.system([[git --no-optional-locks remote -v]]):gsub(".*:(.-)%.git.*", "%1")
	local branch = fn.system([[git --no-optional-locks branch --show-current]]):gsub("\n$", "")

	local location
	local selStart = fn.line("v")
	local selEnd = fn.line(".")
	local notVisualMode = not (fn.mode():find("[Vv]"))
	if notVisualMode then
		location = "" -- link just the file itself
	elseif selStart == selEnd then -- one-line-selection
		location = "L" .. tostring(selStart)
	elseif selStart < selEnd then
		location = "L" .. tostring(selStart) .. "-L" .. tostring(selEnd)
	else
		location = "L" .. tostring(selEnd) .. "-L" .. tostring(selStart)
	end

	local url = string.format("https://github.com/%s/blob/%s/%s", remote, branch, pathInRepo)
	if location ~= "" then url = url .. "#" .. location end

	os.execute("open '" .. url .. "'") -- open in browser (macOS cli)
	fn.setreg("+", url) -- copy to clipboard
end

--------------------------------------------------------------------------------
return M
