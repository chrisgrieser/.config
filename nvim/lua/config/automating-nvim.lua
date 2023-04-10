require("config.utils")
-- Runs arbitrary lua commands when written to the watchedFile

-- INFO
-- https://neovim.io/doc/user/luvref.html#luv-fs-event-handle
-- https://github.com/rktjmp/fwatch.nvim/blob/main/lua/fwatch.lua#L16
-- https://neovim.io/doc/user/lua.html#lua-loop
--------------------------------------------------------------------------------

local watchedFile = "/tmp/nvim-automation"
local w = vim.loop.new_fs_event()

-- ensure file existence for watcher to work reliably
-- INFO needs to come before watcher is started
if not fn.filereadable(watchedFile) then
	local file, err = io.open(watchedFile, "w")
	if not file then
		vim.notify("Could not append: " .. err, vim.log.levels.ERROR)
		return false
	end
	file:write("foo")
	file:close()
end

--------------------------------------------------------------------------------

local function executeExtCommand()
	local commandStr = ReadFile(watchedFile):gsub("[\n\r]$", "")
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
