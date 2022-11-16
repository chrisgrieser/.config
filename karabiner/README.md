# Karabiner Config Infos
- Written in yaml, since more readable than JSON. This "source code" of the configs is located in `/assets/complex_modifications/`.
- Quick Reloading setup
	- To trigger refreshing via Sublime from one hotkey `/Sublime User Folder/Build Karabiner Config.sublime-build`
	- this triggers script `build-karabiner-config.js`, which converts the yaml to json and compiles the `karabiner.json`
	- this requires `yq` being installed on the system
	- Note: the rules are added to the *first* profile in the profile list from Karabiner. Also, this method does not create any new automatic backups anymore (this could be implemented, but I backup via git already anyways)
	- the `karabiner.json` in turn is live-reloaded by Karabiner by default
- With this setup, any visitor of this GitHub repo can still take the JSON files located in `/assets/complex_modifications/` and import them in Karabiner.
