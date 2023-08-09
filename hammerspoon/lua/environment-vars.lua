local M = {}
--------------------------------------------------------------------------------

-- RETRIEVE ENVIRONMENT VARS FROM ZSHENV
-- HACK cannot be done via os.getenv(), since often it does not load properly on
-- system startup, so the values are read manually .zshenv
---@param varname string
---@return string
local function readZshEnv(varname)
	local value, success = hs.execute("source $HOME/.zshenv && echo $" .. varname)
	if not success then hs.notify.show("Hammerspoon", "", "⚠️ Could not source .zshenv") end
	if not value then value = "" end
	value = value:gsub("\n$", "")
	return value
end

-- stored as global files, so the values are not garbage collected
M.dotfilesFolder = readZshEnv("DOTFILE_FOLDER")
M.passwordStore = readZshEnv("PASSWORD_STORE_DIR")
M.vaultLocation = readZshEnv("VAULT_PATH")
M.fileHub = readZshEnv("WD")

--------------------------------------------------------------------------------
-- Apps
M.mailApp = readZshEnv("MAIL_APP")
M.browserApp = readZshEnv("BROWSER_APP")
M.browserDefaultsPath = readZshEnv("BROWSER_DEFAULTS_PATH")
M.tickerApp = readZshEnv("TICKER_APP")

--------------------------------------------------------------------------------
-- DEVICE

local deviceName = hs.host.localizedName():gsub(".- ", "", 1)

M.isAtOffice = (deviceName:find("[Mm]ini") or deviceName:find("eduroam")) ~= nil
M.isAtHome = (deviceName:find("iMac") and deviceName:find("Home")) ~= nil
M.isAtMother = deviceName:find("Mother") ~= nil

---not using static variable, since projector connection can change during
---runtime
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
