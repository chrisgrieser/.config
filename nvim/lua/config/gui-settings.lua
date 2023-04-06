require("config.utils")
local g = vim.g
-- INFO https://neovide.dev/configuration.html
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
-- SIZE

vim.opt.guifont = "JetBrainsMonoNL Nerd Font:h25.2" -- https://www.programmingfonts.org/#oxygen

-- INFO: Transparency set in theme-config.lua
if Fn.hostname():find("Mother") then
	g.neovide_scale_factor = 0.93
	g.neovide_refresh_rate = 40
elseif Fn.hostname():find("eduroam") or Fn.hostname():find("iMac") then
	g.neovide_scale_factor = 1
	g.neovide_refresh_rate = 80
end

local delta = 1.05
Keymap({ "n", "x", "i" }, "<D-+>", function() g.neovide_scale_factor = g.neovide_scale_factor * delta end)
Keymap({ "n", "x", "i" }, "<D-->", function() g.neovide_scale_factor = g.neovide_scale_factor / delta end)

--------------------------------------------------------------------------------

-- Behavior
g.neovide_confirm_quit = false
g.neovide_hide_mouse_when_typing = true
g.neovide_remember_window_size = false -- done via --geometry in `neovide` call, since more reliable

-- Keymaps
g.neovide_input_use_logo = true -- enable `cmd` key on macOS
g.neovide_input_macos_alt_is_meta = true -- enable `opt` key on macOS
Keymap("i", "<M-.>", "…") -- helpers when `opt` is turned into meta key
Keymap("i", "<M-->", "–") -- en-dash
Keymap("i", "<M-7>", "|")

-- Window Appearance
g.neovide_underline_automatic_scaling = true -- slightly unstable according to docs
g.neovide_scroll_animation_length = 1 -- 

--------------------------------------------------------------------------------
-- CURSOR

vim.opt.guicursor = {
	"n-sm:block",
	"i-ci-c:ver25",
	"r-cr-o-v:hor10",
	"a:blinkwait200-blinkoff500-blinkon700",
}

g.neovide_cursor_animation_length = 0.01
g.neovide_cursor_trail_size = 0.9
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
