# alfred-config ![Build Status](https://github.com/SamVerschueren/alfred-config/workflows/CI/badge.svg)

> Allow easy user configurations for your [Alfred](https://www.alfredapp.com/) workflows


## Install

```
$ npm install --save alfred-config
```


## Usage

Add the `alfred-config` command as `postinstall` script of your Alfred package.

```json
{
	"name": "alfred-unicorn",
	"scripts": {
		"postinstall": "alfred-config"
	}
}
```

After installing the `alfred-unicorn` package, the system will open the text editor and allows your user to change the provided workflow configuration.

### Workflow configuration

A workflow configuration is defined by a JSON file which allows comments.

```js
{
	// GitHub API key
	"apiKey": "",

	// Throttling rate (requests per second)
	"throttling": 50,

	// GitHub user information
	"user": {
		"name": "",
		"email": ""
	}
}
```

You can provide defaults as well which the user can change after installing the package.

When your workflow evolves over time, you can add more properties or even remove deprecated ones. It will automatically merge the old user provided configuration with the new workflow configuration, removing unused properties.


## Related

- [alfy](https://github.com/sindresorhus/alfy) - Create Alfred workflows with ease


## License

MIT © [Sam Verschueren](https://github.com/SamVerschueren)
