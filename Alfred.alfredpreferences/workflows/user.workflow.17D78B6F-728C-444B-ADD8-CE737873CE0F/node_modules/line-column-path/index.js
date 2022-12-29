'use strict';

exports.parse = path => {
	if (typeof path === 'object') {
		if (!path.file) {
			throw new Error('Missing required `file` property');
		}

		return {
			file: path.file,
			line: path.line || 1,
			column: path.column || 1
		};
	}

	const match = /^(.*?):(\d+)(?::(\d+))?$/.exec(path);

	if (!match) {
		return {
			file: path,
			line: 1,
			column: 1
		};
	}

	if (!match[1]) {
		throw new Error('Missing file path');
	}

	return {
		file: match[1],
		line: Number(match[2]),
		column: Number(match[3]) || 1
	};
};

exports.stringify = (path, options) => {
	options = {
		file: true,
		column: true,
		...options
	};

	if (!path.file) {
		throw new Error('Missing required `file` property');
	}

	let result = '';

	if (options.file) {
		result += path.file;
	}

	if (path.line) {
		result += `:${path.line}`;
	}

	if (path.line && path.column && options.column) {
		result += `:${path.column}`;
	}

	if (!options.file) {
		result = result.replace(/^:/, '');
	}

	return result;
};

