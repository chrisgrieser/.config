require("utils")
-- https://neovide.dev/configuration.html
--------------------------------------------------------------------------------

-- Appearance
cmd[[colorscheme onedark]]
opt.guifont = "Input,JetBrainsMonoNL Nerd Font:h26"
opt.guicursor = opt.guicursor:sub("ver25", "ver15")
g.neovide_cursor_animation_length = 0.04
g.neovide_cursor_trail_size = 0.7
g.neovide_scroll_animation_length = 0.1
g.neovide_transparency = 0.95

-- Functional
g.neovide_hide_mouse_when_typing = true
g.neovide_confirm_quit = false
g.neovide_remember_window_size = true
opt.title = true -- title (for Window Managers and espanso)

-- Keybindings
g.neovide_input_use_logo = true -- logo = `cmd` (on macOS)
g.neovide_input_macos_alt_is_meta = false -- makes `opt` usable on mac
keymap({"n", "v"}, "<M-l>", "@") -- needed when alt is turned into meta key
keymap({"n", "v"}, "<M-9>", "}")
keymap({"n", "v"}, "<M-8>", "{")

keymap("n", "<D-s>", ":write!<CR>") -- cmd+s
keymap("n", "<D-a>", "ggvG") -- cmd+a & cmd+c
keymap("n", "<D-w>", ":w<CR>:bd<CR>") -- cmd+w
keymap("n", "<D-l>", ":!open %:h <CR><CR>") -- show file in default GUI file explorer

keymap("n", "<D-v>", "p")
keymap("v", "<D-v>", "P") -- capital P to not switch register content
keymap("i", "<D-v>", ":put<CR>")

keymap("n", "<D-c>", "yy") -- no selection = line
keymap("v", "<D-c>", "y")

keymap("n", "<D-x>", "dd") -- no selection = line
keymap("v", "<D-x>", "d")


-- font resizing
vim.g.gui_font_default_size = 12
vim.g.gui_font_size = vim.g.gui_font_default_size
vim.g.gui_font_face = "Fira Code Retina"

RefreshGuiFont = function()
  vim.opt.guifont = string.format("%s:h%s",vim.g.gui_font_face, vim.g.gui_font_size)
end

ResizeGuiFont = function(delta)
  vim.g.gui_font_size = vim.g.gui_font_size + delta
  RefreshGuiFont()
end

ResetGuiFont = function()
  vim.g.gui_font_size = vim.g.gui_font_default_size
  RefreshGuiFont()
end

-- Call function on startup to set default value
ResetGuiFont()

-- Keymaps

local opts = { noremap = true, silent = true }

vim.keymap.set({'n', 'i'}, "<C-+>", function() ResizeGuiFont(1)  end, opts)
vim.keymap.set({'n', 'i'}, "<C-->", function() ResizeGuiFont(-1) end, opts)



