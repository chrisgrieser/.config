.PHONY: reload list_menubar_items

# alternatively, use `sketchybar --hotload`
reload:
	sketchybar --reload
	echo " sketchybar config"

restart:
	brew services restart sketchybar

# used for aliases
list_menubar_items:
	sketchybar --query default_menu_items | sed '1d;$$d' | cut -d'"' -f2
