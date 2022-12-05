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
- Finder-Vim-Mode factors in whether you are using Spotlight or Alfred with `cmd+space`. However, if you use another key combination with Alfred (for example for the clipboard or the Universal action), you have to use one of two methods:
	1. (Easier) Temporarily pause Finder-Vim-Mode via `⌫ backspace`, use Alfred, and as soon as you press either `capslock`, `escape`, or `return`, Finder-Vim-Mode will be active again.
	2. Permanently disable Finder-Vim-Mode for the respective Alfred Commands by downloading the [Finder-Vim-Mode-Addon](karabiner/assets/finder-vim-addons.json) and customizing it keys. The `from` and `to` keys need to be the same (except for the extra intermediary `mandatory`), the first example uses modifier keys, the second only a single keystroke.

> __Note__  
> Press `?` in Finder to show the following cheatsheet:

![finder-vim-cheatsheet](/visualized-keyboard-layout/macos-finder-vim-mode.png).
