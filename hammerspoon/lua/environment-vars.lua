local M = {}
--------------------------------------------------------------------------------

-- RETRIEVE ENVIRONMENT VARS FROM ZSHENV
-- HACK cannot be done via os.getenv(), since it does not load properly on system
-- startup, so the values are read manually .zshenv
---@param varname string
---@return string varvalue
local function readZshEnv(varname)
	local zshenv = os.getenv("HOME") .. "/.zshenv"
	local value
	for line in io.open(zshenv, "r"):lines() do
		if line:find(varname) then
			value = line:match(".*= ?(.*)")
			break
		end
	end
	value = value
		:gsub("$HOME", os.getenv("HOME")) -- resolve $HOME
		:gsub(" ?#.*$", "") -- remove bash comments
		:gsub('"', "") -- remove quotes
		:gsub(" *$", "") -- trim 
		:gsub("^ *", "") -- trim
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
M.tickerApp = "Ivory"

--------------------------------------------------------------------------------
-- DEVICE

local deviceName = hs.host.localizedName():gsub(".- ", "", 1)

M.isAtOffice = (deviceName:find("[Mm]ini") or deviceName:find("eduroam")) ~= nil
M.isAtHome = (deviceName:find("iMac") and deviceName:find("Home")) ~= nil
M.isAtMother = deviceName:find("Mother") ~= nil

---not using static variable, since projector connection can vary
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
