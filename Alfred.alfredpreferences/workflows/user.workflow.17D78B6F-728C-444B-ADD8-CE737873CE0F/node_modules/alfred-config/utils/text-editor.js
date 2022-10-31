'use strict';
const openEditor = require('open-editor');
const execa = require('execa');

exports.open = file => {
	try {
		openEditor([file]);
	} catch {
		execa.sync('open', [file]);
	}
};
