# Karabiner Config Infos
Written in YAML, since more readable than JSON. This "source code" of the configs is located in `/assets/complex_modifications/`.

__Quick Reloading setup__
- this triggers script `build-karabiner-config.js`, which converts the YAML to json and compiles the `karabiner.json`
- this requires `yq` being installed on the system. [Note that `yd 'explode(.)'` is required to resolve the YAML anchors.](https://mikefarah.gitbook.io/yq/operators/anchor-and-alias-operators).
- Note: the rules are added to the *first* profile in the profile list from Karabiner. Also, this method does not create any new automatic backups anymore (this could be implemented, but I backup via git already anyways)
- the `karabiner.json` in turn is live-reloaded by Karabiner by default


## Vim Mode for macOS Finder

Keyboard-only control of macOS' Finder, inspired by vim/ranger. Install via:

```bash
open "karabiner://karabiner/assets/complex_modifications/import?url=https://raw.githubusercontent.com/chrisgrieser/.config/main/karabiner/assets/finder-vim.json"
curl -sL "https://raw.githubusercontent.com/chrisgrieser/.config/main/visualized-keyboard-layout/macos-finder-vim-mode.png" -o "$HOME/.config/karabiner/assets/macos-finder-vim-mode.png"
```

- To be used in `List View` only. 
- if you have a complex modification affecting the capslock key, it has to come __after__ Finder Vim Controls in Karabiner's priority list.
- Press `?` in Finder to show the following cheatsheet:

![finder-vim-cheatsheet](/visualized-keyboard-layout/macos-finder-vim-mode.png).
