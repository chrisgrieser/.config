local u = require("modules.utils")
--------------------------------------------------------------------------------

local reloadIndicator = "/tmp/hs-is-reloading"

-- `hammerspoon://hs-reload` for reloading via Makefile
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
