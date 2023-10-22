local M = {}

local pathw = hs.pathwatcher.new
local env = require("lua.environment-vars")
local u = require("lua.utils")
local home = os.getenv("HOME")

---INFO this works as only downloaded files get quarantined.
---Ensures that files created locally do not trigger the actions.
---@param filepath string
---@return boolean whether the file exists
local function fileIsDownloaded(filepath)
	local fileExists, msg = pcall(hs.fs.xattr.get, filepath, "com.apple.quarantine")
	return fileExists and msg ~= nil
end

--------------------------------------------------------------------------------

-- CONFIG
local browserSettings = home .. "/.config/_browser-extension-configs/"
local libraryPath = home .. "/.config/pandoc/main-bibliography.bib"

--------------------------------------------------------------------------------

M.pathw_fileHub = pathw(env.fileHub, function(paths, _)
	if not u.screenIsUnlocked() then return end
	for _, filep in pairs(paths) do
		local fileName = filep:gsub(".*/", "")
		local ext = fileName:gsub(".*%.", "")

		-- ALFREDWORKFLOWS, ICAL, & BIB
		if (ext == "alfredworkflow" or ext == "ics") and fileIsDownloaded(filep) then
			u.runWithDelays(3, function() os.remove(filep) end)
		elseif ext == "bib" and fileIsDownloaded(filep) then
			local bibEntry = u.readFile(filep)
			if not bibEntry then return end
			bibEntry = bibEntry:gsub("\n?$", "\n")
			u.writeToFile(libraryPath, bibEntry, true)
			hs.open(libraryPath)
			os.remove(filep)

		-- STATS UPDATE
		elseif fileName == "Stats.dmg" then
			u.runWithDelays(6, function() os.remove(filep) end)

		-- VARIOUS BROWSER SETTINGS
		elseif fileName == "violentmonkey" then
			os.rename(filep, browserSettings .. "violentmonkey")
			-- needs to be zipped again, since browser auto-opens all zip files
			-- stylua: ignore
			hs.execute("cd '" .. browserSettings .. "' && zip violentmonkey.zip ./violentmonkey/* && rm -rf ./violentmonkey")
			print("➡️ Violentmonkey backup")
			u.app(env.browserApp):activate() -- window created by auto-unzipping
		elseif fileName == "ublacklist-settings.json" then
			os.rename(filep, browserSettings .. fileName)
			print("➡️ ublacklist backup")
		elseif fileName:find("vimium_c.*%.json") then
			os.rename(filep, browserSettings .. "vimium-c-settings.json")
			print("➡️ Vimium-C backup")
		elseif fileName:find("adg_ext_settings_.*%.json") then
			os.rename(filep, browserSettings .. "adguard-settings.json")
			print("➡️ AdGuard backup")
		elseif fileName:find("SponsorBlockConfig_.*%.json") then
			os.rename(filep, browserSettings .. "SponsorBlock-settings.json")
			print("➡️ SponsorBlockConfig backup")
		elseif fileName:find("Inoreader Feeds .*%.xml") then
			os.rename(filep, browserSettings .. "Inoreader Feeds.opml")
			print("➡️ Inoreader backup")
		end
	end
end):start()

--------------------------------------------------------------------------------
-- AUTO-INSTALL OBSIDIAN ALPHA

M.pathw_ObsiAlph = pathw(env.fileHub, function(files)
	for _, file in pairs(files) do
		-- needs delay and `.crdownload` check, since the renaming is sometimes
		-- not picked up by hammerspoon
		if not (file:match("%.crdownload$") or file:match("%.asar%.gz$")) then return end

		u.runWithDelays(0.5, function()
			hs.execute([[cd "]] .. env.fileHub .. [[" || exit 1
				test -f obsidian-*.*.*.asar.gz || exit 1
				killall Obsidian
				mv obsidian-*.*.*.asar.gz "$HOME/Library/Application Support/obsidian/"
				cd "$HOME/Library/Application Support/obsidian/"
				rm obsidian-*.*.*.asar
				gunzip obsidian-*.*.*.asar.gz
				while pgrep -xq "Obsidian" ; do sleep 0.1; done
				sleep 0.2
				open -a "Obsidian"
			]])
			-- close the created tab
			u.closeTabsContaining("https://cdn.discordapp.com/attachments")
		end)
	end
end):start()

--------------------------------------------------------------------------------
return M
