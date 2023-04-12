## Plugins

▶️ [Nice overview of my dotfiles](https://dotfyle.com/chrisgrieser/config-nvim).

Unfortunately, dotfyle's scrapping seems to be a bit off (missing about 40 plugins 😅). You can get a *full* list of all plugins I use directly from the [lazy.lock](./lazy-lock.json), and the configs of those plugins can be found in [the plugins folder](./lua/plugins)

Also, you can check out [the plugins I authored myself](https://github.com/chrisgrieser?tab=repositories&q=nvim&type=source&language=&sort=stargazers).

## nvim config structure

```bash
├── lua
│  ├── config # keybingings, options, …
│  ├── funcs # utitily functions
│  └── plugins # plugins & their configs
├── after
│  └── ftplugin # filetype-specific configs
├── mac-helper
├── snippets
│  ├── basic
│  └── project-specific
└── templates
```
