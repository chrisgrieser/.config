local M = {}
--------------------------------------------------------------------------------

local pluginName = "Git Jumper"

local config = {
	gotoChangedFiles = {
		maxFiles = 5,
		currentFileIcon = "",
	},
	gotoLastCommittedChangeInFile = {
		highlightDurationMs = 2000,
		highlightGroup = "DiffText",
	},
}

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = pluginName })
end

--------------------------------------------------------------------------------

local changedFileNotif
function M.gotoChangedFiles()
	local opts = config.gotoChangedFiles

	-- get numstat
	vim.system({ "git", "add", "--intent-to-add", "--all" }):wait() -- so new files show up in `--numstat`
	local gitResponse = vim.system({ "git", "diff", "--numstat" }):wait()
	local numstat = vim.trim(gitResponse.stdout)
	local numstatLines = vim.split(numstat, "\n")

	-- GUARD
	if gitResponse.code ~= 0 then
		notify("Not in git repo", "warn")
		return
	elseif numstat == "" then
		notify("No changes found.", "info")
		return
	end

	-- parameters
	local gitroot = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }):wait().stdout)
	local pwd = vim.uv.cwd() or ""
	local currentFile = vim.api.nvim_buf_get_name(0)

	-- Changed Files, sorted by most changes
	---@type {relPath: string, absPath: string, changes: number}[]
	local changedFiles = {}
	for _, line in pairs(numstatLines) do
		local added, deleted, file = line:match("(%d+)%s+(%d+)%s+(.+)")
		if added and deleted and file then -- exclude changed binaries
			local changes = tonumber(added) + tonumber(deleted)
			local absPath = vim.fs.normalize(gitroot .. "/" .. file)
			local relPath = absPath:sub(#pwd + 2)

			-- only add if in pwd, useful for monorepos
			if vim.startswith(absPath, pwd) then
				table.insert(changedFiles, { relPath = relPath, absPath = absPath, changes = changes })
			end
		end
	end
	table.sort(changedFiles, function(a, b) return a.changes > b.changes end)
	changedFiles = vim.list_slice(changedFiles, 1, opts.maxFiles)

	-- GUARD
	if #changedFiles == 1 and changedFiles[1].absPath == currentFile then
		notify("Already at only changed file.", "info")
		return
	end

	-- Select next file
	local nextFileIndex
	for i = 1, #changedFiles do
		if changedFiles[i].absPath == currentFile then
			nextFileIndex = math.fmod(i, #changedFiles) + 1 -- `fmod` = lua's modulo
			break
		end
	end
	if not nextFileIndex then nextFileIndex = 1 end

	local nextFile = changedFiles[nextFileIndex]
	vim.cmd.edit(nextFile.absPath)

	-----------------------------------------------------------------------------
	-- NOTIFICATION

	-- GUARD
	local notifyInstalled, notifyNvim = pcall(require, "notify")
	if not notifyInstalled then return end

	-- get width defined by user for nvim-notify to avoid overflow/wrapped lines
	-- INFO max_width can be number, nil, or function, see https://github.com/chrisgrieser/nvim-tinygit/issues/6#issuecomment-1999537606
	local _, notifyConfig = notifyNvim.instance()
	local width = 50
	if notifyConfig and notifyConfig.max_width then
		local max_width = type(notifyConfig.max_width) == "number" and notifyConfig.max_width
			or notifyConfig.max_width()
		width = max_width - 9 -- padding, border, prefix & space, ellipsis
	end

	local listOfChangedFiles = {}
	for i = 1, #changedFiles do
		local prefix = (i == nextFileIndex and opts.currentFileIcon or "·")
		local path = changedFiles[i].relPath
		-- +2 for prefix + space
		local displayPath = #path + 2 > width and "…" .. path:sub(-1 - width) or path
		table.insert(listOfChangedFiles, prefix .. " " .. displayPath)
	end
	local msg = table.concat(listOfChangedFiles, "\n")

	changedFileNotif = vim.notify(msg, vim.log.levels.INFO, {
		title = pluginName,
		replace = changedFileNotif and changedFileNotif.id,
		animate = false,
		hide_from_history = true,
		on_open = function(win)
			local bufnr = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_call(
				bufnr,
				function() vim.fn.matchadd("Title", opts.currentFileIcon .. ".*") end
			)
		end,
	})
end

function M.gotoLastCommittedChangeInFile()
	local opts = config.gotoLastCommittedChangeInFile
	local file = vim.api.nvim_buf_get_name(0)

	-- stylua: ignore
	local cmd = { "git", "--no-pager", "log", "--max-count=1", "--patch", "--unified=0", "--format=", "--", file }
	local result = vim.system(cmd):wait()
	if result.code ~= 0 then
		notify(result.stderr or "", "error")
		return
	elseif result.stdout == "" then
		notify("File has not last committed change.", "warn")
		return
	end
	vim.notify(result.stdout, vim.log.levels.INFO, { title = "Diff" })

	-- INFO meaning of the `@@` lines: https://stackoverflow.com/a/31615728/22114136
	local changedInLastCommit = vim.iter(vim.split(result.stdout, "\n"))
		:filter(function(line) return vim.startswith(line, "@@ ") end)
		:map(function(line)
			local start, length = line:match("%+(%d+),(%d+)")
			if not start then
				start, length = line:match("%+(%d+)"), 0
			end
			return { start = tonumber(start), length = tonumber(length) }
		end)
		:totable()
	local firstChange = changedInLastCommit[1]

	-- goto beginning of first last change
	vim.api.nvim_win_set_cursor(0, { firstChange.start, 0 })

	-- highlight changed lines
	local ns = vim.api.nvim_create_namespace("lastCommittedChange")
	local changeEnd = firstChange.start + firstChange.length
	vim.highlight.range(0, ns, opts.highlightGroup, { firstChange.start, 0 }, { changeEnd, -1 })
	vim.defer_fn(
		function() vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) end,
		opts.highlightDurationMs
	)
end

--------------------------------------------------------------------------------
return M
