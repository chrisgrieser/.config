require("utils")
--------------------------------------------------------------------------------

-- general
cmd[[colorscheme tokyonight-moon]]

--------------------------------------------------------------------------------

keymap({"n", "v", "i"}, "<D-w>", ":w<CR>:bd<CR>") -- cmd+w
keymap({"n", "v", "i"}, "<D-q>", ":wall!<CR>:quitall!<CR>") -- cmd+q

keymap({"n", "v"}, "<M-l>", "@") -- needed when alt is turned into meta key
keymap({"n", "v"}, "<M-9>", "}")
keymap({"n", "v"}, "<M-8>", "{")

keymap({"n", "v"}, "<D-z>", ":undo<CR>") -- cmd+z
keymap({"n", "v"}, "<D-Z>", ":redo<CR>") -- cmd+shift+z
keymap({"n", "v"}, "<D-s>", ":write!<CR>") -- cmd+s
keymap("i", "<D-s>", "<Esc>:write!<CR>a")
keymap("i", "<D-z>", "<Esc>:undo<CR>a")
keymap("i", "<D-Z>", "<Esc>:redo<CR>a")
keymap("n", "<D-a>", "ggvG") -- cmd+a
keymap("i", "<D-a>", "<Esc>ggvG")
keymap("v", "<D-a>", "ggG")
keymap({"n", "v"}, "<D-l>", ":!open %:h <CR><CR>") -- show file in default GUI file explorer
cmd[[let g:VM_maps['Find Under'] = '<D-j>']] -- cmd+j for jumping selection

-- cut copy paste
keymap({"n", "v"}, "<D-v>", "p")
keymap("i", "<D-v>", "<C-r>*")
keymap("n", "<D-c>", "yy") -- no selection = line
keymap("v", "<D-c>", "y")
keymap("i", "<D-v>", "<Esc>pa")
keymap("n", "<D-x>", "dd") -- no selection = line
keymap("v", "<D-x>", "d")

-- font resizing font size
-- https://neovide.dev/faq.html#how-can-i-dynamically-change-the-font-size-at-runtime
g.gui_font_default_size = 25
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

-- NEOVIDE
-- https://neovide.dev/configuration.html

g.neovide_cursor_animation_length = 0.015
g.neovide_cursor_trail_size = 0.9
g.neovide_scroll_animation_length = 0.4
g.neovide_transparency = 0.96
g.neovide_floating_blur_amount_x = 5.0
g.neovide_floating_blur_amount_y = 5.0
g.neovide_cursor_unfocused_outline_width = 0.3

g.neovide_cursor_vfx_mode = "railgun"
g.neovide_cursor_vfx_particle_lifetime=1.3
g.neovide_cursor_vfx_particle_density=17.0
g.neovide_cursor_vfx_particle_speed=17.0
g.neovide_cursor_vfx_particle_phase=1.3 -- only railgun
g.neovide_cursor_vfx_particle_curl=1.3 -- only railgun

g.neovide_confirm_quit = false
g.neovide_input_use_logo = true -- logo = `cmd` (on macOS)
g.neovide_hide_mouse_when_typing = true
g.neovide_remember_window_size = true
g.neovide_input_macos_alt_is_meta = false -- makes `opt` usable on mac

