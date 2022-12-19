# nvim-various-textobjs

<!--toc:start-->
- [Text Objects included](#text-objects-included)
- [Installation and Setup](#installation-and-setup)
- [Credits](#credits)
- [About me](#about-me)
<!--toc:end-->

## Text Objects included
- `indentation`: Indentation text object. Similar to [vim-indent-object](https://github.com/michaeljsmith/vim-indent-object), but in written in lua.
- `value`:
- `number`:
- `diagnostic`: Diagnostic from the built-in LSP. Similar to [textobj-diagnostic.nvim](https://github.com/andrewferrier/textobj-diagnostic.nvim).
- `subword`: like `iw`, but treating dashes and underscores always as word delimiters, regardless of the `iskeyword` option.
- `nearEoL`: from cursor position to end of line minus 1 character. Useful to change everything except a trailing comma or semicolon.
- `restOfParagraph`: like `}`, but linewise.

__FileType specific__
- `mdlink`:
- `jsRegex`: 
- `cssSelector`:

## Installation and Setup

```lua
-- packer
use "chrisgrieser/nvim-various-textobjs"
```

A `.setup()` call is not required. It is only needed if you want to change the amount of lines below the cursor where the plugin looks for a text object:

```lua
require("various-textobjs").setup {
	-- default 8. Set to 0 to only look in the current line
	lookForwardLines = 10,
}
```

## Credits
Thanks to the Valuable Dev for [their blogpost on how to get started with creating custom text objects](https://thevaluable.dev/vim-create-text-objects/).

<!-- vale Google.FirstPerson = NO -->
## About me
In my day job, I am a sociologist studying the social mechanisms underlying the digital economy. For my PhD project, I investigate the governance of the app economy and how software ecosystems manage the tension between innovation and compatibility. If you are interested in this subject, feel free to get in touch.

__Profiles__
- [Discord](https://discordapp.com/users/462774483044794368/)
- [Academic Website](https://chris-grieser.de/)
- [GitHub](https://github.com/chrisgrieser/)
- [Twitter](https://twitter.com/pseudo_meta)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)
