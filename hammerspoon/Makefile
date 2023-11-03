.PHONY: lines reload
#───────────────────────────────────────────────────────────────────────────────

reload: # reload Hammerspoon config
	open -g "hammerspoon://hs-reload"
	echo " Hammerspoon config"

lines: # total length of config in LoC
	echo ;\
	find . -name "*.lua" -not -path "*/Spoons/*" | xargs wc -l | sort -r
