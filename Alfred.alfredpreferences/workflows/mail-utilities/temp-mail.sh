#!/usr/bin/env zsh
# shellcheck disable=2002

# PASSWORD
password=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | head -c 32)
echo -n "${password}"
echo -n "$password" | pbcopy

#───────────────────────────────────────────────────────────────────────────────
# MAIL
# based on https://alfred.app/workflows/vitor/temporary-email/

email_name=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | head -c 25)
# shellcheck disable=2154
readonly email="${email_name}@${email_service}"

if [[ "${email_service}" == 'maildrop.cc' ]]; then
	readonly url="https://${email_service}/inbox/?mailbox=${email_name}"
else
	readonly url="https://${email_service}/inbox/${email_name}"
fi

echo -n "$email"
echo -n "$email" | pbcopy
osascript -e "display notification \"$email\" with title \"Temp Mail & Password copied\""

#───────────────────────────────────────────────────────────────────────────────
# OPEN MAIL IN BROWSER
# Use AppleScript instead of JXA because the latter cannot create tabs at specific indexes
# Call it via the shell because otherwise the code is complicated by "using terms from"
# which requires a specific browser to be installed
front_browser="$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')"

if [[ "${front_browser}" == 'Safari'* || "${front_browser}" == 'Webkit'* ]]; then
	osascript -e "
	tell application \"${front_browser}\" to tell front window
		set tabIndex to index of current tab
		make new tab at after tab tabIndex with properties {URL:\"${url}\"}
	end tell
  " >/dev/null # Ignore stdout, otherwise tab info is printed
elif [[ "${front_browser}" == 'Google Chrome'* || "${front_browser}" == 'Chromium'* || "${front_browser}" == 'Opera'* || "${front_browser}" == 'Vivaldi'* || "${front_browser}" == 'Brave Browser'* || "${front_browser}" == 'Microsoft Edge'* ]]; then
	osascript -e "
	tell application \"${front_browser}\" to tell front window
		set tabIndex to active tab index
		make new tab at after tab tabIndex with properties {URL:\"${url}\"}
		set active tab index to tabIndex
	end tell"
# As of Orion 0.99.124.1 and Arc 0.105.3, neither exposes tab indexes via AppleScript
elif [[ "${front_browser}" == 'Orion' || "${front_browser}" == 'Arc' ]]; then
	osascript -e "
	tell application \"${front_browser}\" to tell front window
		make new tab with properties {URL:\"${url}\"}
	end tell" >/dev/null # Ignore stdout, otherwise tab info is printed
# Browser without AppleScript support, such as Firefox
else
	open "${url}"
fi

