.PHONY: lines startup
#───────────────────────────────────────────────────────────────────────────────
# total length of config in LoC
lines:
	find . -name "*.zsh" -or -name ".zsh*" -maxdepth 1 | xargs wc -l | sort -r

# measure shell startup time, https://blog.jonlu.ca/posts/speeding-up-zsh
startup:
	hyperfine "$$SHELL -i -c exit"
