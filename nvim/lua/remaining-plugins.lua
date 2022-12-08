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
-- https://github.com/rktjmp/fwatch.nvim/blob/main/lua/fwatch.lua#L16
-- https://neovim.io/doc/user/lua.html#lua-loop
local w = vim.loop.new_fs_event()
local function on_change(err)
	if err then
		print(err)
		return
	end
	print("file has changed")
	if w then w:stop() end
end

local watchedFile = "/tmp/nvim"
if w then
	w:start(watchedFile, {}, on_change)
end
