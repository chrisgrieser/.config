local reloadIndicator = "/tmp/hs-is-reloading"

-- URI for Justfile
hs.urlevent.bind("hs-reload", function()
	hs.execute("touch " .. reloadIndicator) -- to detect whether we start or reload hammerspoon
	U.defer(0.1, hs.reload)
end)

if U.isSystemStart() then
	hs.notify.show("Hammerspoon", "", "✅ Finished loading")
else
	-- is reloading
	print("\n---------------------- HAMMERSPOON RELOAD ----------------------\n")
	os.remove(reloadIndicator)
	hs.notify.show("Hammerspoon", "", "✅ Finished reloading")
	U.defer(0.2, require("appearance.console").cleanupConsole)
end
