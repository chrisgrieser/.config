#!/usr/bin/env zsh

dns_address_1=$1
dns_address_2=$2

networksetup -setdnsservers Wi-Fi "$dns_address_1" "$dns_address_2"
networksetup -setdnsservers Ethernet "$dns_address_1" "$dns_address_2"
