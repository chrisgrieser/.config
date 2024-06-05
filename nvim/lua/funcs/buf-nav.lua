local M = {}
local api = vim.api
--------------------------------------------------------------------------------

local pluginName = "Buf Nav"

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = pluginName })
end

---@nodiscard
---@param path string
local function fileExists(path) return vim.uv.fs_stat(path) ~= nil end

--------------------------------------------------------------------------------

---@param altBufnr integer
---@return boolean
local function hasAltFile(altBufnr)
	if altBufnr < 0 then return false end
	local valid = api.nvim_buf_is_valid(altBufnr)
	local nonSpecial = api.nvim_get_option_value("buftype", { buf = altBufnr }) == ""
	local moreThanOneBuffer = #(vim.fn.getbufinfo { buflisted = 1 }) > 1
	local currentBufNotAlt = vim.api.nvim_get_current_buf() ~= altBufnr -- fixes weird rare vim bug
	local altFileExists = fileExists(api.nvim_buf_get_name(altBufnr))

	return valid and nonSpecial and moreThanOneBuffer and currentBufNotAlt and altFileExists
end

---get the alternate oldfile, accounting for non-existing files
---@nodiscard
---@return string|nil path of oldfile, nil if none exists in all oldfiles
local function altOldfile()
	local curPath = api.nvim_buf_get_name(0)
	for _, path in ipairs(vim.v.oldfiles) do
		if fileExists(path) and not path:find("/COMMIT_EDITMSG$") and path ~= curPath then
			return path
		end
	end
	return nil
end

---shows name & icon of alt buffer. If there is none, show first alt-oldfile.
---@param maxDisplayLen? number
---@return string
function M.altFileStatus(maxDisplayLen)
	-- some statusline plugins convert their input into strings
	if type(maxDisplayLen) ~= "number" then maxDisplayLen = 25 end

	local altBufNr = vim.fn.bufnr("#")
	local altOld = altOldfile()
	local name, icon

	if hasAltFile(altBufNr) then
		local altPath = api.nvim_buf_get_name(altBufNr)
		local altFile = vim.fs.basename(altPath)
		name = altFile ~= "" and altFile or "[No Name]"
		-- icon
		local ext = altFile:match("%w+$")
		local altBufFt = api.nvim_get_option_value("filetype", { buf = altBufNr })
		local ok, devicons = pcall(require, "nvim-web-devicons")
		icon = ok and devicons.get_icon(altFile, ext or altBufFt) or "#"

		-- name: consider if alt and current file have same basename
		local curFile = vim.fs.basename(api.nvim_buf_get_name(0))
		local currentAndAltWithSameBasename = curFile == altFile
		if currentAndAltWithSameBasename then
			local altParent = vim.fs.basename(vim.fs.dirname(altPath))
			name = altParent .. "/" .. altFile
		end
	elseif altOld then
		icon = "󰋚"
		name = vim.fs.basename(altOld)
	else
		return "–––"
	end

	-- truncate
	local nameNoExt = name:gsub("%.%w+$", "")
	if #nameNoExt > maxDisplayLen then
		local ext = name:match("%.%w+$")
		name = nameNoExt:sub(1, maxDisplayLen) .. "…" .. ext
	end
	return icon .. " " .. name
end

---switch to alternate buffer/oldfile (in that priority)
function M.gotoAltBuffer()
	if vim.bo.buftype ~= "" then return end -- deactivate if in a special buffer

	if hasAltFile(vim.fn.bufnr("#")) then
		vim.cmd.buffer("#")
		return
	end
	local altOld = altOldfile()
	if altOld then
		vim.cmd.edit(altOld)
		return
	end
	notify("No Alt-File or Oldfile available.", "warn")
end

--------------------------------------------------------------------------------

---@class (exact) bufNavState
---@field bufsByLastAccess table[]
---@field bufNavNotify { id: number }
---@field timeoutTimer table
local state = {}

local config = {
	timeout = 4000,
	maxBufAgeMins = 15,
}

---@param dir "next"|"prev"
function M.bufferByLastUsed(dir)
	-- GET BUFFERS SORTED BY LAST ACCESS
	-- timeout required, as switching to buffer always makes it the last accessed one
	if state.timeoutTimer then state.timeoutTimer:stop() end
	state.timeoutTimer = vim.defer_fn(function() state.bufsByLastAccess = nil end, config.timeout)

	if not state.bufsByLastAccess then
		---@type {name: string, lastused: number}[]
		state.bufsByLastAccess = vim.iter(vim.fn.getbufinfo { buflisted = 1 })
			:filter(function(buf) return (os.time() - buf.lastused) < config.maxBufAgeMins * 60 end)
			:totable()
		table.sort(state.bufsByLastAccess, function(a, b) return a.lastused > b.lastused end)
		state.bufsByLastAccess = vim.list_slice(state.bufsByLastAccess, 1, config.maxBufs)
	end
	if #state.bufsByLastAccess < 2 then
		state.bufsByLastAccess = nil
		notify("Only one buffer open.", "warn")
		return
	end

	-- DETERMINE NEXT BUFFER
	local currentBuf = vim.api.nvim_buf_get_name(0)
	local currentBufIdx
	for i = 1, #state.bufsByLastAccess do
		if state.bufsByLastAccess[i].name == currentBuf then
			currentBufIdx = i
			break
		end
	end
	local nextBufIdx
	if dir == "prev" then
		nextBufIdx = currentBufIdx - 1
		if nextBufIdx < 1 then nextBufIdx = #state.bufsByLastAccess end
	else
		nextBufIdx = currentBufIdx + 1
		if nextBufIdx > #state.bufsByLastAccess then nextBufIdx = 1 end
	end
	local nextBufName = state.bufsByLastAccess[nextBufIdx].name
	vim.cmd.edit(nextBufName)

	-----------------------------------------------------------------------------
	-- DISPLAY BUFFER-LIST

	local notifyInstalled, _ = pcall(require, "notify")
	if not notifyInstalled then return end

	local curBufIcon = ""
	local bufsDisplay = vim.iter(state.bufsByLastAccess)
		:map(function(buf)
			local prefix = nextBufName == buf.name and curBufIcon or "•"
			local minsAgo = math.ceil((os.time() - buf.lastused) / 60)
			local minStr = minsAgo == 0 and "" or tostring(minsAgo)
			return ("%s %s (%s mins)"):format(prefix, vim.fs.basename(buf.name), minStr)
		end)
		:rev()
		:totable()
	table.insert(bufsDisplay, 1, table.remove(bufsDisplay)) -- move current buffer to top

	---@diagnostic disable-next-line: assign-type-mismatch
	state.bufNavNotify = vim.notify(table.concat(bufsDisplay, "\n"), vim.log.levels.INFO, {
		timeout = config.timeout,
		title = pluginName,
		animate = false,
		stages = "no_animation",
		hide_from_history = true,
		replace = state.bufNavNotify and state.bufNavNotify.id,
		on_open = function(win)
			local bufnr = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_call(bufnr, function() vim.fn.matchadd("Title", curBufIcon .. ".*") end)
		end,
	})
end

--------------------------------------------------------------------------------
return M
