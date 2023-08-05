#!/usr/bin/env zsh

dns_address="$*"
networksetup -setdnsservers Wi-Fi $dns_address
networksetup -setdnsservers Ethernet $dns_address
