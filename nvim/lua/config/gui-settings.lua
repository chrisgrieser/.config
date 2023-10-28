local g = vim.g
local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------

-- REMOTE CONTROL
-- nvim server (RPC) to remote control neovide instances
-- DOCS https://neovim.io/doc/user/remote.html
pcall(os.remove, "/tmp/nvim_server.pipe") -- FIX server sometimes not properly shut down
vim.defer_fn(function() vim.fn.serverstart("/tmp/nvim_server.pipe") end, 400)

--------------------------------------------------------------------------------

-- SIZE & FONT
vim.opt.guifont = "JetBrainsMonoNL Nerd Font:h25.2"

local host = vim.fn.hostname()
local isAtOffice = (host:find("mini") or host:find("eduroam") or host:find("fak1")) ~= nil
if host:find("Mother") then
	g.neovide_scale_factor = 0.88
	g.neovide_refresh_rate = 35
elseif isAtOffice then
	g.neovide_scale_factor = 1.06
	g.neovide_refresh_rate = 45
else
	g.neovide_scale_factor = 1
	g.neovide_refresh_rate = 50
end

local function setNeovideScaleFactor(delta)
	g.neovide_scale_factor = g.neovide_scale_factor + delta
	require("config.utils").notify("", "Scale Factor: " .. g.neovide_scale_factor)
end

keymap({ "n", "x", "i" }, "<D-+>", function() setNeovideScaleFactor(0.01) end)
keymap({ "n", "x", "i" }, "<D-->", function() setNeovideScaleFactor(-0.01) end)

--------------------------------------------------------------------------------

-- window size
g.neovide_remember_window_size = true
-- HACK fix window size sometimes not being remembered
vim.fn.system { "open", "-g", "hammerspoon://neovide-post-startup" }

-- keymaps
g.neovide_input_use_logo = true -- enable `cmd` key on macOS
g.neovide_input_macos_alt_is_meta = false -- false, so {@~ etc can be used
g.neovide_hide_mouse_when_typing = true

-- Window Appearance
g.neovide_underline_automatic_scaling = true -- slightly unstable according to docs
g.neovide_scroll_animation_length = 1

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

-- only railgun, torpedo, and pixiedust
g.neovide_cursor_vfx_particle_lifetime = 0.5
g.neovide_cursor_vfx_particle_density = 20.0
g.neovide_cursor_vfx_particle_speed = 40.0

-- only railgun
g.neovide_cursor_vfx_particle_phase = 1.3
g.neovide_cursor_vfx_particle_curl = 1.3
