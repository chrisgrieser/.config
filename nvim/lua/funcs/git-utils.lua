local M = {}
local fn = vim.fn

local logWarn = vim.log.levels.WARN
local logError = vim.log.levels.ERROR
local logInfo = vim.log.levels.INFO

--------------------------------------------------------------------------------

---Choose a GitHub issues from the current repo to open in the browser
function M.issueSearch()
	local repo = fn.system("git remote -v | head -n1")
	if repo:find("^fatal") then
		vim.notify("Not a GitHub Repo.", logWarn)
		return
	end
	repo = repo:match(":.*%."):sub(2, -2)

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
---@param gitShellOpts table
local function shimmeringFocusBuild(commitMsg, gitShellOpts)
	local buildscriptLocation = vim.env.ICLOUD .. "/Repos/shimmering-focus/build.sh"

	vim.notify(' Building theme…\n"' .. commitMsg .. '"')
	fn.jobstart('zsh "' .. buildscriptLocation .. '" "' .. commitMsg .. '"', gitShellOpts)
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

			vim.cmd.checktime() -- reload buffer if changed (e.g., due to linters or pandocvim). Also requires opt.autoread
			os.execute("sketchybar --trigger repo-files-update") -- specific to my setup
		end,
	}

	vim.ui.input({ prompt = "Commit Message", default = prefillMsg }, function(commitMsg)
		if not commitMsg then
			return
		elseif #commitMsg > 50 then
			vim.notify("Commit Message too long.", logWarn)
			M.addCommitPush(commitMsg:sub(1, 50))
			return
		elseif commitMsg == "" then
			commitMsg = "chore"
		end
			-- stylua: ignore
		local cc = { "chore", "build", "test", "fix", "feat", "refactor", "perf", "style", "revert", "ci", "docs", "deprecate" }
		local firstWord = commitMsg:match("^%w+")
		if not vim.tbl_contains(cc, firstWord) then
			vim.notify("Not using a Conventional Commits keyword.", logWarn)
			M.addCommitPush(commitMsg)
			return
		end

		-- Shimmering Focus specific actions instead
		if expand("%") == "source.css" then
			shimmeringFocusBuild(commitMsg, gitShellOpts)
			return
		end

		vim.notify(' git add-commit-push\n"' .. commitMsg .. '"')
		fn.jobstart(
			"git add -A && git commit -m '" .. commitMsg .. "' ; git pull ; git push",
			gitShellOpts
		)
	end)
end

---normal mode: link to file
---visual mode: link to selected lines
function M.gitLink()
	local repo = fn.system([[git --no-optional-locks remote -v]]):gsub(".*:(.-)%.git .*", "%1")
	local branch = fn.system([[git --no-optional-locks branch --show-current]]):gsub("\n$", "")
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

	local gitRemote = "https://github.com/" .. repo .. "/blob/" .. branch .. pathInRepo

	local resultUrl = gitRemote .. location
	os.execute("open '" .. resultUrl .. "'")
	fn.setreg("+", resultUrl)
end

--------------------------------------------------------------------------------
return M
