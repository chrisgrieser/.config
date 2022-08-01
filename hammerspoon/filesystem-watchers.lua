require("utils")

home = os.getenv("HOME")
fileHub = home.."/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"

--------------------------------------------------------------------------------

-- BRAVE Bookmarks synced to Chrome Bookmarks (needed for Alfred)
function bookmarkSync()
	hs.execute([[
		BROWSER="BraveSoftware/Brave-Browser"
		mkdir -p "$HOME/Library/Application Support/Google/Chrome/Default"
		cp "$HOME/Library/Application Support/$BROWSER/Default/Bookmarks" "$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks"
		cp "$HOME/Library/Application Support/$BROWSER/Local State" "$HOME/Library/Application Support/Google/Chrome/Local State"
	]])
end
BrowserBookmarks = home.."/Library/Application Support/BraveSoftware/Brave-Browser/Default/Bookmarks"
bookmarkWatcher = hs.pathwatcher.new(BrowserBookmarks, bookmarkSync)
bookmarkWatcher:start()

--------------------------------------------------------------------------------

-- Download Folder Badge
function downloadFolderBadge ()
	-- requires "fileicon" being installed
	hs.execute([[
		export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
		folder="$HOME/Video/Downloaded"
		icons_path="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Custom Icons/Download Folder"
		itemCount=$(ls "$folder" | wc -l)
		itemCount=$((itemCount-1)) # reduced by one to account for the "?Icon" file in the folder

		# cache necessary to prevent recursion of icon change triggering pathwatcher again
		cache_location="/Library/Caches/dlFolderLastChange"
		if test ! -e "$cache_location" ; then
			if test $itemCount -gt 0 ; then
				echo "badge" > "$cache_location"
			else
				touch "$cache_location"
			fi
		fi
		last_change=$(cat "$cache_location")

		# using test instead of square brackets cause lua
		if test $itemCount -gt 0 && test -z "$last_change" ; then
			fileicon set "$folder" "$icons_path/with Badge.icns"
			echo "badge" > "$cache_location"
			killall Dock
		elif test $itemCount -eq 0 && test -n "$last_change" ; then
			fileicon set "$folder" "$icons_path/without Badge.icns"
			echo "" > "$cache_location"
			killall Dock
		fi
	]])
end
downloadFolderWatcher = hs.pathwatcher.new(home.."/Video/Downloaded", downloadFolderBadge)
if isIMacAtHome() then downloadFolderWatcher:start() end

--------------------------------------------------------------------------------

-- Redirects TO File Hub
scanFolder = home.."/Library/Mobile Documents/iCloud~com~geniussoftware~GeniusScan/Documents/"
function scanFolderMove()
	hs.execute("mv '"..scanFolder.."'/* '"..fileHub.."'")
end
scanFolderWatcher = hs.pathwatcher.new(scanFolder, scanFolderMove)
scanFolderWatcher:start()

systemDownloadFolder = home.."/Downloads/"
function systemDlFolderMove()
	hs.execute("mv '"..systemDownloadFolder.."'/* '"..fileHub.."'")
end
systemDlFolderWatcher = hs.pathwatcher.new(systemDownloadFolder, systemDlFolderMove)
systemDlFolderWatcher:start()

function isInSubdirectory (file, folder) -- (instead of directly in the folder)
	local _, fileSlashes = file:gsub("/", "")
	local _, folderSlashes = folder:gsub("/", "")
	return fileSlashes > folderSlashes
end

-- Redirects FROM File Hub
function fromFileHub(files)
	for _,file in pairs(files) do

		if isInSubdirectory(file, fileHub) then return end
		fileName = file:gsub(".*/","")

		if fileName:sub(-15) == ".alfredworkflow" or fileName:sub(-4) == ".ics" then
			runDelayed(3, function ()
				hs.applescript('set toDelete to "'..file..'" as POSIX file\n'..
					'tell application "Finder" to delete toDelete')
			end)
		elseif fileName == "vimium-options.json" then
			hs.execute("mv -f '"..file.."' \"$HOME/dotfiles/Browser Extension Settings/\"")
		end
	end
end
fileHubWatcher = hs.pathwatcher.new(fileHub, fromFileHub)
fileHubWatcher:start()

