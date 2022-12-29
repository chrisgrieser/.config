#!/usr/bin/env node
'use strict';
const alfredLink = require('.');

alfredLink.unlink().catch(error => {
	console.error(error);
	process.exit(1);
});
