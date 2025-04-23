-- DOCS https://neovide.dev/configuration.html
if not vim.g.neovide then return end

--------------------------------------------------------------------------------

-- SIZES
local host = vim.uv.os_gethostname()
local isAtOffice = host:find("eduroam") or host:find("mini")
local isAtMother = host:find("Mother")

if isAtMother then
	vim.g.neovide_scale_factor = 0.9
	vim.g.neovide_refresh_rate = 30
	vim.g.neovide_padding_top = 4
	vim.g.neovide_padding_left = 6
elseif isAtOffice then
	vim.g.neovide_scale_factor = 1.05
	vim.g.neovide_refresh_rate = 45
	vim.g.neovide_padding_top = 0
	vim.g.neovide_padding_left = 2
else
	vim.g.neovide_scale_factor = 1
	vim.g.neovide_refresh_rate = 45
	vim.g.neovide_padding_top = 15
	vim.g.neovide_padding_left = 7
end
vim.opt.linespace = -2 -- less line height

--------------------------------------------------------------------------------

-- CMD & ALT Keys
vim.g.neovide_input_use_logo = true -- enable, so `cmd` on macOS can be used
vim.g.neovide_input_macos_option_key_is_meta = "none" -- disable, so `{@~` etc. can be used

-- Appearance
vim.g.neovide_opacity = 1
vim.g.neovide_theme = "auto" -- needs to be set, as the setting in `config.toml` is ignored
vim.g.neovide_underline_stroke_scale = 2.5 -- fix underline thickness
vim.g.neovide_show_border = true

-- behavior
vim.g.neovide_remember_window_size = true
vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_cursor_animate_in_insert_mode = false
vim.g.neovide_cursor_animate_command_line = false

do -- only active when `multigrid` is enabled in `neovide/config.toml`
	vim.g.neovide_scroll_animation_length = 0 -- scroll instantly
	vim.g.neovide_floating_corner_radius = 0 -- looks weird with some plugin windows
	vim.g.neovide_floating_shadow = false -- looks weird with some plugin windows
	vim.g.neovide_position_animation_length = 0.15 -- windows movement speed
	vim.g.neovide_floating_blur_amount_x = 3.0
	vim.g.neovide_floating_blur_amount_y = 3.0
end

--------------------------------------------------------------------------------
-- CURSOR
vim.opt.guicursor = {
	"i-ci-c:ver25",
	"n-sm:block",
	"r-cr-o-v:hor10",
	"a:blinkwait200-blinkoff800-blinkon1000",
}
vim.g.neovide_cursor_smooth_blink = true

vim.g.neovide_cursor_animation_length = 0.03
vim.g.neovide_cursor_trail_size = 1.0 -- 0-1, long trail
vim.g.neovide_cursor_vfx_mode = "railgun" -- railgun|torpedo|pixiedust|sonicboom|ripple|wireframe

vim.g.neovide_cursor_vfx_particle_lifetime = 1.3
vim.g.neovide_cursor_vfx_particle_density = 0.7
vim.g.neovide_cursor_vfx_particle_speed = 20
