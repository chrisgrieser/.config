.PHONY: reload_karabiner

reload_karabiner:
	osascript -l JavaScript ./build-karabiner-config.js

show_leader_keys:
	yq '.rules[1].manipulators[].description' \
		"./assets/complex_modifications/2 ctrl-leader.yaml" | sort -f
