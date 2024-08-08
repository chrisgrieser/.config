-- DOCS https://neovide.dev/configuration.html
--------------------------------------------------------------------------------
if not vim.g.neovide then return end

local g = vim.g
local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------

-- FIX neovide ignoring `tabs = false` on consecutive opening of new files
-- https://github.com/neovide/neovide/issues/2585
vim.api.nvim_create_autocmd("TabNewEntered", {
	callback = function(ctx)
		vim.defer_fn(function()
			if vim.fn.tabpagenr("$") == 1 or vim.bo.buftype ~= "" then return end
			vim.cmd.tabclose()
			vim.defer_fn(function() vim.cmd.edit(ctx.file) end, 1)
		end, 1)
	end,
})

--------------------------------------------------------------------------------

-- SIZE & FONT
local host = vim.uv.os_gethostname()
local isAtOffice = host:find("eduroam") or host:find("mini")
local isAtMother = host:find("Mother")

if isAtMother then
	g.neovide_scale_factor = 0.9
	g.neovide_padding_top = 4
	g.neovide_padding_left = 6
elseif isAtOffice then
	g.neovide_scale_factor = 1.05
	g.neovide_padding_top = 0
	g.neovide_padding_left = 2
else
	g.neovide_scale_factor = 1
	g.neovide_padding_top = 15
	g.neovide_padding_left = 7
end

--------------------------------------------------------------------------------

-- cmd+ / cmd- to change zoom
local scaleNotify
local function setNeovideScaleFactor(delta)
	g.neovide_scale_factor = g.neovide_scale_factor + delta
	scaleNotify = vim.notify("Scale Factor: " .. g.neovide_scale_factor, vim.log.levels.INFO, {
		replace = scaleNotify and scaleNotify.id,
	})
end
keymap({ "n", "x", "i" }, "<D-+>", function() setNeovideScaleFactor(0.01) end, { desc = "Zoom +" })
keymap({ "n", "x", "i" }, "<D-->", function() setNeovideScaleFactor(-0.01) end, { desc = "Zoom -" })

--------------------------------------------------------------------------------

-- CMD & ALT Keys
g.neovide_input_use_logo = true -- enable, so `cmd` on macOS can be used
g.neovide_input_macos_option_key_is_meta = "none" -- disable, so `{@~` etc. can be used

-- Appearance
g.neovide_transparency = 0.93
g.neovide_theme = "auto" -- needs to be set, as the setting in `config.toml` is ignored
g.neovide_underline_stroke_scale = 2.0 -- fix underline thickness
g.neovide_remember_window_size = true
g.neovide_hide_mouse_when_typing = true
g.neovide_refresh_rate = isAtMother and 25 or 50
vim.opt.linespace = -2 -- less line height

--------------------------------------------------------------------------------
-- CURSOR
vim.opt.guicursor = {
	"i-ci-c:ver25",
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
