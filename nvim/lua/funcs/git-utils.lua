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
local gitShellOpts = {
	stdout_buffered = true,
	stderr_buffered = true,
	detach = true, -- run even when quitting nvim
	on_stdout = function(_, data)
		if data[1] == "" and #data == 1 then return end
		local output = table.concat(data, "\n")

		-- prevent double notifications
		local ok, notify = pcall(require, "notify")
		if ok then notify.dismiss() end

		vim.notify(output)
	end,
	on_stderr = function(_, data)
		if data[1] == "" and #data == 1 then return end
		local output = table.concat(data, "\n")

		-- git puts non-errors into STDERR?
		local logLevel = vim.log.levels.INFO
		if output:lower():find("error") then
			logLevel = vim.log.levels.ERROR
		elseif output:lower():find("warning") then
			logLevel = vim.log.levels.WARN
		end

		vim.notify(output, logLevel)
	end,
	on_exit = function()
		-- reload buffer if changed, e.g., due to linters or pandocvim
		-- (also requires opt.autoread being enabled)
		vim.cmd("silent checktime")
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

-- Uses ColorColumn of 50 to indicate max length of commit messages, and
-- additionally colors commit messages that are too long in red.
local function setGitCommitAppearance()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "DressingInput",
		once = true, -- do not affect other dressing inputs
		callback = function()
			local winNs = 1
			vim.api.nvim_win_set_hl_ns(0, winNs)
			fn.matchadd("commitmsg", [[.\{49}\zs.*\ze]])

			vim.bo.filetype = "gitcommit" -- for treesitter highlighting
			vim.api.nvim_set_hl(winNs, "Title", { link = "Normal" })

			vim.opt_local.colorcolumn = "50"
			vim.api.nvim_set_hl(winNs, "ColorColumn", { link = "DiagnosticVirtualTextInfo" })
			vim.api.nvim_set_hl(winNs, "commitmsg", { bg = "#E06C75" })
		end,
	})
end

--------------------------------------------------------------------------------

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
	setGitCommitAppearance()

	vim.ui.input({ prompt = " 󰊢 Amend", default = prefillMsg }, function(commitMsg)
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

		vim.notify('󰊢 git commit\n"' .. newMsg .. '"')
		local stdout = fn.system { "git", "commit", "-m", newMsg }
		if vim.v.shell_error ~= 0 then vim.notify("Error: " .. stdout, vim.log.levels.WARN) end
	end)
end

---@param prefillMsg? string
function M.addCommit(prefillMsg)
	local stdout = fn.system { "git", "add", "-A" }
	if vim.v.shell_error ~= 0 then
		vim.notify("Error: " .. stdout, vim.log.levels.WARN)
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
---@param justOpenRepo any
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

--------------------------------------------------------------------------------
return M
