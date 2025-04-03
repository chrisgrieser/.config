-- DOCS https://neovide.dev/configuration.html
if not vim.g.neovide then return end

--------------------------------------------------------------------------------

-- SIZE & FONT
vim.opt.linespace = -2 -- less line height

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
	vim.g.neovide_refresh_rate = 60
	vim.g.neovide_padding_top = 15
	vim.g.neovide_padding_left = 7
end

-- cmd+ / cmd- to change zoom
local function changeScaleFactor(delta)
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + delta
	local icon = delta > 0 and "" or ""
	local opts = { id = "scale_factor", icon = icon, title = "Scale factor" }
	vim.notify(tostring(vim.g.neovide_scale_factor), nil, opts)
end
local keymap = require("config.utils").uniqueKeymap
keymap({ "n", "x", "i" }, "<D-+>", function() changeScaleFactor(0.01) end, { desc = " Zoom" })
keymap({ "n", "x", "i" }, "<D-->", function() changeScaleFactor(-0.01) end, { desc = " Zoom" })

--------------------------------------------------------------------------------

-- CMD & ALT Keys
vim.g.neovide_input_use_logo = true -- enable, so `cmd` on macOS can be used
vim.g.neovide_input_macos_option_key_is_meta = "none" -- disable, so `{@~` etc. can be used

-- Appearance
vim.g.neovide_opacity = 1
vim.g.neovide_theme = "auto" -- needs to be set, as the setting in `config.toml` is ignored
vim.g.neovide_underline_stroke_scale = 2.5 -- fix underline thickness

-- behavior
vim.g.neovide_remember_window_size = true
vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_cursor_animate_in_insert_mode = false
vim.g.neovide_cursor_animate_command_line = false -- does not affect noice-cmdline

do -- only active when `multigrid` is enabled in `neovide/config.toml`
	vim.g.neovide_scroll_animation_length = 0 -- scroll instantly
	vim.g.neovide_floating_corner_radius = 0 -- looks weird with some windows
	vim.g.neovide_floating_shadow = false -- shadow looks weird with many plugin windows
	vim.g.neovide_position_animation_length = 0.1 -- i.e., speed windows move
end

--------------------------------------------------------------------------------
-- CURSOR
vim.opt.guicursor = {
	"i-ci-c:ver25",
	"n-sm:block",
	"r-cr-o-v:hor10",
	"a:blinkwait100-blinkoff500-blinkon500",
}
vim.g.neovide_cursor_smooth_blink = true

vim.g.neovide_cursor_animation_length = 0.1
vim.g.neovide_cursor_trail_size = 1.0 -- 0-1, long trail
vim.g.neovide_cursor_vfx_mode = "railgun" -- railgun|torpedo|pixiedust|sonicboom|ripple|wireframe

vim.g.neovide_cursor_vfx_particle_lifetime = 1.0
vim.g.neovide_cursor_vfx_particle_density = 1.5
vim.g.neovide_cursor_vfx_particle_speed = 5
