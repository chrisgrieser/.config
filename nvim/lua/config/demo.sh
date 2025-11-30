#!/usr/bin/env zsh


echo "hello" | sed -e 's/hello/hi/g' | cut -d' ' -f2
