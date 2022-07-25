require("utils")

function discordWatcher(appName, eventType)
	if appName ~= "Discord" then return end

	-- on launch, open OMG Server instead of friends (who needs friends if you have Obsidian?)
	-- and reconnect Obsidian's Discord Rich Presence (Obsidian launch already covered by RP Plugin)
	if eventType == hs.application.watcher.launched then
		hs.urlevent.openURL("discord://discord.com/channels/686053708261228577/700466324840775831")
		if appIsRunning("Obsidian") then
			runDelayed(3, function()
				if appIsRunning("Obsidian") then return end
				hs.urlevent.openURL("obsidian://advanced-uri?vault=Main%20Vault&commandid=obsidian-discordrpc%253Areconnect-discord")
				hs.application("Discord"):activate()
			end)
		end
	end

	-- when Discord is focused, enclose URL in clipboard with <>
	-- when Discord is unfocused, removes <> from URL in clipboard
	local clipb = hs.pasteboard.getContents()
	if not (clipb) then return end

	if eventType == hs.application.watcher.activated then
		local hasURL = clipb:match('^https?:%S+$')
		local hasObsidianURL = clipb:match('^obsidian:%S+$')
		if hasURL or hasObsidianURL then
			hs.pasteboard.setContents("<"..clipb..">")
		end
	elseif eventType == hs.application.watcher.deactivated then
		local hasEnclosedURL = clipb:match('^<https?:%S+>$')
		local hasEnclosedObsidianURL = clipb:match('^<obsidian:%S+>$')
		if hasEnclosedURL or hasEnclosedObsidianURL then
			clipb = clipb:sub(2, -2) -- remove first & last character
			hs.pasteboard.setContents(clipb)
		end
	end
end
discordAppWatcher = hs.application.watcher.new(discordWatcher)
discordAppWatcher:start()

