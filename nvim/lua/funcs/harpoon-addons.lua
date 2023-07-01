local fn = vim.fn
local u = require("config.utils")
local expand = vim.fn.expand

--------------------------------------------------------------------------------
local M = {}

---of all the marked files, gets the next one in order of last change time
---(ctime), similar to the grapling hook plugin for Obsidian
---this is essentially an alternative to `require("harpoon.ui").nav_next()`,
---only that the order of cycling is not determined by the list, but by the
---mtime order
function M.harpoonNextCtimeFile()
	-- get project
	local pwd = vim.loop.cwd() or ""
	local jsonPath = fn.stdpath("data") .. "/harpoon.json"
	local json = u.readFile(jsonPath)
	if not json then return end
	local data = vim.json.decode(json)
	if not data then return end
	local project = data.projects[pwd]
	if not project or #project.mark.marks == 0 then return end

	-- sort by atime
	local marksCtime = {}
	for _, file in pairs(project.mark.marks) do
		local absPath = pwd .. "/" .. file.filename
		local atime = vim.loop.fs_stat(absPath).atime.sec
		table.insert(marksCtime, { atime = atime, path = absPath })
	end
	table.sort(marksCtime, function(a, b) return a.atime > b.atime end)

	-- return next file
	local currentFile = expand("%:p")
	local fileFound = false
	for _, file in pairs(marksCtime) do
		if fileFound then return file.path end
		fileFound = currentFile == file.path
	end
	-- if at last marked file or if current file is not marked in harpoon, return
	-- the last accessed file instead
	return marksCtime[1].path
end

--------------------------------------------------------------------------------

---returns a harpoon icon if the current file is marked in Harpoon. Does not
---`require` Harpoon itself (allowing harpoon to still be lazy-loaded)
local function updateHarpoonIndicator()
	vim.b.harpoonMark = "" -- empty by default
	local harpoonJsonPath = fn.stdpath("data") .. "/harpoon.json"
	local fileExists = fn.filereadable(harpoonJsonPath) ~= 0
	if not fileExists then return end
	local harpoonJson = u.readFile(harpoonJsonPath)
	if not harpoonJson then return end

	local harpoonData = vim.json.decode(harpoonJson)
	local pwd = vim.loop.cwd()
	if not pwd or not harpoonData then return end
	local currentProject = harpoonData.projects[pwd]
	if not currentProject then return end
	local markedFiles = currentProject.mark.marks
	local currentFile = fn.expand("%:p")

	for _, file in pairs(markedFiles) do
		local absPath = pwd .. "/" .. file.filename
		if absPath == currentFile then vim.b.harpoonMark = "󰛢" end
	end
end

function M.harpoonStatusline() return vim.b.harpoonMark or "" end

-- so the harpoon state is only checked once on buffer enter and not every second
-- also, the command is called on marking a new file
vim.api.nvim_create_autocmd({ "BufReadPost", "UiEnter" }, {
	pattern = "*",
	callback = updateHarpoonIndicator,
})

--------------------------------------------------------------------------------
return M
