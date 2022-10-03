require("utils")
-- https://neovide.dev/configuration.html
--------------------------------------------------------------------------------

cmd[[colorscheme dracula]]
opt.title = true -- title (for Window Managers and espanso)

keymap({"n", "v", "i"}, "<D-w>", ":w<CR>:bd<CR>") -- cmd+w
keymap({"n", "v", "i"}, "<D-q>", ":wall!<CR>:quitall!<CR>") -- cmd+q

keymap({"n", "v"}, "<M-l>", "@") -- needed when alt is turned into meta key
keymap({"n", "v"}, "<M-9>", "}")
keymap({"n", "v"}, "<M-8>", "{")

keymap({"n", "v", "i"}, "<D-z>", ":undo<CR>") -- cmd+z
keymap({"n", "v", "i"}, "<D-Z>", ":redo<CR>") -- cmd+shift+z
keymap({"n", "v", "i"}, "<D-s>", ":write!<CR>") -- cmd+s
keymap("n", "<D-a>", "ggvG") -- cmd+a
keymap("i", "<D-a>", "<Esc>ggvG")
keymap("v", "<D-a>", "ggG")
keymap({"n", "v", "i"}, "<D-l>", ":!open %:h <CR><CR>") -- show file in default GUI file explorer
cmd[[let g:VM_maps['Find Under'] = '<D-j>']] -- cmd+j for jumping selection

keymap("n", "<D-v>", "p")
keymap("v", "<D-v>", "P") -- capital P to not switch register content
keymap("i", "<D-v>", ":put<CR>")

keymap("n", "<D-c>", "yy") -- no selection = line
keymap("v", "<D-c>", "y")

keymap("n", "<D-x>", "dd") -- no selection = line
keymap("v", "<D-x>", "d")


-- font resizing font size
-- https://neovide.dev/faq.html#how-can-i-dynamically-change-the-font-size-at-runtime
g.gui_font_default_size = 27
g.gui_font_face = "JetBrainsMonoNL Nerd Font"

g.gui_font_size = g.gui_font_default_size
RefreshGuiFont = function()
	opt.guifont = string.format("%s:h%s",g.gui_font_face, g.gui_font_size)
end
ResizeGuiFont = function(delta)
	g.gui_font_size = g.gui_font_size + delta
	RefreshGuiFont()
end
ResetGuiFont = function()
	g.gui_font_size = g.gui_font_default_size
	RefreshGuiFont()
end

ResetGuiFont() -- Call function on startup to set default value

-- Keymaps
keymap({'n','v','i'}, '<D-+>', function() ResizeGuiFont(1)  end, {silent = true})
keymap({'n','v','i'}, '<D-->', function() ResizeGuiFont(-1) end, {silent = true})

--------------------------------------------------------------------------------

-- Neovide 0.10.1 not working: https://github.com/neovide/neovide/issues/1582
--------------------------------------------------------------------------------

-- g.neovide_cursor_animation_length = 0.04
-- g.neovide_cursor_trail_size = 0.7
-- g.neovide_scroll_animation_length = 0.1
-- g.neovide_transparency = 0.95
-- g.neovide_hide_mouse_when_typing = true
-- g.neovide_confirm_quit = false
-- g.neovide_remember_window_size = true
-- g.neovide_input_use_logo = true -- logo = `cmd` (on macOS)
-- g.neovide_input_macos_alt_is_meta = false -- makes `opt` usable on mac
