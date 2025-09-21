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
 * @property {string} state
 * @property {string} district - District name.
 * @property {string} locality - Local area.
 * @property {string} street - Street name.
 * @property {string} housenumber
 * @property {number[]} extent - Bounding box as [minLon, maxLat, maxLon, minLat].
 */

//───────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	// unique user-agent to make blocking less likely
	const workflowName = $.getenv("alfred_workflow_name");
	const version = $.getenv("alfred_workflow_version");
	const userAgent = `Alfred ${workflowName}/${version}`;
	return app.doShellScript(`curl --silent --user-agent "${userAgent}" "${url}"`);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {Record<string, string>} */
const mapProvider = {
	"Google Maps": "https://www.google.com/maps?q=",
	"Apple Maps": "maps://maps.apple.com?q=",
};

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = (argv[0] || "").trim();
	const mapProvider1 = $.getenv("map_provider_1");
	const mapProvider2 = $.getenv("map_provider_2");
	if (!query) return JSON.stringify({ items: [{ title: "Waiting for query…", valid: false }] });

	// DOCS https://photon.komoot.io/
	const apiUrl = "https://photon.komoot.io/api?q=" + encodeURIComponent(query);
	console.log("api url:", apiUrl);
	const response = httpRequest(apiUrl);
	if (!response) return JSON.stringify({ items: [{ title: "Error: No results", valid: false }] });
	const /** @type {GeoLocation[]} */ locations = JSON.parse(response).features;

	/** @type {Record<string, boolean>} */
	const usedAddresses = {};

	/** @type {AlfredItem[]} */
	const items = locations.reduce((/** @type {AlfredItem[]} */ acc, loc) => {
		const { name, country, state, city, district, locality, postcode, street, housenumber } =
			loc.properties;
		const address = [
			name,
			country,
			state,
			city,
			district,
			locality,
			postcode,
			((street || "") + " " + (housenumber || "")).trim(),
		].filter(Boolean);
		const addressStr = address.join(", ");

		// prevent duplicate entries
		if (usedAddresses[addressStr]) return acc;
		usedAddresses[addressStr] = true;

		const title = name || street + " " + housenumber;
		const addressDisplay = address.slice(1).join(", "); // skip name from display
		const mapProvider1Url = mapProvider[mapProvider1] + encodeURIComponent(addressStr);
		const mapProvider2Url = mapProvider[mapProvider2] + encodeURIComponent(addressStr);

		// SIC osm coordinates are long/lat, even though mapping apps expect
		// lat/long, thus needs to be reversed
		const coordinates = loc.geometry.coordinates.reverse().join(",");

		/** @type {AlfredItem} */
		const alfredItem = {
			title: title,
			subtitle: addressDisplay,
			arg: mapProvider1Url,
			mods: {
				cmd: { arg: mapProvider2Url },
				ctrl: { arg: addressStr }, // copy
				shift: { arg: coordinates }, // copy
			},
			variables: {
				// only for debugging
				address: addressStr,
				url1: mapProvider1Url,
				url2: mapProvider2Url,
				coordinates: coordinates,
			},
		};
		acc.push(alfredItem);
		return acc;
	}, []);

	// manual search fallback
	items.push({
		title: `Search for "${query}"`,
		subtitle: mapProvider1,
		arg: mapProvider[mapProvider1] + encodeURIComponent(query),
		mods: {
			cmd: { arg: mapProvider[mapProvider2] + encodeURIComponent(query) },
		},
	});

	return JSON.stringify({ items: items });
}
