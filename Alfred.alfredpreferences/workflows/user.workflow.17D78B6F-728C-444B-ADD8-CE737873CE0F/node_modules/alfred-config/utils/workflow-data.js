'use strict';
const fs = require('fs');
const path = require('path');
const resolveAlfredPrefs = require('resolve-alfred-prefs');
const plist = require('plist');

/**
 * Resolves the data path of the workflow. This value is identical to `process.env.alfred_workflow_data`.
 */
exports.resolvePath = async () => {
	const {path: alfredPrefs} = await resolveAlfredPrefs();

	// Read the `info.plist` file
	const plistContent = fs.readFileSync(path.join(process.cwd(), 'info.plist'), 'utf8');

	// Extract the `bundleid` information
	const {bundleid} = plist.parse(plistContent);

	return path.join(path.dirname(alfredPrefs), 'Workflow Data', bundleid);
};
