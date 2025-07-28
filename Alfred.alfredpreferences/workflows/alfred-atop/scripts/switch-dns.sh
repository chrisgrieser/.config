#!/usr/bin/env zsh

dns_address_1="$1"
dns_address_2="$2"

# switch on CURRENT available network services to prevent unnecessary change
scutil --nwi |
	awk -F': ' '/Network interfaces/ {print $2;}' |
	sed 's/ /\n/g' |
	while read -r interface; do
		networksetup -listnetworkserviceorder |
			awk "/Device: $interface)/{print a}{a=\$0}" |
			sed 's/([0-9]*)//g' |
			while read -r networkservicename; do
				if [[ -z "$dns_address_1" && -z "$dns_address_2" ]]; then
					networksetup -setdnsservers "$networkservicename" empty
				else
					networksetup -setdnsservers "$networkservicename" "$dns_address_1" "$dns_address_2"
				fi
			done
	done
