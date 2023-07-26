.PHONY: lines
#───────────────────────────────────────────────────────────────────────────────
# total length of config in LoC
lines:
	find . -name "*.lua" | xargs wc -l | tail -n1

plugins:
	location_of_installed_plugins="$$HOME/.local/share/nvim/lazy" ; \
	cd "$$location_of_installed_plugins" ; \
	grep --only-matching --no-filename --max-count=1 "http.*" ./*/.git/config | \
		sed 's/.git$$//' | \
		sort -i

debug:
	export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; \
	neovide test.lua -- -u repro.lua
