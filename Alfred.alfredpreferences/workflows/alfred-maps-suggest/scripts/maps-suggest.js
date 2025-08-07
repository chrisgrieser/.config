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


const mapProvider = {
	// biome-ignore-start lint/style/useNamingConvention: Alfred standard
	"google_maps": "http://google.com/maps?q=",
	"apple_maps": "maps://maps.apple.com?q=",
	// biome-ignore-end lint/style/useNamingConvention: Alfred standard
}


//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = (argv[0] || "").trim();
	const openAt = $.getenv("open_map_at");
	if (!query) return JSON.stringify({ items: [{ title: "Waiting for query…", valid: false }] });

	// DOCS https://photon.komoot.io/
	const apiUrl = "https://photon.komoot.io/api?q=" + encodeURIComponent(query);
	console.log("api url:", apiUrl);
	const response = httpRequest(apiUrl);
	if (!response) return JSON.stringify({ items: [{ title: "Error: No results", valid: false }] });
	const /** @type {GeoLocation[]} */ locations = JSON.parse(response).features;

	/** @type {AlfredItem[]} */
	const items = locations.map((loc) => {
		const { name, country, state, city, district, locality, postcode, street, housenumber } =
			loc.properties;
		const title = name || street + " " + housenumber;
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
		const addressDisplay = address.slice(1).join(", "); // skip name from display
		const url = openAt + encodeURIComponent(addressStr);

		// SIC osm coordinates are long/lat, even though mapping apps expect
		// lat/long, thus needs to be reversed
		const coordinates = loc.geometry.coordinates.reverse().join(",");

		return {
			title: title,
			subtitle: addressDisplay,
			mods: {
				cmd: { arg: otherUrl },
				ctrl: { arg: addressStr }, // copy
				shift: { arg: coordinates }, // copy
			},
			arg: url,
			variables: { address: addressStr, url: url, coordinates: coordinates }, // for debugging
		};
	});

	return JSON.stringify({ items: items });
}
