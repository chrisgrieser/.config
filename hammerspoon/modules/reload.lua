local u = require("modules.utils")
--------------------------------------------------------------------------------

local reloadIndicator = "/tmp/hs-is-reloading"

-- URI for Makefile/Justfile
hs.urlevent.bind("hs-reload", function()
	hs.execute("touch " .. reloadIndicator)
	u.runWithDelays(0.15, hs.reload)
end)

--------------------------------------------------------------------------------

if u.isSystemStart() then
	hs.notify.show("Hammerspoon", "", "✅ Finished loading")
else
	-- is reloading
	print("\n--------------------------- HAMMERSPOON RELOAD -------------------------------\n")
	os.remove(reloadIndicator)
end
