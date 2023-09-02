.PHONY: lines plugins debug
#───────────────────────────────────────────────────────────────────────────────

lines: # prints total length of config
	find . -name "*.lua" | xargs wc -l

plugins: # prints remote repo of all installed plugins as markdown links
	location_of_installed_plugins="$$HOME/.local/share/nvim/lazy" ; \
	cd "$$location_of_installed_plugins" ; \
	grep --only-matching --no-filename --max-count=1 "http.*" ./*/.git/config | \
		sed 's/.git$$//' | \
		cut -c20- | \
		sed -E 's|(.*)|- [\1](https://github.com/\1)|' | \
		sort -i

debug: # runs minimal config for debugging purposes
	export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$$PATH ; \
	neovide ./debug/test.lua -- -u ./debug/repro.lua
