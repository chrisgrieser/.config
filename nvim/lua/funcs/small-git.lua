local M = {}
local fn = vim.fn

--------------------------------------------------------------------------------
-- CONFIG
local commitMsgMaxLength = 72

--------------------------------------------------------------------------------
-- HELPERS

---send notification
---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	local pluginName = "Small Git"
	vim.notify(msg, vim.log.levels[level:upper()], { title = pluginName })
end

---also notifies if not in git repo
---@nodiscard
---@return boolean
local function isInGitRepo()
	fn.system("git rev-parse --is-inside-work-tree")
	local inGitRepo = vim.v.shell_error == 0
	if not inGitRepo then notify("Not in Git Repo.", "warn") end
	return inGitRepo
end

---if on mac, play a sound
---@param soundFilepath string
local function playSoundMacOS(soundFilepath)
	if vim.fn.has("macunix") ~= 1 then return end
	fn.system(("afplay %q &"):format(soundFilepath))
end

--NOTE this requires an outer-scope output variable which needs to be emptied
--before the run
local gitShellOpts = {
	stdout_buffered = true,
	stderr_buffered = true,
	detach = true, -- run even when quitting nvim
	on_stdout = function(_, data)
		if data[1] == "" and #data == 1 then return end
		local output = table.concat(data, "\n"):gsub("%s*$", "")

		-- no need to notify that the pull in `git pull ; git push` yielded no update
		if output:find("Current branch .* is up to date") then return end

		notify(output)
		playSoundMacOS(
			"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/siri/jbl_confirm.caf" -- codespell-ignore
		)
	end,
	on_stderr = function(_, data)
		if data[1] == "" and #data == 1 then return end
		local output = table.concat(data, "\n"):gsub("%s*$", "")

		-- git often puts non-errors into STDERR, therefore checking here again
		-- whether it is actually an error or not
		local logLevel = "info"
		local sound =
			"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/siri/jbl_confirm.caf" -- codespell-ignore
		if output:lower():find("error") then
			logLevel = "error"
			sound = "/System/Library/Sounds/Basso.aiff"
		elseif output:lower():find("warning") then
			logLevel = "warn"
			sound = "/System/Library/Sounds/Basso.aiff"
		end

		notify(output, logLevel)
		playSoundMacOS(sound)
	end,
}

---process a commit message: less than 50 chars, not empty, adheres to
---conventional commits
---@param commitMsg string
---@nodiscard
---@return boolean is the commit message valid?
---@return string the (modified) commit message
local function processCommitMsg(commitMsg)
	commitMsg = vim.trim(commitMsg)
	if #commitMsg > commitMsgMaxLength then
		notify("Commit Message too long.", "warn")
		local shortenedMsg = commitMsg:sub(1, commitMsgMaxLength)
		return false, shortenedMsg
	elseif commitMsg == "" then
		return true, "chore"
	end

	-- ensure conventional commits
	-- stylua: ignore
	local conventionalCommits = { "chore", "build", "test", "fix", "feat", "refactor", "perf", "style", "revert", "ci", "docs", "improv", "break" }
	local firstWord = commitMsg:match("^%w+")
	if not vim.tbl_contains(conventionalCommits, firstWord) then
		notify("Not using a Conventional Commits keyword.", "warn")
		return false, commitMsg
	end

	-- message ok
	return true, commitMsg
end

-- Uses ColorColumn to indicate max length of commit messages, and
-- additionally colors commit messages that are too long in red.
local function setGitCommitAppearance()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "DressingInput",
		once = true, -- do not affect other dressing inputs
		callback = function()
			local winNs = 2
			vim.api.nvim_win_set_hl_ns(0, winNs)
			fn.matchadd("commitmsg", ([[.\{%s}\zs.*\ze]]):format(commitMsgMaxLength - 1))

			-- for treesitter highlighting
			vim.bo.filetype = "gitcommit"
			vim.api.nvim_set_hl(winNs, "Title", { link = "Normal" })

			-- fix confirming input field (not working in insert mode due to filetype change)
			vim.keymap.set("i", "<CR>", "<Esc><CR>", { buffer = true, remap = true })

			vim.api.nvim_buf_set_name(0, "COMMIT_EDITMSG") -- for statusline

			vim.opt_local.colorcolumn = { 50, commitMsgMaxLength } -- https://stackoverflow.com/questions/2290016/git-commit-messages-50-72-formatting
			vim.api.nvim_set_hl(winNs, "commitmsg", { bg = "#E06C75" })
		end,
	})
end

--------------------------------------------------------------------------------

function M.amendNoEditPushForce()
	vim.cmd("silent update")
	if not isInGitRepo() then return end

	local lastCommitMsg = fn.system("git log -1 --pretty=%B"):gsub("%s+$", "")
	notify('󰊢 Amend-No-Edit & Force Push…\n"' .. lastCommitMsg .. '"')

	local stderr = fn.system("git add -A && git commit --amend --no-edit")
	if vim.v.shell_error ~= 0 then
		vim.notify("Error: " .. stderr, vim.log.levels.WARN)
		return
	end

	fn.jobstart("git push --force", gitShellOpts)
end

---@param prefillMsg? string
function M.amendAndPushForce(prefillMsg)
	vim.cmd.update()
	if not isInGitRepo() then return end

	if not prefillMsg then
		local lastCommitMsg = fn.system("git log -1 --pretty=%B"):gsub("%s+$", "")
		prefillMsg = lastCommitMsg
	end
	setGitCommitAppearance()

	vim.ui.input({ prompt = " 󰊢 Amend", default = prefillMsg }, function(commitMsg)
		if not commitMsg then return end -- aborted input modal
		local validMsg, newMsg = processCommitMsg(commitMsg)

		if not validMsg then -- if msg invalid, run again to fix the msg
			M.amendAndPushForce(newMsg)
			return
		end

		notify('󰊢 Amend & Force Push…\n"' .. newMsg .. '"')
		local stderr = fn.system("git add -A && git commit --amend -m '" .. newMsg .. "'")
		if vim.v.shell_error ~= 0 then
			notify(stderr, "warn")
			return
		end

		fn.jobstart("git push --force", gitShellOpts)
	end)
end

---@param prefillMsg? string
function M.commit(prefillMsg)
	vim.cmd("silent update")
	if not isInGitRepo() then return end
	if not prefillMsg then prefillMsg = "" end
	setGitCommitAppearance()

	vim.ui.input({ prompt = " 󰊢 Commit Message:", default = prefillMsg }, function(commitMsg)
		if not commitMsg then return end -- aborted input modal
		local validMsg, newMsg = processCommitMsg(commitMsg)
		if not validMsg then -- if msg invalid, run again to fix the msg
			M.addCommitPush(newMsg)
			return
		end

		notify('󰊢 Commit\n"' .. newMsg .. '"')
		local stderr = fn.system { "git", "commit", "-m", newMsg }
		if vim.v.shell_error ~= 0 then notify(stderr, "warn") end
	end)
end

---@param prefillMsg? string
function M.addCommit(prefillMsg)
	local stderr = fn.system { "git", "add", "-A" }
	if vim.v.shell_error ~= 0 then
		notify(stderr, "warn")
		return
	end
	M.commit(prefillMsg)
end

---@param prefillMsg? string
function M.addCommitPush(prefillMsg)
	vim.cmd("silent update")
	if not isInGitRepo() then return end
	if not prefillMsg then prefillMsg = "" end
	setGitCommitAppearance()

	vim.ui.input({ prompt = " 󰊢 Commit Message", default = prefillMsg }, function(commitMsg)
		if not commitMsg then return end -- aborted input modal
		local validMsg, newMsg = processCommitMsg(commitMsg)
		if not validMsg then -- if msg invalid, run again to fix the msg
			M.addCommitPush(newMsg)
			return
		end

		notify('󰊢 Add-Commit-Push\n"' .. newMsg .. '"')

		local stderr = fn.system("git add -A && git commit -m '" .. newMsg .. "'")
		if vim.v.shell_error ~= 0 then
			stderr = stderr:gsub("%s*$", "")
			notify(stderr, "warn")
			return
		end

		fn.jobstart("git pull ; git push", gitShellOpts)
	end)
end

---opens current buffer in the browser & copies the link to the clipboard
---normal mode: link to file
---visual mode: link to selected lines
---@param justOpenRepo any -- don't link to file with a specific commit, just link to repo
function M.githubUrl(justOpenRepo)
	if not isInGitRepo() then return end

	local filepath = fn.expand("%:p")
	local gitroot = fn.system("git --no-optional-locks rev-parse --show-toplevel")
	local pathInRepo = filepath:sub(#gitroot + 1)

	local pathInRepoEncoded = pathInRepo:gsub("%s+", "%%20")
	local remote = fn.system("git --no-optional-locks remote -v"):gsub(".*:(.-)%.git.*", "%1")
	local hash = fn.system("git --no-optional-locks rev-parse HEAD"):gsub("\n$", "")
	local branch = fn.system("git --no-optional-locks branch --show-current"):gsub("\n$", "")

	local selStart = fn.line("v")
	local selEnd = fn.line(".")
	local isVisualMode = fn.mode():find("[Vv]")
	local isNormalMode = fn.mode() == "n"
	local url = "https://github.com/" .. remote

	if not justOpenRepo and isNormalMode then
		url = url .. ("/blob/%s/%s"):format(branch, pathInRepoEncoded)
	elseif not justOpenRepo and isVisualMode then
		local location
		if selStart == selEnd then -- one-line-selection
			location = "#L" .. tostring(selStart)
		elseif selStart < selEnd then
			location = "#L" .. tostring(selStart) .. "-L" .. tostring(selEnd)
		else
			location = "#L" .. tostring(selEnd) .. "-L" .. tostring(selStart)
		end

		-- example: https://github.com/chrisgrieser/.config/blob/4cc310490c4492be3fe144d572635012813c7822/nvim/lua/config/textobject-keymaps.lua#L8-L20
		url = url .. ("/blob/%s/%s%s"):format(hash, pathInRepoEncoded, location)
	end

	vim.fn.system { "open", url } -- macOS cli
	fn.setreg("+", url) -- copy to clipboard
end

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
		local type = state == "all" and "" or state .. " "
		notify(("There are no %sissues or PRs for this repo."):format(type), "warn")
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
			fn.system { "open", choice.html_url }
		end
	)
end

--------------------------------------------------------------------------------
return M
