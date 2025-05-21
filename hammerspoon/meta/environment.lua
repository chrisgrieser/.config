local M = {}
--------------------------------------------------------------------------------

local device = hs.host.localizedName()
M.isAtOffice = (device:find("[Mm]ini") or device:find("eduroam") or device:find("Office")) ~= nil
M.isAtHome = (device:find("iMac") and device:find("Home")) ~= nil
M.isAtMother = device:find("Mother") ~= nil

---not static variable, since projector connection can change during runtime
---@nodiscard
---@return boolean
function M.isProjector()
	if M.isAtOffice then return false end
	return #hs.screen.allScreens() > 1
end

--------------------------------------------------------------------------------
return M
