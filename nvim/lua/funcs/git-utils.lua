local M = {}
local fn = vim.fn
local logWarn = vim.log.levels.WARN

--------------------------------------------------------------------------------
-- HELPERS

---also notifies if not in git repo
---@return boolean
local function isInGitRepo()
	fn.system("git rev-parse --is-inside-work-tree")
	if vim.v.shell_error ~= 0 then
		vim.notify("Not a GitHub Repo.", logWarn)
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
		if #output == 0 then return end
		local out = table.concat(output, " \n "):gsub("%s*$", "")
		local logLevel = logInfo
		if out:lower():find("error") then
			logLevel = logError
		elseif out:lower():find("warning") then
			logLevel = logWarn
		end
		vim.notify(out, logLevel)

		vim.cmd.checktime() -- reload buffer if changed (e.g., due to linters or pandocvim). Also requires opt.autoread
		os.execute("sketchybar --trigger repo-files-update") -- specific to my setup

		-- confirmation sound
		fn.system(
			"afplay '/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/siri/jbl_confirm.caf' &"
		)
	end,
}

---process a commit message
---@param commitMsg string
---@return boolean is the commit message valid?
---@return string the (modified) commit message
local function processCommitMsg(commitMsg)
	if #commitMsg > 50 then
		vim.notify("Commit Message too long.", logWarn)
		local shortenedMsg = commitMsg:sub(1, 50)
		return false, shortenedMsg
	elseif commitMsg == "" then
		return true, "chore"
	end
	-- stylua: ignore
	local cc = { "chore", "build", "test", "fix", "feat", "refactor", "perf", "style", "revert", "ci", "docs" }
	local firstWord = commitMsg:match("^%w+")
	if not vim.tbl_contains(cc, firstWord) then
		vim.notify("Not using a Conventional Commits keyword.", logWarn)
		return false, commitMsg
	end
	return true, commitMsg
end

--------------------------------------------------------------------------------

---Choose a GitHub issues from the current repo to open in the browser
function M.issueSearch()
	if not isInGitRepo() then return end

	local repo = fn.system("git remote -v | head -n1"):match(":.*%."):sub(2, -2)

	-- TODO figure out how to make a proper http request in nvim
	local max_results = 20
	local rawJSON = fn.system(
		[[curl -sL "https://api.github.com/repos/]]
			.. repo
			.. [[/issues?per_page=]]
			.. max_results
			.. [[&state=open"]]
	)
	local issues = vim.json.decode(rawJSON)

	if #issues == 0 then
		vim.notify("There are no issues or PRs for this repo.", logWarn)
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
	local buildscriptLocation = vim.env.ICLOUD .. "/Repos/shimmering-focus/build.sh"

	vim.notify(' Building theme…\n"' .. commitMsg .. '"')
	output = {}
	local command = string.format("zsh '%s' '%s'", buildscriptLocation, commitMsg)
	fn.jobstart(command, gitShellOpts)
end

---amend
---@param noedit any
function M.amendAndPushForce(noedit)
	if not isInGitRepo() then return end
	output = {}
	if noedit then
		vim.notify(" Amend-No-Edit & Force Push")
		fn.jobstart("git add -A && git commit --amend --no-edit ; git push -f", gitShellOpts)
	else
		local lastCommitMsg = fn.system("git log -1 --pretty=%B"):gsub("%s+$", "")
		vim.ui.input({prompt = "Amend", default = commitMsg}, function (commitMsg)
			
		end)
		vim.notify(" Amend & Force Push")
	end
end

---@param prefillMsg? string
function M.addCommitPush(prefillMsg)
	if not isInGitRepo() then return end

	if not prefillMsg then prefillMsg = "" end

	vim.ui.input({ prompt = "Commit Message", default = prefillMsg }, function(commitMsg)
		if not commitMsg then return end -- aborted input modal

		local validMsg, newMsg = processCommitMsg(commitMsg)

		-- if msg invalid, run again to fix the msg
		if not validMsg then
			M.addCommitPush(newMsg)			
			return
		end

		-- run Shimmering Focus specific actions instead
		if expand("%") == "source.css" then
			shimmeringFocusBuild(newMsg)
			return
		end

		vim.notify(' git add-commit-push\n"' .. newMsg .. '"')
		output = {}
		fn.jobstart(
			"git add -A && git commit -m '" .. newMsg .. "' ; git pull ; git push",
			gitShellOpts
		)
	end)
end

---normal mode: link to file
---visual mode: link to selected lines
function M.gitLink()
	if not isInGitRepo() then return end

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

	local gitRemote = "https://github.com/"
		.. fn.system([[git --no-optional-locks remote -v]]):gsub(".*:(.-)%.git .*", "%1")
		.. "/blob/"
		.. fn.system([[git --no-optional-locks branch --show-current]]):gsub("\n$", "")
		.. pathInRepo

	local resultUrl = gitRemote .. location
	os.execute("open '" .. resultUrl .. "'")
	fn.setreg("+", resultUrl)
end

--------------------------------------------------------------------------------
return M
