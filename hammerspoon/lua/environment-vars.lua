local M = {}
--------------------------------------------------------------------------------
-- APPS

M.transBgApps = {
	"neovide",
	"Neovide",
	"Obsidian",
	"wezterm-gui",
	"WezTerm",
}

M.videoAndAudioApps = {
	"IINA",
	"YouTube",
	"zoom.us",
	"FaceTime",
	"Netflix",
	"Prime Video",
	"Jellyfin",
	"Tageschau",
	"Crunchyroll",
	"TikTok",
	"Twitch",
	"Steam",
}

--------------------------------------------------------------------------------
-- DEVICE

local deviceName = hs.host.localizedName():gsub(".- ", "", 1)

M.isAtOffice = (deviceName:find("[Mm]ini") or deviceName:find("eduroam")) ~= nil
M.isAtHome = (deviceName:find("iMac") and deviceName:find("Home")) ~= nil
M.isAtMother = deviceName:find("Mother") ~= nil

---not static variable, since projector connection can change during runtime
---@nodiscard
---@return boolean
function M.isProjector()
	local mainDisplayName = hs.screen.primaryScreen():name()
	local projectorHelmholtz = mainDisplayName == "ViewSonic PJ"
	local tvLeuthinger = mainDisplayName == "TV_MONITOR"
	return projectorHelmholtz or tvLeuthinger
end

--------------------------------------------------------------------------------
return M
