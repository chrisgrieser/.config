<!-- vale Google.FirstPerson = NO -->
## Plugins

▶️ [Nice overview of my dotfiles](https://dotfyle.com/chrisgrieser/config-nvim).

<!-- vale Vale.Spelling = NO -->
<!-- LTeX: enabled=false -->
Unfortunately, dotfyle's scrapping seems to be a bit off (missing about 40 plugins 😅). You can get a *full* list of all plugins I use directly from the [`lazy.lock`](./lazy-lock.json), and the configs of those plugins can be found in [the plugin folder](./lua/plugins).
<!-- vale Vale.Spelling = YES -->
<!-- LTeX: enabled=true -->

Also, you can check out [the nvim plugins I authored myself](https://github.com/chrisgrieser?tab=repositories&q=nvim&type=source&language=&sort=stargazers).

## Config structure

```text
├── lua
│  ├── config # keybindings, options, …
│  ├── funcs # utility functions
│  └── plugins # plugins & their configs
├── after
│  └── ftplugin # filetype-specific configs
├── mac-helper # for neovide users on macOS
├── snippets
│  ├── basic
│  └── project-specific
└── templates
```
