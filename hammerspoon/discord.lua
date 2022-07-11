require("utils")

function discordWatcher(appName, eventType)
	if appName ~= "Discord" then return end

	-- on launch, open OMG Server instead of friends (who needs friends if you have Obsidian?)
	-- and reconnect Obsidian's Discord Rich Presence (Obsidian launch already covered by RP Plugin)
	if eventType == hs.application.watcher.launched then
		hs.urlevent.openURL("discord://discord.com/channels/686053708261228577/700466324840775831")
		if appIsRunning("Obsidian") then
			runDelayed(2.5, function()
				hs.urlevent.openURL("obsidian://advanced-uri?vault=Main%20Vault&commandid=obsidian-discordrpc%253Areconnect-discord")
				hs.application("Discord"):activate()
			end)
		end

	-- when Discord is focused, enclose URL in clipboard with <>
	elseif eventType == hs.application.watcher.activated then
		local clipb = hs.pasteboard.getContents()
		if not clipb then return end
		local hasURL = string.match(clipb, '^https?%S+$')
		if (hasURL) then
			hs.pasteboard.setContents("<"..clipb..">")
		end

	-- when Discord is unfocused, removes <> from URL in clipboard
	elseif eventType == hs.application.watcher.deactivated then
		local clipb = hs.pasteboard.getContents()
		local hasEnclosedURL = string.match(clipb, '^<https?%S+>$')
		if (hasEnclosedURL) then
			clipb = clipb:sub(2, -2) -- remove first & last character
			hs.pasteboard.setContents(clipb)
		end
	end
end
discordAppWatcher = hs.application.watcher.new(discordWatcher)
discordAppWatcher:start()

