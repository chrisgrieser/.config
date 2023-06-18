#!/usr/bin/env zsh

ioreg -r -d 1 -k BatteryPercent | grep -E 'BatteryPercent|Product"' |
	cut -d "=" -f 2 |             # get value
	sed -E 's/^ //' | tr -d '"' | # clean
	sed 'N;s/\n/ /' |             # merge every second line https://stackoverflow.com/a/9605559
	sed -E 's/([0-9]{1,3})/ \1%/' # append percent sign
