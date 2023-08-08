#!/usr/bin/env zsh

dns_address_1="$1"
dns_address_2="$2"

# switch on all available network services
# NOTE this includes disabled ones for consistency
networksetup -listallnetworkservices | # list all
	tail -n +2 | # skip info text
	tr -d "*" | # remove "*" marking disabled services
	xargs -I {} networksetup -setdnsservers {} "$dns_address_1" "$dns_address_2"
