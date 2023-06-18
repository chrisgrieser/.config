local u = require("lua.utils")

--------------------------------------------------------------------------------

-- hyper+v: toggle vertical split
u.hotkey(u.hyper, "V", function()
	local allWins = hs.window.allWindows()
	local frontApp = hs.application:frontmostApplication()
	local noSplit = #hs.spaces.spacesForScreen() == 1 -- I don't use spaces for anything else
	print("noSplit:", noSplit)

	if noSplit then
		-- unhide all windows, so they are displayed as selection for the second window
		for _, win in pairs(allWins) do
			local app = win:application()
			if app and app:isHidden() then app:unhide() end
		end

		frontApp:selectMenuItem { "Window", "Tile Window to Right of Screen" }
	else
		print("👾 beep")
		frontApp:selectMenuItem { "Window", "Move Window to Desktop" }

		-- un-fullscreen the window of the second app
		for _, win in pairs(allWins) do
			if win:isFullScreen() then win:setFullScreen(false) end
		end
	end
end)
