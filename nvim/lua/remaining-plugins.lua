require("utils")
--------------------------------------------------------------------------------

-- netrw
g.netrw_browse_split = 0
g.netrw_list_hide = ".*\\.DS_Store$,^./$,^../$" -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner
g.netrw_liststyle = 3 -- tree style as default
g.netrw_winsize = 30 -- width
g.netrw_localcopydircmd = "cp -r" -- so copy work with directories
cmd [[highlight! def link netrwTreeBar IndentBlankLineChar]]

--------------------------------------------------------------------------------
-- Mundo
g.mundo_width = 30
g.mundo_preview_height = 15
g.mundo_preview_bottom = 0
g.mundo_auto_preview = 1
g.mundo_right = 1 -- right side, not left

augroup("MundoConfig", {})
autocmd("FileType", {
	group = "MundoConfig",
	pattern = "Mundo",
	callback = function()
		keymap("n", "-", "/", {remap = true, buffer = true})
	end
})

--------------------------------------------------------------------------------
-- https://neovim.io/doc/user/luvref.html#luv-fs-event-handle


local w = vim.loop.new_fs_event()
local function on_change(err, fname, status)
	-- Do work...
	vim.api.nvim_command("checktime")
	-- Debounce: stop/start.
	w:stop()
	watch_file(fname)
end

local function watch_file(fname)
	local fullpath = vim.api.nvim_call_function("fnamemodify", {fname, ":p"})
	w:start(fullpath, {}, vim.schedule_wrap(function(...)
		on_change(...)
	end))
end
