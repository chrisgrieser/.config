.PHONY: lines
#───────────────────────────────────────────────────────────────────────────────
# total length of config in LoC
lines:
	find . -name "*.lua" | xargs wc -l | tail -n1

plugins:
	plugin_dir="$$HOME/.local/share/nvim/lazy" ; \
	cd "$$plugin_dir" ; \
	grep --only-matching --no-filename --max-count=1 "http.*" ./*/.git/config | \
	cut 

