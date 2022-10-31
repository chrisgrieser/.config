'use strict';
const fs = require('fs');
const HJSON = require('./hjson');

module.exports = file => {
	try {
		return HJSON.parse(fs.readFileSync(file, 'utf8'));
	} catch (_) {
		return {};
	}
};
