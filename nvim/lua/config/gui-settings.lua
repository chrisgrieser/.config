require("config.utils")
-- https://neovide.dev/configuration.html
--------------------------------------------------------------------------------

-- font size dependent on device
local device = fn.hostname()
if device:find("Mother") then
	g.neovide_scale_factor = 0.94
elseif device:find("eduroam") or device:find("iMac") then
	g.neovide_scale_factor = 1
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
g.neovide_hide_mouse_when_typing = true
g.neovide_remember_window_size = false -- done via --geometry in `neovide` call

-- Keymaps
g.neovide_input_use_logo = true -- logo = `cmd` (on macOS)
g.neovide_input_macos_alt_is_meta = true -- makes `opt` usable on macOS
keymap("i", "<M-.>", "…") -- needed when alt is turned into meta key
keymap("i", "<M-->", "–")

-- Window Appearance
g.neovide_underline_automatic_scaling = true -- slightly unstable according to docs
-- INFO: Transparency set in themes.lua, since varying with dark/light mode

-- cursor
g.neovide_cursor_animation_length = 0.003
g.neovide_cursor_trail_size = 0.5
g.neovide_cursor_unfocused_outline_width = 0.1

g.neovide_cursor_vfx_mode = "" -- railgun|torpedo|pixiedust|sonicboom|ripple|wireframe

local particleModes = {"railgun", "torpedo", "pixiedust"}
if vim.tbl_contains(particleModes, g.neovide_cursor_vfx_mode) then
	g.neovide_cursor_vfx_particle_lifetime = 0.4
	g.neovide_cursor_vfx_particle_density = 20.0
	g.neovide_cursor_vfx_particle_speed = 40.0
	if g.neovide_cursor_vfx_mode == "railgun" then
		g.neovide_cursor_vfx_particle_phase = 1.3 -- only railgun
		g.neovide_cursor_vfx_particle_curl = 1.3 -- only railgun
	end
end
