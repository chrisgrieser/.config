#!/bin/zsh

zmodload zsh/datetime

readonly source="./src/Access.swift"
readonly exec="${source:h}/${source:t:r}"
readonly DEBUG="${alfred_debug:-0}"

# Utility functions
clock() { echo $EPOCHREALTIME }
stamp() { strftime %H:%M:%S.%3. }
stale() { (($(date -r "$1" +%s) > $(date -r "$2" +%s))) }
tick()  { printf "%.0f" $(( ($(clock) - $1) * 1000 )) }
mask()  { printf '%s' "${1//$HOME/~}"}
log()   { [[ $DEBUG -eq 1 ]] && echo >&2 "[$(stamp)] $1" }

[[ $DEBUG -eq 1 ]] && echo >&2 "·"
if command -v xcrun &>/dev/null && xcrun --find swiftc &>/dev/null; then
    if [[ -f $exec ]] && ! $(stale $source $exec); then
        log "[Info] run: binary $(mask $exec)"
        start=$(clock)
        $exec
        log "[Info] ran: binary (took: $(tick $start)ms)"
    else
        log "[Info] compile: script $(mask $source)"
        start=$(clock)
        (   # background compilation
            xcrun swiftc -O $source -o $exec >/dev/null 2>&1 &
        ) >/dev/null 2>&1 &
        log "[Info] run: script ($(tick $start)ms after compilation started)"
        xcrun swift $source # immediate execution
        log "[Info] ran: script ($(tick $start)ms after compilation started)"
    fi
else
    log "[Info] run: script $(mask $source)"
    start=$(clock)
    swift $source # fallback to direct execution (slow)
    log "[Info] ran: script (took: $(tick $start)ms)"
fi
