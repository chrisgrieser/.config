#!/usr/bin/env zsh

# We make the widget's name start with a dot in order to make this plugin
# work with zsh-syntax-highlighting and zsh-autosuggestions.
'builtin' 'autoload' '-Uz' '--' "${${(%):-%x}:A:h}/zsh-no-ps2" &&
'builtin' 'zle' '-N' '.zsh-no-ps2' 'zsh-no-ps2'                &&
'builtin' 'bindkey' '^J' '.zsh-no-ps2'                         &&
'builtin' 'bindkey' '^M' '.zsh-no-ps2'
