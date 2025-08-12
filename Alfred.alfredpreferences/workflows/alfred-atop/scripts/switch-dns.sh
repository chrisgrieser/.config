#!/usr/bin/env zsh

dns_address_1="$1"
dns_address_2="$2"

# switch on ALL available network services
# (This is to avoid inconsistencies of different services with different dns
# settings. Also, the `select-dns-server.js` just looks for the first enabled
# services to decide which is the currently active DNS.)
networksetup -listallnetworkservices | # list all
	tail -n +2 |                          # skip info text
	tr -d "*" |                           # remove "*" marking disabled services
	while read -r service; do
		if [[ -z "$dns_address_1" && -z "$dns_address_2" ]]; then
			networksetup -setdnsservers "$service" empty
		else
			networksetup -setdnsservers "$service" "$dns_address_1" "$dns_address_2"
		fi
	done
