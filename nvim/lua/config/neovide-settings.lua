-- GUARD
if not vim.g.neovide then return end
--------------------------------------------------------------------------------
local g = vim.g

local u = require("config.utils")
local keymap = require("config.utils").uniqueKeymap

--------------------------------------------------------------------------------
-- DOCS https://neovide.dev/configuration.html

-- SIZE & FONT

local host = vim.fn.hostname()
local isAtOffice = (host:find("mini") or host:find("eduroam") or host:find("fak1")) ~= nil
local fontSize
if host:find("Mother") then
	fontSize = 23
	g.neovide_padding_top = 0
elseif isAtOffice then
	fontSize = 26
	g.neovide_padding_top = 0
else
	fontSize = 24.5
	g.neovide_padding_top = 13
end
g.neovide_padding_left = 5

vim.opt.guifont = {
	vim.env.CODE_FONT .. ":h" .. fontSize,
	"Symbols Nerd Font Mono",
} 

local function setNeovideScaleFactor(delta)
	g.neovide_scale_factor = g.neovide_scale_factor + delta
	u.notify("", "Scale Factor: " .. g.neovide_scale_factor)
end

keymap({ "n", "x", "i" }, "<D-+>", function() setNeovideScaleFactor(0.01) end)
keymap({ "n", "x", "i" }, "<D-->", function() setNeovideScaleFactor(-0.01) end)

--------------------------------------------------------------------------------

-- Behavior
g.neovide_remember_window_size = true
g.neovide_input_use_logo = true -- enable `cmd` key on macOS
g.neovide_input_macos_alt_is_meta = false -- false, so {@~ etc can be used
g.neovide_hide_mouse_when_typing = true

-- Appearance
g.neovide_transparency = 0.91
g.neovide_underline_stroke_scale = 1.1
g.neovide_refresh_rate = host:find("Mother") and 30 or 50

-- These have no effect with multi-grid turned off, and multi-grid has problems
-- with satellite.nvim currently.
-- g.neovide_scroll_animation_length = 0.03 -- amount of smooth scrolling
-- g.neovide_floating_shadow = true
-- g.neovide_floating_z_height = 20 -- amount of shadow

--------------------------------------------------------------------------------
-- CURSOR
vim.opt.guicursor = {
	"i-ci-c:ver25", -- INFO with noice.nvim, the guicursor cannot be styled in the cmdline https://github.com/folke/noice.nvim/issues/552
	"n-sm:block",
	"r-cr-o-v:hor10",
	"a:blinkwait200-blinkoff350-blinkon550",
}

g.neovide_cursor_animation_length = 0.01
g.neovide_cursor_trail_size = 0.9
g.neovide_cursor_unfocused_outline_width = 0.1
g.neovide_cursor_vfx_mode = "railgun" -- railgun|torpedo|pixiedust|sonicboom|ripple|wireframe

g.neovide_cursor_animate_in_insert_mode = true
g.neovide_cursor_animate_command_line = true

-- only railgun, torpedo, and pixiedust
g.neovide_cursor_vfx_particle_lifetime = 0.8
g.neovide_cursor_vfx_particle_density = 20.0
g.neovide_cursor_vfx_particle_speed = 40.0

-- only railgun
g.neovide_cursor_vfx_particle_phase = 1.3
g.neovide_cursor_vfx_particle_curl = 1.3
