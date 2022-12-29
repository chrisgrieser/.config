#!/usr/bin/env node
'use strict';
const fs = require('fs');
const path = require('path');
const pathExists = require('path-exists');
const mkdirp = require('mkdirp');
const readConfig = require('./utils/read-config');
const {merge} = require('./utils/merge-config');
const textEditor = require('./utils/text-editor');
const workflowData = require('./utils/workflow-data');

const npmGlobal = process.env.npm_config_global;

if (npmGlobal === '') {
	// Prevent linking if the script was part of a non-global npm (install) command
	process.exit(0);
}

const srcPath = path.join(process.cwd(), 'config.json');

if (!pathExists.sync(srcPath)) {
	// No `config.json` file found, gracefully exit because we don't need to merge
	process.exit();
}

(async () => {
	try {
		// Resolve the location of the workflow data
		const workflowDataPath = await workflowData.resolvePath();

		const destPath = path.join(workflowDataPath, 'user-config.json');

		// Read the current user workflow config and the original workflow config
		const currentConfig = readConfig(destPath);
		const srcConfig = readConfig(srcPath);

		// Make sure the target location exists
		mkdirp.sync(path.dirname(destPath));

		// Write the file to the target location
		fs.writeFileSync(destPath, merge(srcConfig, currentConfig));

		// Open the file in the preferred text editor
		textEditor.open(destPath);
	} catch (error) {
		console.error(error);

		process.exit(1);
	}
})();
