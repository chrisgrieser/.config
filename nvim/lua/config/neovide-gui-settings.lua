-- DOCS https://neovide.dev/configuration.html
--------------------------------------------------------------------------------
if not vim.g.neovide then return end -- GUARD

local g = vim.g
local host = vim.fn.hostname()
local isAtOffice = (host:find("mini") or host:find("eduroam") or host:find("fak1")) ~= nil
local isAtMother = host:find("Mother")
--------------------------------------------------------------------------------

-- SIZE & FONT
if isAtMother then
	g.neovide_padding_top = 4
	g.neovide_padding_left = 6
elseif isAtOffice then
	g.neovide_padding_top = 0
	g.neovide_padding_left = 4
else
	g.neovide_padding_top = 15
	g.neovide_padding_left = 7
end

-- CMD & ALT Keys
g.neovide_input_use_logo = true -- enable `cmd` key on macOS
g.neovide_input_macos_option_key_is_meta = "both" -- so `{@~` etc. can be used

-- Appearance
g.neovide_remember_window_size = true
g.neovide_transparency = 0.91
g.neovide_refresh_rate = isAtMother and 30 or 50
vim.opt.linespace = -2 -- less line height

--------------------------------------------------------------------------------
-- CURSOR
vim.opt.guicursor = {
	"i-ci-c:ver25", -- INFO with noice.nvim, the guicursor cannot be styled in the cmdline https://github.com/folke/noice.nvim/issues/552
	"n-sm:block",
	"r-cr-o-v:hor10",
	"a:blinkwait200-blinkoff350-blinkon550",
}
g.neovide_hide_mouse_when_typing = true

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
