-- https://wezfurlong.org/wezterm/config/files.html#quick-start
--------------------------------------------------------------------------------
local wezterm = require("wezterm") -- Pull in the wezterm API
local config = {} -- This table will hold the configuration.

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then config = wezterm.config_builder() end
--------------------------------------------------------------------------------

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "AdventureTime"
config.font_size = 25

--------------------------------------------------------------------------------

return config
