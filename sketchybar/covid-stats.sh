#!/usr/bin/env zsh

covid_numbers=$(curl -s "https://api.corona-zahlen.org/germany" | yq -r '.weekIncidence' | cut -d. -f1)
[[ "$covid_numbers" == "null" ]] && covid_numbers="–"

sketchybar --set "covid-stats" label="${covid_numbers}" icon="🦠"
