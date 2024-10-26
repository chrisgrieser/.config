local M = {}
--------------------------------------------------------------------------------

function M.gotoMostChangedFile()
	local gitResponse = vim.system({ "git", "diff", "--numstat", "." }):wait()
	if gitResponse.code ~= 0 then
		vim.notify("Not in git repo.", vim.log.levels.WARN)
		return
	end
	local numstatLines = vim.split(gitResponse.stdout, "\n", { trimempty = true })

	-- GUARD
	if #numstatLines == 0 then
		vim.notify("No changes found.")
		return
	end

	-- parameters
	local currentFile = vim.api.nvim_buf_get_name(0)

	-- Changed Files, sorted by most changes
	local targetFile
	local mostChanges = 0
	vim.iter(numstatLines):each(function(line)
		local added, deleted, file = line:match("(%d+)%s+(%d+)%s+(.+)")
		if not (added and deleted and file) then return end -- exclude changed binaries

		local changes = tonumber(added) + tonumber(deleted)
		if changes > mostChanges then
			mostChanges = changes
			targetFile = file
		end
	end

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
end

--------------------------------------------------------------------------------
return M
