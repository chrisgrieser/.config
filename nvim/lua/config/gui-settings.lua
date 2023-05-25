local g = vim.g
local fn = vim.fn
local keymap = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd
--------------------------------------------------------------------------------

-- See hammerspoons `app-hider.lua`
autocmd("VimEnter", {
	callback = function()
		-- HACK hide other apps for the GUI transparency, done this way since
		-- hammerspoons app triggers do not correctly pick up neovide
		fn.system("open -g 'hammerspoon://hide-other-than-neovide'")

		-- HACK to fix neovide sometimes not enlarging the window
		fn.system("open -g 'hammerspoon://enlarge-neovide-window'")
	end,
})

--------------------------------------------------------------------------------
-- SIZE & FONT
-- https://www.programmingfonts.org/#oxygen
vim.opt.guifont = "JetBrainsMonoNL Nerd Font:h25.2" 

-- INFO: Transparency set in theme-config.lua
if fn.hostname():find("Mother") then
	g.neovide_scale_factor = 0.94
	g.neovide_refresh_rate = 40
elseif fn.hostname():find("mini") or fn.hostname():find("eduroam") then
	g.neovide_scale_factor = 1.06
	g.neovide_refresh_rate = 60
elseif fn.hostname():find("iMac") then
	g.neovide_scale_factor = 1
	g.neovide_refresh_rate = 70
end

local delta = 1.05
keymap({ "n", "x", "i" }, "<D-+>", function() g.neovide_scale_factor = g.neovide_scale_factor * delta end)
keymap({ "n", "x", "i" }, "<D-->", function() g.neovide_scale_factor = g.neovide_scale_factor / delta end)

--------------------------------------------------------------------------------

-- Behavior
g.neovide_confirm_quit = false
g.neovide_hide_mouse_when_typing = true
g.neovide_remember_window_size = false -- done via --geometry in `neovide` call, since more reliable

-- keymaps
g.neovide_input_use_logo = true -- enable `cmd` key on macOS
g.neovide_input_macos_alt_is_meta = false -- false, so {@~ etc can be used

-- Window Appearance
g.neovide_underline_automatic_scaling = true -- slightly unstable according to docs
g.neovide_scroll_animation_length = 1

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

-- only railgun, torpedo, and pixiedust
g.neovide_cursor_vfx_particle_lifetime = 0.5
g.neovide_cursor_vfx_particle_density = 20.0
g.neovide_cursor_vfx_particle_speed = 40.0

-- only railgun
g.neovide_cursor_vfx_particle_phase = 1.3
g.neovide_cursor_vfx_particle_curl = 1.3 
