local M = {}
--------------------------------------------------------------------------------

-- RETRIEVE ENVIRONMENT VARS FROM ZSHENV
-- HACK cannot be done via `os.getenv()`, since often it does not load properly on
-- system startup, so the values have to be read manually.
---@param varname string
---@return string
local function readZshEnv(varname)
	local value, success = hs.execute("source $HOME/.zshenv && echo $" .. varname)
	if not success then hs.notify.show("Hammerspoon", "", "⚠️ Could not source .zshenv") end
	if not value then return "" end
	value = value:gsub("\n$", "")
	return value
end

--------------------------------------------------------------------------------
-- Apps

M.mastodonApp = "Mona"
M.browserApp = readZshEnv("BROWSER_APP")

M.transBgApps = {
	"neovide",
	"Obsidian",
	"wezterm-gui",
	"WezTerm",
}

M.videoAndAudioApps = {
	"IINA",
	"TikTok",
	"YouTube",
	"zoom.us",
	"FaceTime",
	"Twitch",
	"Netflix",
	"Prime Video",
	"Jellyfin",
	"Tageschau",
	"Crunchyroll",
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

M.fileHub = readZshEnv("WD")
M.codeFont = readZshEnv("CODE_FONT")
M.homebrewPrefix = M.isAtMother and "/usr/local" or "/opt/homebrew"

--------------------------------------------------------------------------------
return M
