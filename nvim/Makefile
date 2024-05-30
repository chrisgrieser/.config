.PHONY: count-lines update-plugins debug
#───────────────────────────────────────────────────────────────────────────────

# prints total length of config
count-lines:
	echo ;\
	find . -name "*.lua" | xargs wc -l | sort --reverse

# updates README.md with current list of installed plugins
update-plugins:
	nvim_readme="$$HOME/.config/nvim/README.md" ; \
	last_line_before_plugins="## All installed plugins" ; \
	location_of_installed_plugins="$$HOME/.local/share/nvim/lazy" ; \
	\
	sed -i -e -n "1,/$$last_line_before_plugins/p" "$$nvim_readme" ; \
	\
	cd "$$location_of_installed_plugins" ; \
	grep --only-matching --no-filename --max-count=1 "url = .*" ./*/.git/config | \
		sed 's/.git$$//' | cut -c7- | \
		sed -E 's|https://github.com/(.*/.*)|- [\1](&)|' | \
		sort --ignore-case >> "$$nvim_readme" ; \
	\
	[[ "$(uname)" == "Darwin" ]] && open "$$nvim_readme"

# runs minimal config for debugging purposes with neovide
debug:
	export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$$PATH ; \
	neovide --no-tabs ./debug/test.lua -- -u ./debug/repro.lua &>/dev/null
