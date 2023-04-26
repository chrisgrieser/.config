local u = require("lua.utils")
-- retrieve configs from zshenv
-- HACK cannot be done via os.getenv(), since it does not load properly on system
-- startup, so the values are read manually


local zshenv = u.readFile(os.getenv("HOME") .. "/.zshenv")

---manually read exported environment variables from .zshenv
---@param varname string
local function readZshEnv(varname)
		
end

-- stored as global files, so they stay accessible
DotfilesFolder = readZshEnv("DOTFILE_FOLDER")
PasswordStore = readZshEnv("PASSWORD_STORE_DIR")
VaultLocation = readZshEnv("VAULT_PATH")
FileHub = readZshEnv("WD")
