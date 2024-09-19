#!/usr/bin/env zsh
# INFO Kyoko is the only Japanese voice on macOS, apparently

word=$1
say --voice=Kyoko --rate= "$word" &
