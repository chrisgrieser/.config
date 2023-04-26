local M = {}
--------------------------------------------------------------------------------
-- RETRIEVE CONFIGS FROM ZSHENV
-- HACK cannot be done via os.getenv(), since it does not load properly on system
-- startup, so the values are read manually
--------------------------------------------------------------------------------

-- ZSHENV

---manually read exported environment variables from .zshenv
---@param varname string
---@return string varvalue
local function readZshEnv(varname)
	local zshenv = os.getenv("HOME") .. "/.zshenv"
	local varvalue
	for line in io.open(zshenv, "r"):lines() do
		if line:find(varname) then
			varvalue = line:match(".*= ?(.*)")
			break
		end
	end
	varvalue = varvalue
		:gsub("$HOME", os.getenv("HOME")) -- resole $HOME
		:gsub(" ?#.*$", "") -- bash comments
		:gsub('"', "") -- quotes
		:gsub(" *$", "") -- trim
		:gsub("^ *", "")
	return varvalue
end

-- stored as global files, so the values are not garbage collected
M.dotfilesFolder = readZshEnv("DOTFILE_FOLDER")
M.passwordStore = readZshEnv("PASSWORD_STORE_DIR")
M.vaultLocation = readZshEnv("VAULT_PATH")
M.fileHub = readZshEnv("WD")

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
