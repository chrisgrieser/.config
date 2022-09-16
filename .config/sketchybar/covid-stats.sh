#!/usr/bin/env sh

covid_numbers=$(curl -s "https://api.corona-zahlen.org/germany" | yq -r '.weekIncidence' | cut -d. -f1)

sketchybar --set "$NAME" label="${covid_numbers}✦ "



