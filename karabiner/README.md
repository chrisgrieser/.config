# Karabiner Config Infos
Written in YAML, since more readable than JSON. This "source code" of the configs is located in `/assets/complex_modifications/`.

__Quick Reloading setup__
- this triggers script `build-karabiner-config.js`, which converts the YAML to JSON and compiles the `karabiner.json`
- this requires `yq` being installed on the system. [Note that `yd 'explode(.)'` is required to resolve the YAML anchors](https://mikefarah.gitbook.io/yq/operators/anchor-and-alias-operators).
- Note: the rules are added to the *first* profile in the profile list from Karabiner. Also, this method does not create any new automatic backups anymore (this repo is a backup already, making them redundant anyway)
- the `karabiner.json` in turn is live-reloaded by Karabiner by default
