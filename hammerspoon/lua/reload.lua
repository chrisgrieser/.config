local u = require("lua.utils")
--------------------------------------------------------------------------------

local reloadIndicator = "/tmp/hs-is-reloading"

-- trigger `hammerspoon://hs-reload` for reloading via nvim (filetype-config: lua.lua)
u.urischeme("hs-reload", function()
	hs.execute("touch " .. reloadIndicator)
	u.runWithDelays(0.3, hs.reload)
	-- hs.reload()
end)

if u.isReloading() then
	print("\n--------------------------- 🔨 HAMMERSPOON RELOAD -------------------------------\n")
	os.remove(reloadIndicator)
else
	u.notify("🔨 Finished loading")
end
