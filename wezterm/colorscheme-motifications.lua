-- DOCS https://wezterm.org//config/lua/wezterm/get_builtin_color_schemes.html
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local scheme = wezterm.get_builtin_color_schemes()["Nord Light (Gogh)"]
scheme.background = "red"

return {
	color_schemes = {
		["Nord Light (Gogh)"] = scheme,
	},
	color_scheme = "Nord Light (Gogh)",
}
