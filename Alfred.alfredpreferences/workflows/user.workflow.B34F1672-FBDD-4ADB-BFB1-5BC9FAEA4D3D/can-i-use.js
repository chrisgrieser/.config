#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

const dataURL = "https://raw.githubusercontent.com/Fyrd/caniuse/main/fulldata-json/data-2.0.json";

//──────────────────────────────────────────────────────────────────────────────

function findMatches(query, data) {
	const lcQuery = query.toLowerCase();
	return data.filter(d => {
		console.log("${lcQuery}: ${d.title}/${d.name)/[${d.keywords}]");
		return d.title.toLowerCase().includes(lcQuery) ||
			d.name.toLowerCase().includes(lcQuery) ||
			d.keywords.toLowerCase().includes(lcQuery);
	});
} /* findMatches() */

function getBrowserVersion(stats, title, browser) {
	let version = 0;
	let retval = "";

	for (const v of Object.keys(stats).sort((a, b) => Number(a) - Number(b))) {
		const numVersion = Number(v);
		const support = stats[v];
		//  if (title.indexOf('WOFF 2')> -1) console.log(`${browser}: ${numVersion} ${support}`);
		if (numVersion > version) {
			if (support === "y") {
				retval = `${v}+`;
				break;
			}
			if (support.indexOf("y x") > -1) {
				version = numVersion;
				retval = `${v}-px-`;
			} else if (support.indexOf("a") > -1) {
				version = numVersion;
				retval = `${v}!pa.`;
			} else if (support.indexOf("p") > -1) {
				version = numVersion;
				retval = `${v}w/pl`;
			}
		}
	}
	//  if (title.indexOf('WOFF 2')> -1) console.log(`Version ${browser} found: ${retval}`);
	return retval;
} /* getBrowserVersion */

function run(argv) {
	const browserMap = {
		"ie": "IE",
		"edge": "E",
		"firefox": "FF",
		"chrome": "GC",
		"safari": "S",
	};

	const query = argv[0];
	if (!query) return;
	const localCache = "data.json";
	const filemanager = $.NSFileManager.defaultManager;
	const modificationDate = (() => {
		if (filemanager.fileExistsAtPath($(localCache))) {
			const error = Ref();
			const dict = filemanager.attributesOfItemAtPathError($(localCache), error);
			return dict.objectForKey($.NSFileModificationDate).js;
		}
		return null;

	})();

	const milliSecsPerDay = 8.64e7;
	const cachedValues = (() => {
		if (!modificationDate || Date.now() - modificationDate >= milliSecsPerDay * 7) {
			//  const dataURL = 'https://raw.githubusercontent.com/Fyrd/caniuse/master/data.json'; 
			const dataJSON = app.doShellScript(`curl ${dataURL}`);
			//    console.log(dataJSON.length);
			const data = JSON.parse(dataJSON).data;
			const cacheArray = Object.keys(data).map(k => {
				const caniuseData = data[k];
				const stats = {};
				Object.keys(caniuseData.stats).filter(browser => browserMap[browser]).forEach(browser => {
					const support = getBrowserVersion(caniuseData.stats[browser], caniuseData.title, browser);
					if (support.trim().length) stats[browserMap[browser]] = support;
				});
				return {
					name: k,
					title: caniuseData.title,
					url: `https://caniuse.com/#feat=${k}`,
					description: caniuseData.description,
					keywords: caniuseData.keywords,
					stats: Object.keys(stats).map(key => `${key}: ${stats[key]}`).join(", "),
				};
			});
			if (cacheArray.length) {
				/* write cache data */
				//      console.log(`updating cache data @ ${Path(localCache)}`);
				const file = app.openForAccess(Path(localCache), { writePermission: true });
				app.write(JSON.stringify(cacheArray), { to: file });
				app.closeAccess(file);
			}
			return cacheArray;
		} /* if local file is older than one week */
		const file = app.openForAccess(Path(localCache));
		const cacheArray = JSON.parse(app.read(file));
		app.closeAccess(file);
		return cacheArray;

	})();
	/* Now 'cachedValues' contains the relevant JSON data */
	const result = findMatches(query, cachedValues);
	const items = result.map(r => {
		return {
			uid: r.title,
			arg: r.url,
			title: `${r.title} [${r.stats}]`,
			subtitle: r.description,
		};
	}); /* items */
	return JSON.stringify({
		items: items.length ?
			items :
			[{ title: `No matches found for ${query}` }],
	});
}
