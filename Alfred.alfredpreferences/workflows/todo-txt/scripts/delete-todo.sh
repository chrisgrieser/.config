#!/usr/bin/env zsh

line_no=$1

# shellcheck disable=2154
sed -i '' "${line_no}d" "$todotxt_filepath"
