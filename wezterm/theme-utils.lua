local M = {}
local wt = require("wezterm")
--------------------------------------------------------------------------------

---selects the color scheme depending on Dark/Light Mode
---@param lightTheme string 
---@param darkTheme string 
---@nodiscard
---@return string name of the string to set in config.colorscheme
function M.autoScheme(darkTheme, lightTheme)
	local currentMode = wt.gui.get_appearance()
	local colorscheme = currentMode:find("Dark") and darkTheme or lightTheme
	return colorscheme
end

---selects the opacity depending on Dark/Light Mode
---@param lightOpacity number 
---@param darkOpacity number 
---@nodiscard
---@return integer Opacity to use
function M.autoOpacity(darkOpacity, lightOpacity)
	local currentMode = wt.gui.get_appearance()
	local opacity = currentMode:find("Dark") and darkOpacity or lightOpacity
	return opacity
end

---cycle through builtin dark schemes in dark mode, and through light schemes in
---light mode
function M.cycle(window, _)
	local allSchemes = wt.color.get_builtin_schemes()
	local currentMode = wt.gui.get_appearance()
	local currentScheme = window:effective_config().color_scheme
	local darkSchemes = {}
	local lightSchemes = {}

	for name, scheme in pairs(allSchemes) do
		local bg = wt.color.parse(scheme.background) -- parse into a color object
		local h, s, l, a = bg:hsla() ---@diagnostic disable-line: unused-local
		if l < 0.45 then
			table.insert(darkSchemes, name)
		else
			table.insert(lightSchemes, name)
		end
	end
	local schemesToSearch = currentMode:find("Dark") and darkSchemes or lightSchemes

	for i = 1, #schemesToSearch, 1 do
		if schemesToSearch[i] == currentScheme then
			local overrides = window:get_config_overrides() or {}
			local nextScheme = schemesToSearch[i + 1]
			overrides.color_scheme = nextScheme
			window:set_config_overrides(overrides)

			window:copy_to_clipboard(nextScheme)
			window:toast_notification("Color scheme", nextScheme, nil, 4000)
			return
		end
	end
end

--------------------------------------------------------------------------------
return M
