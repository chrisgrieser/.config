.PHONY: lines, startup
#───────────────────────────────────────────────────────────────────────────────
# total length of config in LoC
lines:
	find . -name "*.zsh" -or -name ".zsh*" -type f -maxdepth 1 | xargs wc -l | tail -n1 | xargs

# measure shell startup time, https://blog.jonlu.ca/posts/speeding-up-zsh
startup:
	hyperfine "$$SHELL -i -c exit"
	# time $SHELL -i -c exit
