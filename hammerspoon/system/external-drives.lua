local M = {} -- persist from garbage collector

local u = require("meta.utils")
local usb = hs.usb.watcher

-- backup device: open terminal
-- otherwise: open in Finder
M.usb_externalDrives = usb.new(function(device)
	local name = device.productName
	local ignore = {
		"CHERRY Wireless Device", -- Mouse at mother
		"Keychron K3", ------------- Keyboard at home & office
		"SP 150", ------------------ RICOH printer
		"Integrated RGB Camera", --- Docking station in the office
		"USB 10/100/1000 LAN", ----- ^
		"T27hv-20", ---------------- ^
	}
	if hs.fnutils.contains(ignore, name) or device.eventType ~= "added" then return end
	-----------------------------------------------------------------------------
	u.notify("Mounted: " .. name)

	local harddriveNames = {
		"ZY603 USB3.0 Device", -- Externe A
		"External Disk 3.0", ---- Externe B
		"Elements 2621", -------- Externe C
	}

	if hs.fnutils.contains(harddriveNames, name) then
		hs.application.open("WezTerm")
	else
		-- search for mounted volumes, since the usb-watcher does not report it to us
		local cmd = [[df | grep ' /Volumes/' | grep -v '/Volumes/Recovery' | 
			grep --only-matching '/Volumes/.*' | head -n1 | xargs -I{} open '{}']]
		u.defer({ 1, 3, 5 }, function() hs.execute(cmd) end)
	end
end):start()

--------------------------------------------------------------------------------
return M
