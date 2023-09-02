.PHONY: lines reload
#───────────────────────────────────────────────────────────────────────────────

reload: # reload Hammerspoon config
	open -g "hammerspoon://hs-reload"

lines: # total length of config in LoC
	find . -name "*.lua" -not -path "*/Spoons/*" | xargs wc -l
