require("utils")
require("appearance")
--------------------------------------------------------------------------------

-- font size dependent on device
if fn.hostname():find("iMac") then
	g.neovide_scale_factor = 1
elseif fn.hostname():find("mini") then
	g.neovide_scale_factor = 0.9
elseif fn.hostname():find("Mother") then
	g.neovide_scale_factor = 0.9
end

opt.guifont = "JetBrainsMonoNL Nerd Font:h26"
opt.guicursor = "n-sm:block," ..
	"i-ci-c-ve:ver25," ..
	"r-cr-o-v:hor10," ..
	"a:blinkwait300-blinkoff500-blinkon700"

--------------------------------------------------------------------------------
-- CMD-Keybindings
keymap({"n", "x", "i"}, "<D-w>", function() -- cmd+w
	if fn.tabpagenr("$") > 1 then
		cmd [[tabclose]]
	elseif fn.winnr("$") > 1 then
		cmd [[close]]
		print("beep")
	elseif fn.bufnr("$") > 1 then ---@diagnostic disable-line: param-type-mismatch
		cmd [[bdelete]]
	end
	cmd [[nohl]]
end)
keymap({"n", "x", "i"}, "<D-S-w>", function() cmd [[only]] end) -- cmd+shift+w
keymap({"n", "x", "i"}, "<D-z>", function() cmd [[undo]] end) -- cmd+z
keymap({"n", "x", "i"}, "<D-S-z>", function() cmd [[redo]] end) -- cmd+shift+z
keymap({"n", "x", "i"}, "<D-s>", function() cmd [[write!]] end) -- cmd+s
keymap("n", "<D-a>", "ggVG") -- cmd+a
keymap("i", "<D-a>", "<Esc>ggVG")
keymap("x", "<D-a>", "ggG")

keymap({"n", "x"}, "<D-l>", ":!open %:h <CR><CR>") -- show file in default GUI file explorer
keymap({"n", "x"}, "<D-1>", ":Lexplore<CR><CR>") -- file tree (netrw)
keymap({"n", "x"}, "<D-0>", ":messages<CR>")
keymap({"n", "x"}, "<D-9>", ":Notification<CR>")

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
keymap("i", "<D-v>", "<C-r><C-o>+")

-- cmd+e: inline code
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>") -- no selection = word under cursor
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>")
keymap("i", "<D-e>", "``<Left>")

-- cmd+t: Template ${string}
keymap("n", "<D-t>", "bi${<Esc>ea}<Esc>b") -- no selection = word under cursor
keymap("x", "<D-t>", "<Esc>${<i}<Esc>${>la}<Esc>b")
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
g.neovide_scroll_animation_length = 0.5
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
