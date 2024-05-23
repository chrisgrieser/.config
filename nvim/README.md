<!-- LTeX: enabled=false -->
# nvim-dr-lsp 👨‍⚕️👩‍⚕️
<!-- LTeX: enabled=true -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-dr-lsp">
<img alt="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-dr-lsp/shield"/></a>

`D`efinitions and `R`eferences utility for the LSP.

Lightweight plugin that highlights definitions and references of the word under
the cursor and displays their count in the statusline.

![Showcase](https://github.com/chrisgrieser/nvim-dr-lsp/assets/73286100/8c6600c8-b16d-434f-8bdb-47b4a9dab7cb)

<!-- toc -->

- [Statusline Component](#statusline-component)
- [Installation](#installation)
- [Highlights of definitions and references](#highlights-of-definitions-and-references)
- [Definition and reference count in the statusbar](#definition-and-reference-count-in-the-statusbar)
- [Similar Plugins](#similar-plugins)
- [Credits](#credits)

<!-- tocstop -->

## Installation
The plugin requires at least nvim 0.10.

```lua
-- lazy.nvim
{ "chrisgrieser/nvim-dr-lsp" },

-- packer
use { "chrisgrieser/nvim-dr-lsp" }
```

There is no `.setup` call for this plugin. Just add the components to your
statusline.

## Highlights of definitions and references
- Definitions are under-dashed, references are under-dotted.
- These are set up automatically for you as soon as the buffer is attached to an
  LSP client.
- To disable the highlights feature, set `vim.g.dr_lsp_no_highlight = true`
  before loading the plugin.

## Definition and reference count in the statusbar

Definitions and references **inside** current buffer:

```text
LSP: 2D 6R
```

Definitions or references **outside** current buffer:

```text
LSP: 1(2)D 4(10)R
```

- 1 definition in the current buffer
- 2 definitions in the workspace
- 4 references in the current buffer
- 10 definitions in the workspace

```lua
-- adding the component to lualine.nvim
{
	sections = {
		lualine_c = {
			{ require("dr-lsp").lspCount },
		},
	}
}
```

There are no built-in options to format the components, since formatting can
already be done with most statusline plugins. With `Lualine`, for example, you can
use the [`fmt` option](https://github.com/nvim-lualine/lualine.nvim#global-options):

```lua
lualine_c = {
	{ 
		require("dr-lsp").lspCount, 
		-- remove the letters from the component
		fmt = function(str) return str:gsub("[RD]", "") end,
	},
},
```

Alternatively, `require("dr-lsp").lspCountTable()` returns the `lspCount`
information as lua table for custom formatting:

```lua
{
	file = {
		definitions = 1,
		references = 4,
	},
	workspace = {
		definitions = 2,
		references = 10,
	},
}
```

## Similar Plugins
- [LSP-Lens](https://github.com/VidocqH/lsp-lens.nvim)
- [action-hints.nvim](https://github.com/roobert/action-hints.nvim)
- [symbol-usage.nvim](https://github.com/Wansmer/symbol-usage.nvim)

<!-- vale Google.FirstPerson = NO -->
## Credits
In my day job, I am a sociologist studying the social mechanisms underlying the
digital economy. For my PhD project, I investigate the governance of the app
economy and how software ecosystems manage the tension between innovation and
compatibility. If you are interested in this subject, feel free to get in touch.

- [Academic Website](https://chris-grieser.de/)
- [Mastodon](https://pkm.social/@pseudometa)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'>
<img
	height='36'
	style='border:0px;height:36px;'
	src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
	border='0'
	alt='Buy Me a Coffee at ko-fi.com'
/></a>
