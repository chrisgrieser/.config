'use strict';
const isPlainObject = require('is-plain-obj');
const HJSON = require('./hjson');

const migrate = (obj1, obj2) => {
	for (const key of Object.keys(obj1)) {
		if (typeof obj2[key] === 'undefined') {
			continue;
		}

		if (isPlainObject(obj1[key])) {
			obj1[key] = migrate(obj1[key], obj2[key]);
		} else {
			obj1[key] = obj2[key];
		}
	}

	return obj1;
};

exports.merge = (newConfig, oldConfig) => {
	const newConfigSrc = typeof newConfig === 'string' ? HJSON.parse(newConfig) : newConfig;
	const oldConfigSrc = typeof oldConfig === 'string' ? HJSON.parse(oldConfig) : oldConfig;

	return HJSON.stringify(migrate(newConfigSrc, oldConfigSrc));
};
