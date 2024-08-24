# <img src="https://user-images.githubusercontent.com/481362/209873324-855bb383-5998-4377-90ee-5bee67d5cc79.png" width="24" height="24"/> Alfred-UTF: Unicode Character Search ![Version badge](https://shields.io/github/v/release/adamkiss/alfred-utf?display_name=tag&include_prereleases&sort=semver)

![Alfred-utf - workflow screenshot](https://repository-images.githubusercontent.com/583129173/ac6a122c-d1a4-4e7d-aaf8-cfaf4141997c)

Simple workflow to replace now defunct Python 2 workflow. Uses pure SQLite3 - with fts5 and json1 extensions - which is still packaged with MacOS, unlike PHP or Python 2 in versions of MacOS 13+.

## Usage

### Search/show:

- `utf right arr` - Search for a Unicode character by full-text matched name, alternative name, html entity or hexadecimal code
- `utf !<character>` - Get details for a single exact character, except
- `utf !h` - get HELP!
- `utf9` - Your top 9 Unicode characters

### Result Actions:
- Default action: copy the character (e.g. `!`)
- <kbd>Cmd</kbd> - copy the HTML version (e.g. `&excl;`)
- <kbd>Option</kbd> - copy the Unicode point for js/python/… (e.g. `\u0021`)
- <kbd>Option</kbd><kbd>Cmd</kbd> - copy the Unicode point for PHP (e.g. `\u{0021}`)
- <kbd>Ctrl</kbd> - copy the hex value(e.g. `21`) 
- <kbd>Option</kbd><kbd>Ctrl</kbd> - copy the full code point (e.g. `0021`) 
- Use Copy result (<kbd>Cmd</kbd>+<kbd>C</kbd>) to copy the character name (e.g. `exclamation mark`)

↳ Result actions (except Copy result <kbd>Cmd</kbd>+<kbd>C</kbd>) also paste to the frontmost app

### Tips

- `utf u0027` - you can prefix the full codepoint with `u`, and the matcher will mostly match this to the character's json value (`\u0027`), which means you get "find a Unicode codepoint" function for free
- `utf larr` - one of the fields matched are html entities - use this for a precise and quick matching
- `utf :raw* query*` - if you prefix your query with a colon, you'll gain access to the underlying technology - and you get to write raw SQLite FTS5 Match Query. Use this power for good

## Installation

1. Download the workflow
2. Use the workflow

## License

MIT License - see [LICENSE](./LICENSE)
© 2022 Adam Kiss. Databased was sourced with [Uni by Martin Tournoij](https://github.com/arp242/uni)