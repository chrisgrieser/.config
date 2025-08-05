#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @typedef {Object} GeoLocation
 * @property {string} type - The type of the feature, e.g., "Feature".
 * @property {GeoProperties} properties - Metadata about the feature.
 * @property {{type: string, coordinates: number[]}} geometry - Geometric data of the feature.
 */

/** @typedef {Object} GeoProperties
 * @property {string} osm_type - Type of OSM object (e.g., "R" for relation).
 * @property {number} osm_id - OpenStreetMap ID.
 * @property {string} osm_key - Main OSM category (e.g., "building").
 * @property {string} osm_value - OSM-specific value (e.g., "train_station").
 * @property {string} type - Type of object (e.g., "house").
 * @property {string} postcode - Postal code.
 * @property {string} countrycode - ISO country code.
 * @property {string} name - Name of the feature.
 * @property {string} country - Country name.
 * @property {string} city - City name.
 * @property {string} district - District name.
 * @property {string} locality - Local area.
 * @property {string} street - Street name.
 * @property {number[]} extent - Bounding box as [minLon, maxLat, maxLon, minLat].
 */

//───────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = (argv[0] || "").trim();
	const openAtUrl = $.getenv("open_map_at");
	if (!query) return JSON.stringify({ items: [{ title: "Waiting for query…", valid: false }] });

	// DOCS
	const apiUrl = "https://photon.komoot.io/api?q=" + encodeURIComponent(query);
	const response = httpRequest(apiUrl);
	if (!response) return JSON.stringify({ items: [{ title: "Error: No results", valid: false }] });

	/** @type {GeoLocation[]} */
	const locations = JSON.parse(response).features;

	/** @type {AlfredItem[]} */
	const items = locations.map((loc) => {
		// SIC osm coordinates are long/lat, thus need to be reversed
		const coordinates = loc.geometry.coordinates.reverse().join(",");
		const icon = loc.properties.type === "house" ? "📍" : "🛣️";
		const subtitle = [coordinates].join("");

		return {
			title: icon + " " + loc.properties.name,
			subtitle: subtitle,
			arg: openAtUrl + coordinates,
		};
	});

	return JSON.stringify({ items: items });
}
