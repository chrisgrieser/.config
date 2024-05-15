local M = {}

local pathw = hs.pathwatcher.new
local env = require("lua.environment-vars")
local u = require("lua.utils")
local home = os.getenv("HOME")
--------------------------------------------------------------------------------

-- CONFIG
local browserSettings = home .. "/.config/+ browser-extension-configs/"
local libraryPath = home .. "/.config/pandoc/main-bibliography.bib"
local desktopPath = home .. "/Desktop"

--------------------------------------------------------------------------------

---INFO this works as only downloaded files get quarantined.
---Ensures that files created locally do not trigger the actions.
---@param filepath string
---@return boolean whether the file exists
local function fileIsDownloaded(filepath)
	local fileExists, msg = pcall(hs.fs.xattr.get, filepath, "com.apple.quarantine")
	return fileExists and msg ~= nil
end

M.pathw_fileHub = pathw(desktopPath, function(paths, _)
	if not u.screenIsUnlocked() then return end -- prevent iCloud sync triggering in standby

	for _, filep in pairs(paths) do
		local fileName = filep:gsub(".*/", "")
		local ext = fileName:gsub(".*%.", "")

		-- 1. AUTO-REMOVE ALFREDWORKFLOWS & ICAL
		if (ext == "alfredworkflow" or ext == "ics") and fileIsDownloaded(filep) then
			u.runWithDelays(3, function() os.remove(filep) end)

		-- 2. AUTO-ADD BIBTEX ENTRIES TO LIBRARY
		elseif ext == "bib" and fileIsDownloaded(filep) then
			local bibEntry = u.readFile(filep)
			if not bibEntry then return end
			bibEntry = bibEntry:gsub("\n?$", "\n")
			u.writeToFile(libraryPath, bibEntry, true)
			hs.open(libraryPath)
			os.remove(filep)

		-- 3. BACKUP BROWSER SETTINGS
		elseif fileName == "violentmonkey" then
			os.rename(filep, browserSettings .. "violentmonkey")
			-- needs to be zipped again, since browser auto-opens all zip files
			-- stylua: ignore
			hs.execute("cd '" .. browserSettings .. "' && zip violentmonkey.zip ./violentmonkey/* && rm -rf ./violentmonkey")
			u.app("Brave Browser"):activate() -- window created by auto-unzipping
		elseif fileName == "ublacklist-settings.json" then
			os.rename(filep, browserSettings .. fileName)
		elseif fileName:find("vimium_c.*%.json") then
			os.rename(filep, browserSettings .. "vimium-c-settings.json")
		elseif fileName:find("my%-ublock%-backup_.*%.txt") then
			os.rename(filep, browserSettings .. "ublock-settings.json")
		elseif fileName:find("SponsorBlockConfig_.*%.json") then
			os.rename(filep, browserSettings .. "SponsorBlock-settings.json")
		elseif fileName == "devdocs.json" then
			os.rename(filep, browserSettings .. "devdocs-settings.json")
		elseif fileName:find("stylus%-.*%.json") then
			os.rename(filep, browserSettings .. "stylus.json")
		end

		-- 4. AUTO-INSTALL OBSIDIAN ALPHA
		-- needs delay and `.crdownload` check, since the renaming is sometimes
		-- not picked up by hammerspoon
		if filep:match("%.crdownload$") or filep:match("%.asar%.gz$") then
			u.runWithDelays(0.5, function()
				hs.execute(([[
					cd %q || exit 1
					test -f obsidian-*.*.*.asar.gz || exit 1
					killall Obsidian
					mv obsidian-*.*.*.asar.gz "$HOME/Library/Application Support/obsidian/"
					cd "$HOME/Library/Application Support/obsidian/"
					rm obsidian-*.*.*.asar
					gunzip obsidian-*.*.*.asar.gz
					while pgrep -xq "Obsidian" ; do sleep 0.1; done
					sleep 0.2
					open -a "Obsidian"
				]]):format(desktopPath))
				u.closeTabsContaining("https://cdn.discordapp.com/attachments")
			end)
		end
	end
end):start()

--------------------------------------------------------------------------------
return M
