#!/usr/bin/env zsh

# shellcheck disable=2154 # alfred var
interval_secs=$((interval_mins * 60))
sleep $interval_secs
