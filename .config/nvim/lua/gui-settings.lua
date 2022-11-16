require("utils")
require("appearance")
--------------------------------------------------------------------------------

-- font size dependent on device
if fn.hostname():find("iMac") then
	g.neovide_scale_factor = 1
elseif fn.hostname():find("mini") then
	g.neovide_scale_factor = 0.95
elseif fn.hostname():find("Mother") then
	g.neovide_scale_factor = 0.95
end

opt.guifont = "JetBrainsMonoNL Nerd Font:h26.9"
opt.guicursor = "n-sm:block," ..
	"i-ci-c-ve:ver25," ..
	"r-cr-o-v:hor10," ..
	"a:blinkwait300-blinkoff500-blinkon700"

--------------------------------------------------------------------------------
-- CMD-Keybindings
keymap({"n", "x"}, "<D-w>", ":close<CR>") -- cmd+w
keymap("i", "<D-w>", "<Esc>:close<CR>")

keymap({"n", "x", "i"}, "<D-n>", qol.createNewFile)

keymap({"n", "x"}, "<D-z>", "u") -- cmd+z
keymap({"n", "x"}, "<D-Z>", "<C-R>") -- cmd+shift+z
keymap("i", "<D-z>", "<C-o>u")
keymap("i", "<D-Z>", "<C-o><C-r>")
keymap({"n", "x"}, "<D-s>", ":write!<CR>") -- cmd+s
keymap("i", "<D-s>", "<Esc>:write!<CR>a")
keymap("n", "<D-a>", "ggVG") -- cmd+a
keymap("i", "<D-a>", "<Esc>ggVG")
keymap("x", "<D-a>", "ggG")

keymap("", "<D-BS>", qol.trashFile)
keymap({"n", "x"}, "<D-l>", ":!open %:h <CR><CR>") -- show file in default GUI file explorer
keymap({"n", "x", "i"}, "<D-1>", ":Lexplore<CR><CR>") -- file tree (netrw)
keymap({"n", "x", "i"}, "<D-0>", ":messages<CR>")
keymap({"n", "x", "i"}, "<D-9>", ":Notification<CR>")

-- Multi-Cursor https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
g.VM_maps = {
	["Find Under"] = "<D-j>", -- cmd+j
	["Visual Add"] = "<D-j>",
	["Select Cursor Up"] = "<M-Up>", -- opt+up
	["Select Cursor Down"] = "<M-Down>",
}

-- cut, copy & paste
keymap("n", "<D-c>", "yy") -- no selection = line
keymap("x", "<D-c>", "y")
keymap("n", "<D-x>", "dd") -- no selection = line
keymap("x", "<D-x>", "d")
keymap({"n", "x"}, "<D-v>", "p")
keymap("c", "<D-v>", "<C-r>+")
keymap("i", "<D-v>", qol.insertModePasteFix)

-- cmd+e: inline code
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>") -- no selection = word under cursor
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>")
keymap("i", "<D-e>", "``<Left>")

-- cmd+t: Template string
keymap("n", "<D-t>", "bi${<Esc>ea}<Esc>") -- no selection = word under cursor
keymap("x", "<D-t>", "<Esc>${<i}<Esc>${>la}<Esc>")
keymap("i", "<D-t>", "${}<Left>")

local delta = 1.1
keymap({"n", "x", "i"}, "<D-+>", function()
	g.neovide_scale_factor = g.neovide_scale_factor * delta
end)
keymap({"n", "x", "i"}, "<D-->", function()
	g.neovide_scale_factor = g.neovide_scale_factor / delta
end)

--------------------------------------------------------------------------------

-- NEOVIDE
-- https://neovide.dev/configuration.html

g.neovide_cursor_animation_length = 0.01
g.neovide_cursor_trail_size = 0.9
g.neovide_scroll_animation_length = 0.01
g.neovide_floating_blur_amount_x = 5.0
g.neovide_floating_blur_amount_y = 5.0
g.neovide_cursor_unfocused_outline_width = 0.1
g.neovide_underline_automatic_scaling = true -- slightly unstable according to docs

g.neovide_cursor_vfx_mode = "railgun"
g.neovide_cursor_vfx_particle_lifetime = 1
g.neovide_cursor_vfx_particle_density = 20.0
g.neovide_cursor_vfx_particle_speed = 25.0
g.neovide_cursor_vfx_particle_phase = 1.3 -- only railgun
g.neovide_cursor_vfx_particle_curl = 1.3 -- only railgun

g.neovide_confirm_quit = false
g.neovide_input_use_logo = true -- logo = `cmd` (on macOS)
g.neovide_hide_mouse_when_typing = true
g.neovide_remember_window_size = true

g.neovide_input_macos_alt_is_meta = true -- makes `opt` usable on macOS
-- needed when alt is turned into meta key
keymap({"n", "x"}, "<M-l>", "@")
keymap("i", "<M-.>", "…")
keymap("i", "<M-->", "–")
