require("config.utils")
-- https://neovide.dev/configuration.html
local g = vim.g
--------------------------------------------------------------------------------

-- See hammerspoons `app-hider.lua`
Autocmd("VimEnter", {
	callback = function()
		-- hide other apps so the GUI transparency is visible.
		Fn.system("open -g 'hammerspoon://hide-other-than-neovide'")

		-- HACK to fix neovide sometimes not enlarging the window
		Fn.system("open -g 'hammerspoon://enlarge-neovide-window'")
	end,
})

--------------------------------------------------------------------------------

local delta = 1.1
Keymap({ "n", "x", "i" }, "<D-+>", function() g.neovide_scale_factor = g.neovide_scale_factor * delta end)
Keymap({ "n", "x", "i" }, "<D-->", function() g.neovide_scale_factor = g.neovide_scale_factor / delta end)

-- Behavior
g.neovide_confirm_quit = false
g.neovide_hide_mouse_when_typing = true
g.neovide_remember_window_size = false -- done via --geometry in `neovide` call

-- Keymaps
g.neovide_input_use_logo = true -- logo = `cmd` (on macOS)
g.neovide_input_macos_alt_is_meta = true -- makes `opt` usable (on macOS)
Keymap("i", "<M-.>", "…") -- needed when alt is turned into meta key
Keymap("i", "<M-->", "–") -- en-dash

-- Graphics (dependent on device)
-- INFO: Transparency set in theme-config.lua
if Fn.hostname():find("Mother") then
	g.neovide_scale_factor = 0.93
	g.neovide_refresh_rate = 45
elseif Fn.hostname():find("eduroam") or Fn.hostname():find("iMac") then
	g.neovide_scale_factor = 1
	g.neovide_refresh_rate = 80
end


-- Window Appearance
g.neovide_underline_automatic_scaling = true -- slightly unstable according to docs
g.neovide_scroll_animation_length = 0.1 -- seems to be not working

-- cursor
g.neovide_cursor_animation_length = 0.003
g.neovide_cursor_trail_size = 0.7
g.neovide_cursor_unfocused_outline_width = 0.1

g.neovide_cursor_vfx_mode = "railgun" -- railgun|torpedo|pixiedust|sonicboom|ripple|wireframe
if vim.tbl_contains({ "railgun", "torpedo", "pixiedust" }, g.neovide_cursor_vfx_mode) then
	g.neovide_cursor_vfx_particle_lifetime = 0.5
	g.neovide_cursor_vfx_particle_density = 20.0
	g.neovide_cursor_vfx_particle_speed = 40.0
	if g.neovide_cursor_vfx_mode == "railgun" then
		g.neovide_cursor_vfx_particle_phase = 1.3 
		g.neovide_cursor_vfx_particle_curl = 1.3 
	end
end
