#!/usr/bin/env zsh

input="$*"
var1=${input%-*}
var2=${input#*-}
