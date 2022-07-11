#!/bin/zsh

subl --command copy_path
sleep 0.1
open -a "TableFlip" "$(pbpaste)"
