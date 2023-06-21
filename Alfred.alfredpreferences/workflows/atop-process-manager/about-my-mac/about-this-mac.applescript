#!/usr/bin/env osascript
tell application "Finder"
	set username to long user name of (system info)
	set computername to host name of (system info)
	set ethernet to primary Ethernet address of (system info)
	set ipaddress to IPv4 address of (system info)
	set osver to system version of (system info)
	set cpuType to CPU type of (system info)
	set physicalMemory to physical memory of (system info)
	-- set bootVolume to boot volume of (system info)
	set totalSpace to capacity of (get startup disk)
	set freeSpace to free space of (get startup disk)

	set osName to do shell script "bash ./about-my-mac/os-name.sh"

	set modelName to do shell script "bash ./about-my-mac/mac-model-year.sh"

	set vmStats to (text 12 thru -2 of (do shell script "vm_stat | grep 'Pages free'")) * 4096

	set freeMemory to (round (vmStats / 1.0E+7) / 100)

	set locale to user locale of (get system info)


	set param to (username & "‡" & computername & "‡" & ethernet & "‡" & ipaddress & "‡" & osver & "‡" & cpuType & "‡" & (round (physicalMemory / 1024)) & "‡" & (round (totalSpace / 10E8)) & "‡" & (round (freeSpace / 10E8)))& "‡" & osName& "‡" & freeMemory& "‡" &modelName & "‡" &locale


	set comm to "bash ./about-my-mac/main.sh" & " \"" & param & "\""

	do shell script comm
end tell
