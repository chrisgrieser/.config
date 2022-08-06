#!/bin/zsh
LAST_FILE=$(ls -td ~/.Trash/* | head -n1)
mv "$LAST_FILE" .
