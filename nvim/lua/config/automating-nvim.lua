require("config.utils")
-- Runs arbitrary lua commands when written to the watchedFile

-- INFO
-- https://neovim.io/doc/user/luvref.html#luv-fs-event-handle
-- https://github.com/rktjmp/fwatch.nvim/blob/main/lua/fwatch.lua#L16
-- https://neovim.io/doc/user/lua.html#lua-loop
--------------------------------------------------------------------------------

local watchedFile = "/tmp/nvim-automation"
local w = vim.loop.new_fs_event()

---reads file from disk, removing trailing newlines
---@param path string
---@return string filecontent
local function readFile(path)
	local file = io.open(path, "r")
	if not file then return "" end
	local content = file:read("*a")
	file:close()
	return content:gsub("[\n\r]$", "")
end

local function executeExtCommand()
	local commandStr = readFile(watchedFile)
	local command = load(commandStr) -- `load()` is the lua equivalent of `eval()`
	if command then command() end

	if w then
		w:stop() -- prevent multiple executions
		StartWatching()
	end
end

function StartWatching()
	if w then w:start(watchedFile, {}, vim.schedule_wrap(executeExtCommand)) end
end

StartWatching()
