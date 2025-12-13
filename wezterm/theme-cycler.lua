local M = {}
--------------------------------------------------------------------------------

---cycle through builtin dark schemes in dark mode, and through light schemes in
---light mode
function M.cycle(window, _pane)
	local wt = require("wezterm")
	local allSchemes = wt.color.get_builtin_schemes()
	local darkSchemes = {}
	local lightSchemes = {}
	for name, scheme in pairs(allSchemes) do
		if scheme.background then -- FIX https://github.com/wez/wezterm/discussions/3426#discussioncomment-9127923
			local bg = wt.color.parse(scheme.background) -- parse into a color object
			local h, s, l, a = bg:hsla() ---@diagnostic disable-line: unused-local
			if l < 0.45 then
				table.insert(darkSchemes, name)
			else
				table.insert(lightSchemes, name)
			end
		end
	end

	local currentScheme = window:effective_config().color_scheme
	local schemesToSearch = wt.gui.get_appearance():find("Dark") and darkSchemes or lightSchemes
	for i = 1, #schemesToSearch do
		if schemesToSearch[i] == currentScheme then
			local overrides = window:get_config_overrides() or {}
			local nextScheme = schemesToSearch[i + 1]
			overrides.color_scheme = nextScheme
			window:set_config_overrides(overrides)

			window:copy_to_clipboard(nextScheme)
			window:toast_notification("Color scheme", nextScheme, nil, 4000) -- BUG not working in keymaps
			wt.log_info("Color scheme:", nextScheme)
			return -- stop loop
		end
	end
end

--------------------------------------------------------------------------------
return M
