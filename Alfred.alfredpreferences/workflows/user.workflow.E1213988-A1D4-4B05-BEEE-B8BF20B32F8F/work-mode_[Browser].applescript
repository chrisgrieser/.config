-- some aspects of this script depend on the device used
set isOffice to (computer name of (system info) is "Christopher’s Mac mini")

if (isOffice is true) then
	set draftWorkspace to "Office"
	set twitterApp to "Tweetdeck"
else
	set draftWorkspace to "Home"
	set twitterApp to "Twitterrific"
end if

-- Start apps
tell application "Mimestream" to if it is not running then activate
tell application "Slack" to if it is not running then activate
tell application "Discord" to if it is not running then activate
tell application twitterApp to if it is not running then activate
tell application "Obsidian" to if it is not running then activate
if (isOffice is false) then
	-- start Spotify
	tell application id "com.runningwithcrayons.Alfred" to run trigger "play" in workflow "com.vdesabou.spotify.mini.player"
	-- kill Zoom
	do shell script ("killall 'zoom.us' || true")
	-- Scroll Twitter up
	tell application "System Events"
		set frontApp to (name of first process where it is frontmost)
		tell application twitterApp to activate
		delay 0.05
		# has to be keystrokes, since headless the app does not have menubar items to be clicked
		keystroke "k" using {command down} -- mark as read
		keystroke "j" using {command down} -- jump to unread
		keystroke "1" using {command down} -- scroll up
	end tell
	delay 0.05
	tell application frontApp to activate

end if

-- Reset Drafts
tell application "Drafts" to open location ("drafts://x-callback-url/runaction?&action=Workspace-" & draftWorkspace)

try
	tell application "System Events"
		tell process "Drafts"
			set frontmost to true
			click menu item "Hide Toolbar" of menu "View" of menu bar 1
		end tell
	end tell
end try
