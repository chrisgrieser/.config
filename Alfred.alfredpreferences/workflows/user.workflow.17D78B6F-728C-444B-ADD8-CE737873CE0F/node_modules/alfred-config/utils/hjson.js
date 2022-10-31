'use strict';
const HJSON = require('hjson').rt;

exports.parse = (text, options) => HJSON.parse(text, options);

exports.stringify = (text, options) => HJSON.stringify(text, {
	bracesSameLine: true,
	quotes: 'all',
	space: '\t',
	separator: true,
	...options
});
