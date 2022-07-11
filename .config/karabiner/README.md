# Karabiner Config Infos
- Written in yaml, since more readable than JSON. This "source code" of the configs is located in `/assets/complex_modifications/`.
- Quick Refreshing setup
	- To trigger refreshing via Sublime from one hotkey `/Sublime User Folder/Build Karabiner Config.sublime-build`
	- this triggers the yaml to json script that uses `yq`: `/Alfred.alfredpreferences/workflows/user.workflow.1E686C4E-854B-4D9F-B761-EF7F221841A8/yaml2json.sh`
	- afterwards, a script runs that uses the created JSON and "compiles" them into the `karabiner.json`: `/Alfred.alfredpreferences/workflows/user.workflow.1E686C4E-854B-4D9F-B761-EF7F221841A8/build-karabiner-config.js` (Note: the rules are added to the *first* profile in the profile list from Karabiner.)
	- the `karabiner.json` in turn is live-reloaded by Karabiner by default
- However, with this setup, any visitor of this GitHub repo can still take the JSON files located in `/assets/complex_modifications/` and import them in Karabiner.
