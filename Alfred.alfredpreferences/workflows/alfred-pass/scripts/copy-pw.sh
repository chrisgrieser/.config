#!/usr/bin/env zsh

echo -n "$(pass show "$*" | head -n1)"
