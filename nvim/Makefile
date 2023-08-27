.PHONY: lines plugins debug
#───────────────────────────────────────────────────────────────────────────────

# prints total length of config
lines:
	find . -name "*.lua" | xargs wc -l

# prints remote repo of all installed plugins
plugins:
	location_of_installed_plugins="$$HOME/.local/share/nvim/lazy" ; \
	cd "$$location_of_installed_plugins" ; \
	grep --only-matching --no-filename --max-count=1 "http.*" ./*/.git/config | \
		sed 's/.git$$//' | \
		sort -i

# runs minimal config for debugging purposes
debug:
	export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$$PATH ; \
	neovide ./debug/test.lua -- -u ./debug/repro.lua
