'use strict';
const fs = require('fs');
const path = require('path');
const pify = require('pify');
const userHome = require('user-home');
const bplistParser = require('bplist-parser');
const untildify = require('untildify');

const bplist = pify(bplistParser);
const settings = path.join(userHome, '/Library/Preferences/com.runningwithcrayons.Alfred-Preferences-3.plist');
const prefsJsonPath = path.join(userHome, '/Library/Application Support/Alfred/prefs.json');

module.exports = async () => {
	let data;
	let errorMessage;

	try {
		const prefsPath = JSON.parse(fs.readFileSync(prefsJsonPath)).current;

		return {
			path: prefsPath
		};
	} catch (error) {
		errorMessage = `Alfred preferences not found at location ${prefsJsonPath}`;
	}

	try {
		data = await bplist.parseFile(settings);

		const syncfolder = data[0].syncfolder || '~/Library/Application Support/Alfred 3';
		const prefsPath = untildify(`${syncfolder}/Alfred.alfredpreferences`);

		return {
			version: 3,
			path: prefsPath
		};
	} catch (error) {
		if (error.code === 'EACCES') {
			errorMessage = `Permission denied to read Alfred preferences at location ${settings}`;
		}
	}

	if (errorMessage) {
		throw new Error(errorMessage);
	}
};
