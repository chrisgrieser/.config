local pw = hs.pathwatcher.new
local env = require("lua.environment-vars")
local u = require("lua.utils")
local home = os.getenv("HOME")

---is in sub-directory instead of directly in the folder
---@param fPath string? filepath
---@param folder string? folderpath
---@return boolean|nil returns nil if getting invalid input
local function isInSubdirectory(fPath, folder)
	if not fPath or not folder then return nil end
	local _, fileSlashes = fPath:gsub("/", "")
	local _, folderSlashes = folder:gsub("/", "")
	return fileSlashes > folderSlashes
end

--------------------------------------------------------------------------------

-- BOOKMARKS SYNCED TO CHROME BOOKMARKS
-- (needed for Alfred)
local sourceProfileLocation = home .. "/Library/Application Support/Vivaldi/"
local sourceBookmarkPath = sourceProfileLocation .. "/Default/Bookmarks"
local chromeProfileLocation = home .. "/Library/Application Support/Google/Chrome/"
BookmarkWatcher = pw(sourceBookmarkPath, function()
	-- Bookmarks
	local bookmarks = hs.json.read(sourceBookmarkPath)
	if not bookmarks then return end
	bookmarks.roots.trash = nil -- remove Vivaldi's trash folder for Alfred
	hs.execute(("mkdir -p '%s'"):format(chromeProfileLocation))
	local success = hs.json.write(bookmarks, chromeProfileLocation .. "/Default/Bookmarks", false, true)
	if not success then
		u.notify("🔖⚠️ Bookmarks not correctly synced.")
		return
	end

	-- Local State (also required for Alfred to pick up the Bookmarks)
	local content = u.readFile(sourceProfileLocation .. "/Local State")
	if not content then return end
	u.writeToFile(chromeProfileLocation .. "/Local State", content)

	print("🔖 Bookmarks synced to Chrome Bookmarks")
end):start()

--------------------------------------------------------------------------------

-- DOWNLOAD FOLDER BADGE
local downloadFolder = home .. "/Downloaded"
DownloadFolderWatcher = pw(
	downloadFolder,
	function()
		hs.execute("zsh ./helpers/download-folder-badge/download-folder-icon.sh " .. downloadFolder)
	end
):start()

--------------------------------------------------------------------------------
-- TO FILE HUB

-- GenuisScan
local scanFolder = home
	.. "/Library/Mobile Documents/iCloud~com~geniussoftware~GeniusScan/Documents/"
ScanFolderWatcher = pw(scanFolder, function()
	hs.execute("mv '" .. scanFolder .. "'/* '" .. env.fileHub .. "'")
	print("➡️ Scan moved to File Hub.")
end):start()

-- Downloads Folder
local systemDownloadFolder = home .. "/Downloads/"
SystemDlFolderWatcher = pw(systemDownloadFolder, function(files)
	-- Stats Update file can directly be trashed
	for _, filePath in pairs(files) do
		if not filePath:find("Stats%.dmg$") then break end
		u.runWithDelays(1, function() os.rename(filePath, home .. "/.Trash/Stats.dmg") end)
	end

	-- otherwise move to filehub
	os.execute("mv '" .. systemDownloadFolder .. "'/* '" .. env.fileHub .. "'")
	print("➡️ Download moved to File Hub.")
end):start()

--------------------------------------------------------------------------------
-- FROM FILE HUB

local browserSettings = env.dotfilesFolder .. "/_browser-extension-configs/"
FileHubWatcher = pw(env.fileHub, function(paths, _)
	if not u.screenIsUnlocked() then return end
	for _, filep in pairs(paths) do
		if isInSubdirectory(filep, env.fileHub) then return end
		local fileName = filep:gsub(".*/", "")
		local ext = fileName:gsub(".*%.", "")

		-- alfredworkflows, ics, and dmg (iCal)
		if ext == "alfredworkflow" or ext == "ics" or ext == "dmg" then
			-- opening ics and Alfred leads to recursions when opened via this file
			-- watcher and are therefore opened via browser auto-open instead. dmg
			-- cannot be opened via browser though and also does not create recursion,
			-- so it is opened here
			if ext == "dmg" and not (fileName == "Stats.dmg") then hs.open(filep) end
			u.runWithDelays(3, function() os.rename(filep, home .. "/.Trash/" .. fileName) end)

		-- zip: unzip
		elseif ext == "zip" and fileName ~= "violentmonkey.zip" then
			-- done via hammerspoon to differentiate between zips to auto-open and
			-- zips to archive (like violentmonkey)
			hs.open(filep)

		-- ublacklist
		elseif fileName == "ublacklist-settings.json" then
			os.rename(filep, browserSettings .. fileName)
			print("➡️ ublacklist backup")

		-- vimium-c
		elseif fileName:match("vimium_c") then
			os.rename(filep, browserSettings .. "vimium-c-settings.json")
			print("➡️ Vimium-C backup")

		-- adguard
		elseif fileName:match(".*_adg_ext_settings_.*%.json") then
			os.rename(filep, browserSettings .. "adguard-settings.json")
			print("➡️ AdGuard backup")

		-- sponsor block
		elseif fileName:match("SponsorBlockConfig_.*%.json") then
			os.rename(filep, browserSettings .. "SponsorBlock-settings.json")
			print("➡️ SponsorBlockConfig backup")

		-- violentmonkey
		elseif fileName:match("violentmonkey.zip") then
			os.rename(filep, browserSettings .. "violentmonkey.zip")
			print("➡️ Violentmonkey backup")

		-- Inoreader
		elseif fileName:match("Inoreader Feeds .*%.xml") then
			os.rename(filep, browserSettings .. "Inoreader Feeds.opml")
			print("➡️ Inoreader backup")
		end
	end
end):start()

--------------------------------------------------------------------------------
-- AUTO-INSTALL OBSIDIAN ALPHA

ObsiAlphaWatcher = pw(env.fileHub, function(files)
	for _, file in pairs(files) do
		-- needs delay and `.crdownload` check, since the renaming is sometimes not picked up by hammerspoon
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
