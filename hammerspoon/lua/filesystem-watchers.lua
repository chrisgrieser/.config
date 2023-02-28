require("lua.utils")

--------------------------------------------------------------------------------

---@param f string filepath
---@param folder string folderpath
---@return boolean
local function isInSubdirectory(f, folder) -- (instead of directly in the folder)
	local _, fileSlashes = f:gsub("/", "")
	local _, folderSlashes = folder:gsub("/", "")
	return fileSlashes > folderSlashes
end

--------------------------------------------------------------------------------

-- Bookmarks synced to Chrome Bookmarks (needed for Alfred)
local appSupport = os.getenv("HOME") .. "/Library/Application Support/"
local sourceBookmarkPath = appSupport .. "/Vivaldi/Default/Bookmarks"
local sourceStatePath = appSupport .. "/Vivaldi/Local State"
local chromeBookmarksPath = appSupport .. "/Google/Chrome/Default/Bookmarks"
local chromeStatePath = appSupport .. "/Google/Chrome/Local State"

BookmarkWatcher = Pw(sourceBookmarkPath, function()
	-- Bookmarks
	local bookmarks = hs.json.read(sourceBookmarkPath)
	if not bookmarks then return end
	bookmarks.roots.trash = nil -- remove Vivaldi's trash folder for Alfred
	local success = hs.json.write(bookmarks, chromeBookmarksPath, false, true)
	if not success then
		Notify("🔖⚠️ Bookmarks not correctly synced.")
		return
	end

	-- Local State (also required for Alfred to pick up the Bookmarks)
	local file = io.open(sourceStatePath, "r")
	if not file then return end
	local content = file:read("*a")
	file:close()
	WriteToFile(chromeStatePath, content)

	print("🔖 Bookmarks synced to Chrome Bookmarks")
end):start()

--------------------------------------------------------------------------------

-- Download Folder Badge
-- requires "fileicon" being installed
local downloadFolder = os.getenv("HOME") .. "/Downloaded"
DownloadFolderWatcher = Pw(
	downloadFolder,
	function()
		hs.execute("zsh ./helpers/download-folder-badge/download-folder-icon.sh " .. downloadFolder)
	end
):start()

--------------------------------------------------------------------------------

-- FONT rsync (for both directions)
-- (symlinking the Folder somehow does not work properly, therefore rsync)
local fontLocation = DotfilesFolder .. "/fonts/" -- source folder needs trailing "/" to copy contents (instead of the folder)
FontsWatcher1 = Pw(os.getenv("HOME") .. "/Library/Fonts", function()
	hs.execute([[rsync --archive --update --delete "$HOME/Library/Fonts/" "]] .. fontLocation .. [["]])
	Notify("Fonts synced.")
end):start()
FontsWatcher2 = Pw(fontLocation, function()
	hs.execute([[rsync --archive --update --delete "]] .. fontLocation .. [[" "$HOME/Library/Fonts"]])
	Notify("Fonts synced.")
end):start()

--------------------------------------------------------------------------------

-- Redirects TO File Hub
local scanFolder = os.getenv("HOME") .. "/Library/Mobile Documents/iCloud~com~geniussoftware~GeniusScan/Documents/"
ScanFolderWatcher = Pw(scanFolder, function()
	hs.execute("mv '" .. scanFolder .. "'/* '" .. FileHub .. "'")
	Notify("Scan moved to File Hub")
end):start()

local systemDownloadFolder = os.getenv("HOME") .. "/Downloads/"
SystemDlFolderWatcher = Pw(systemDownloadFolder, function(files)
	-- Stats Update file can directly be trashed
	for _, filePath in pairs(files) do
		if filePath:find("Stats%.dmg$") then
			os.execute("sleep 1")
			os.rename(filePath, os.getenv("HOME") .. "/.Trash/Stats.dmg")
			return
		end
	end
	-- otherwise move to filehub
	hs.execute("mv '" .. systemDownloadFolder .. "'/* '" .. FileHub .. "'")
	Notify("Download moved to File Hub.")
end):start()

local draftsIcloud = os.getenv("HOME") .. "/Library/Mobile Documents/iCloud~com~agiletortoise~Drafts5/Documents/"
DraftsIcloudWatcher = Pw(draftsIcloud, function(files)
	for _, filePath in pairs(files) do
		if filePath:sub(-3) ~= ".md" or filePath:find("Inbox") then return end
		hs.execute("mv '" .. draftsIcloud .. "'/*.md '" .. FileHub .. "'")
		Notify("Drafts doc moved to File Hub.")
	end
end):start()

--------------------------------------------------------------------------------

-- Redirects FROM File Hub
local browserSettings = DotfilesFolder .. "/browser-extension-configs/"
WatcherActive = true -- to prevent recursion issues
-- selene: allow(high_cyclomatic_complexity)
FileHubWatcher = Pw(FileHub, function(paths, _)
	for _, filep in pairs(paths) do
		if isInSubdirectory(filep, FileHub) then return end
		local fileName = filep:gsub(".*/", "")
		local extension = fileName:gsub(".*%.", "")

		-- delete alfredworkflows and ics (iCal)
		if extension == "alfredworkflow" or extension == "ics" or extension == "dmg" then
			-- opening ics and Alfred leads to recursions when opened via this file
			-- watcher and are therefore opened via browser auto-open instead. .dmg
			-- though cannot be opened via browser and also does not create recursion,
			-- so it is opened here
			if extension == "dmg" then hs.open(filep) end
			RunWithDelays(3, function() os.rename(filep, os.getenv("HOME") .. "/.Trash/" .. fileName) end)

			-- watch later .urls from the office
		elseif extension == "url" and IsIMacAtHome() then
			os.rename(filep, os.getenv("HOME") .. "/Downloaded/" .. fileName)
			Notify("Watch Later URL moved to Video Downloads.")

		-- ublacklist
		elseif fileName == "ublacklist-settings.json" then
			os.rename(filep, browserSettings .. fileName)
			Notify(fileName .. " filed away.")

		-- vimium-c
		elseif fileName:match("vimium_c") then
			os.rename(filep, browserSettings .. "vimium-c-settings.json")
			Notify("Vimium-C backup filed away.")

		-- adguard
		elseif fileName:match(".*_adg_ext_settings_.*%.json") then
			os.rename(filep, browserSettings .. "adguard-settings.json")
			Notify("AdGuard backup filed away.")

		-- sponsor block
		elseif fileName:match("SponsorBlockConfig_.*%.json") then
			os.rename(filep, browserSettings .. "SponsorBlock-settings.json")
			Notify("SpondorBlockConfig filed away.")

		-- violentmonkey
		elseif fileName:match("violentmonkey") then
			-- `-d` test necessary to rpevent recursion of moving out of directory
			-- also triggering the rm command
			hs.execute("[[ -d '" .. filep .. "' ]] && rm -r '" .. browserSettings .. "violentmonkey'")
			os.rename(filep, browserSettings .. "violentmonkey")
			Notify("Violentmonkey backup filed away.")

		-- Bonjourr
		elseif fileName:match("bonjourrExport%-.*%.json") then
			os.rename(filep, browserSettings .. "bonjourr-settings.json")
			Notify("Bonjourr backup filed away.")

		-- Inoreader
		elseif fileName:match("Inoreader Feeds .*%.xml") then
			os.rename(filep, browserSettings .. "Inoreader Feeds.opml")
			Notify("Inoreader backup filed away.")

		-- visualised keyboard layouts
		elseif
			fileName:match("base%-keyboard%-layout%.%w+")
			or fileName:match("app%-switcher%-layout%.%w+")
			or fileName:match("vimrc%-remapping%.%w+")
			or fileName:match("hyper%-bindings%-layout%.%w+")
			or fileName:match("single%-keystroke%-bindings%.%w+")
		then
			os.rename(filep, DotfilesFolder .. "/visualized-keyboard-layout/" .. fileName)
			Notify("Visualized Keyboard Layout filed away.")
		end
	end
end):start()

--------------------------------------------------------------------------------
-- auto-install Obsidian Alpha builds as soon as the file is downloaded
ObsiAlphaWatcher = Pw(FileHub, function(files)
	for _, file in pairs(files) do
		-- needs delay and `.crdownload` check, since the renaming is sometimes not picked up by hammerspoon
		if not (file:match("%.crdownload$") or file:match("%.asar%.gz$")) then return end
		RunWithDelays(0.5, function()
			hs.execute([[cd "]] .. FileHub .. [[" || exit 1
				test -f obsidian-*.*.*.asar.gz || exit 1
				killall Obsidian
				mv obsidian-*.*.*.asar.gz "$HOME/Library/Application Support/obsidian/"
				cd "$HOME/Library/Application Support/obsidian/"
				rm obsidian-*.*.*.asar
				gunzip obsidian-*.*.*.asar.gz
				while pgrep -q "Obsidian" ; do sleep 0.1; done
				sleep 0.2
				open -a "Obsidian"
			]])
			-- close the created tab
			Applescript([[
				tell application "Vivaldi"
					set window_list to every window
					repeat with the_window in window_list
						set tab_list to every tab in the_window
						repeat with the_tab in tab_list
							set the_url to the url of the_tab
							if the_url contains ("https://cdn.discordapp.com/attachments") then
								close the_tab
							end if
						end repeat
					end repeat
				end tell
			]])
		end)
	end
end):start()
