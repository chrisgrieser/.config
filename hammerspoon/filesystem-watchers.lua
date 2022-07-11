require("utils")

home = os.getenv("HOME")
fileHub = home.."/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"

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

-- Folder Redirects to File Hub
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

function autoRemoveFromFileHub(files)
	for _,file in pairs(files) do
		if file:sub(-15) == ".alfredworkflow" then
			hs.applescript(
			   'delay 3\n'.. -- delay so auto-opening still works
				'set toDelete to "'..file..'" as POSIX file\n'..
				'tell application "Finder" to delete toDelete'
			)
		end
	end
end
fileHubWatcher = hs.pathwatcher.new(fileHub, autoRemoveFromFileHub)
fileHubWatcher:start()

