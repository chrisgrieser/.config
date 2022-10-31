'use strict';
const path = require('path');
const dotProp = require('dot-prop');
const readConfig = require('./utils/read-config');

const getEnv = key => process.env[`alfred_${key}`] || '';

class WorkflowConfig {
	constructor(options) {
		const opts = {
			cwd: getEnv('workflow_data'),
			...options
		};

		const configFile = path.join(opts.cwd, 'user-config.json');

		this.store = readConfig(configFile);
	}

	get(key, defaultValue) {
		return dotProp.get(this.store, key, defaultValue);
	}

	has(key) {
		return dotProp.has(this.store, key);
	}

	get size() {
		return Object.keys(this.store).length;
	}

	* [Symbol.iterator]() {
		for (const [key, value] of Object.entries(this.store)) {
			yield [key, value];
		}
	}
}

module.exports = WorkflowConfig;
