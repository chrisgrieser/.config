# resolve-alfred-prefs [![Build Status](https://travis-ci.org/SamVerschueren/resolve-alfred-prefs.svg?branch=master)](https://travis-ci.org/SamVerschueren/resolve-alfred-prefs)

> Resolve the path of `Alfred.alfredpreferences`


## Install

```
$ npm install resolve-alfred-prefs
```


## Usage

```js
const resolveAlfredPrefs = require('resolve-alfred-prefs');

(async () => {
	console.log(await resolveAlfredPrefs());
	// If Alfred 4 or newer
	//=> {path: '/Users/sam/Dropbox/Alfred.alfredpreferences'}

	// If Alfred 3
	//=> {version: 3, path: '/Users/sam/Dropbox/Alfred.alfredpreferences'}
})();
```


## API

### resolveAlfredPrefs()

Returns an `object` with:

- `version` _(String)_ - The key will pesent if the Alfred version is 3.
- `path` _(String)_ - The `Alfred.alfredpreferences` path.


## License

MIT © [Sam Verschueren](https://github.com/SamVerschueren)
