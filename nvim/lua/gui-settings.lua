require("utils")
-- https://neovide.dev/configuration.html
--------------------------------------------------------------------------------

-- font size dependent on device
local device = fn.hostname()
if device:find("iMac") then
	g.neovide_scale_factor = 1
elseif device:find("eduroam") or device:find("mini") then
	g.neovide_scale_factor = 0.92
elseif device:find("Mother") then
	g.neovide_scale_factor = 0.9
end

opt.guifont = "JetBrainsMonoNL Nerd Font:h26"
opt.guicursor = "n-sm:block," ..
	"i-ci-c-ve:ver25," ..
	"r-cr-o-v:hor10," ..
	"a:blinkwait200-blinkoff500-blinkon700"

--------------------------------------------------------------------------------

local delta = 1.1
keymap({"n", "x", "i"}, "<D-+>", function()
	g.neovide_scale_factor = g.neovide_scale_factor * delta
end)
keymap({"n", "x", "i"}, "<D-->", function()
	g.neovide_scale_factor = g.neovide_scale_factor / delta
end)

-- Behavior
g.neovide_confirm_quit = false
g.neovide_input_use_logo = true -- logo = `cmd` (on macOS)
g.neovide_hide_mouse_when_typing = true
g.neovide_remember_window_size = true
g.neovide_input_macos_alt_is_meta = true -- makes `opt` usable on macOS
-- keymap("i", "<M-.>", "…") -- needed when alt is turned into meta key
-- keymap("i", "<M-->", "–")

-- Window Appearance
g.neovide_floating_blur_amount_x = 5.0
g.neovide_floating_blur_amount_y = 5.0
g.neovide_scroll_animation_length = 0.5
g.neovide_underline_automatic_scaling = true -- slightly unstable according to docs
-- INFO: Transparency set in theme-settings.lua, since varying with dark/light mode

-- cursor
g.neovide_cursor_animation_length = 0.01
g.neovide_cursor_trail_size = 0.9
g.neovide_cursor_unfocused_outline_width = 0.1

g.neovide_cursor_vfx_mode = "railgun"
g.neovide_cursor_vfx_particle_lifetime = 1
g.neovide_cursor_vfx_particle_density = 20.0
g.neovide_cursor_vfx_particle_speed = 25.0
g.neovide_cursor_vfx_particle_phase = 1.3 -- only railgun
g.neovide_cursor_vfx_particle_curl = 1.3 -- only railgun
