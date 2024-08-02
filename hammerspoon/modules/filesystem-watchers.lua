local M = {}

local u = require("modules.utils")

local home = os.getenv("HOME")
local pathw = hs.pathwatcher.new
--------------------------------------------------------------------------------

-- CONFIG
local browserSettings = home .. "/.config/+ browser-extension-configs/"
local libraryPath = home .. "/.config/pandoc/main-bibliography.bib"
local desktop = home .. "/Desktop/"
local gameFolder = home .. "/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Games/"

M.pathw_fileHub = pathw(desktop, function(paths, _)
	if not u.screenIsUnlocked() then return end -- prevent iCloud sync triggering in standby

	for _, path in pairs(paths) do
		local name = path:match(".*/(.+)")
		local ext = name:match("%.(.+)$")

		-- INFO only downloaded files get quarantined
		local exists, msg = pcall(hs.fs.xattr.get, path, "com.apple.quarantine")
		local isDownloaded = exists and msg ~= nil

		-- 1. REMOVE ALFREDWORKFLOWS & ICAL (after they are opened by browser)
		if (ext == "alfredworkflow" or ext == "ics") and isDownloaded then
			u.runWithDelays(3, function() os.remove(path) end)

		-- 2. ADD BIBTEX ENTRIES TO LIBRARY
		elseif ext == "bib" and isDownloaded then
			local bibEntry = u.readFile(path)
			if bibEntry then
				bibEntry = bibEntry:gsub("\n?$", "\n")
				u.writeToFile(libraryPath, bibEntry, true)
				hs.open(libraryPath)
				os.remove(path)
			end

		-- 3. BACKUP BROWSER SETTINGS
		elseif name == "violentmonkey" then
			os.rename(path, browserSettings .. "violentmonkey")
			-- needs to be zipped again, since browser auto-opens all zip files
			local shellCmd = ("cd %q && "):format(browserSettings)
				.. "zip violentmonkey.zip ./violentmonkey/* && rm -rf ./violentmonkey"
			hs.execute(shellCmd)
			u.app("Brave Browser"):activate() -- window created by auto-unzipping
		elseif name == "ublacklist-settings.json" then
			os.rename(path, browserSettings .. name)
		elseif name:find("my%-ublock%-backup_.*%.txt") then
			os.rename(path, browserSettings .. "ublock-settings.json")
		elseif name:find(".*_adg_ext_settings_.*%.json") then
			os.rename(path, browserSettings .. "adguard-settings.json")
		elseif name:find("stylus%-.*%.json") then
			os.rename(path, browserSettings .. "stylus.json")
		elseif name:find("Inoreader Feeds .*%.xml") then
			local backupPath = home
				.. "/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Backups/Inoreader Feeds.opml"
			os.rename(path, backupPath)

		-- 4. STEAM GAME SHORTCUTS
		elseif name:find("%.app$") and not isDownloaded then
			os.rename(path, gameFolder .. name)
			-- open folders to copy icon
			hs.open(gameFolder)
			hs.open(home .. "/Library/Application Support/Steam/steamapps/common")

		-- 5. DATESTAMP SCANS FROM THE IPHONE
		elseif name:find("Scanned Document.*.pdf") then
			local dateStamp = os.date("%Y-%m-%d")
			local counter = 1
			local newName
			repeat -- ensure file does not exist
				newName = ("%s/Scanned_Document_%d %s.pdf"):format(desktop, counter, dateStamp)
				counter = counter + 1
			until hs.fs.attributes(newName) == nil
			os.rename(path, newName)

		-- 6. AUTO-INSTALL OBSIDIAN ALPHA
		-- needs delay and `.crdownload` check, since the renaming is sometimes
		-- not picked up by hammerspoon
		elseif name:find("%.crdownload$") or (name:find("%.asar%.gz$") and isDownloaded) then
			u.runWithDelays(0.5, function()
				hs.execute(([=[
					cd %q || exit 1
					test -f obsidian-*.*.*.asar.gz || exit 1
					mv obsidian-*.*.*.asar.gz "$HOME/Library/Application Support/obsidian/"
					cd "$HOME/Library/Application Support/obsidian/"
					rm obsidian-*.*.*.asar
					gunzip obsidian-*.*.*.asar.gz
					killall Obsidian
					while pgrep -xq "Obsidian" ; do sleep 0.1; done
					open -a "Obsidian"
				]=]):format(desktop))
				u.closeTabsContaining("https://cdn.discordapp.com/attachments")
			end)
		end
	end
end):start()

--------------------------------------------------------------------------------
return M
