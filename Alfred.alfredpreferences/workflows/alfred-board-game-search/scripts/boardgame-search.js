#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//------------------------------------------------------------------------------

/** @param {string} path */
function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath($(path).stringByStandardizingPath);
	// biome-ignore format: -
	const encoding = $.NSString.stringEncodingForDataEncodingOptionsConvertedStringUsedLossyConversion(data, $.NSDictionary.dictionary, null, null);
	if (encoding === 0) throw new Error("Unable to detect string encoding");
	const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
	return ObjC.unwrap(str);
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//------------------------------------------------------------------------------

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const csvPath = $.getenv("bgg_csv_path");
	const maxGames = Number.parseInt($.getenv("max_games")) * 10_000;

	if (!fileExists(csvPath))
		return JSON.stringify({
			items: [
				{
					title: "No CSV database found.",
					subtitle: "⏎: Open workflow configuration and follow the setup instructions.",
					arg: "alfredpreferences://navigateto/workflows>workflow>alfred-board-game-search>userconfig>bgg_csv_path",
				},
				{
					title: "",
					subtitle: "⏎: Download the CSV database from BGG",
					arg: "https://boardgamegeek.com/data_dumps/bg_ranks",
				},
			],
		});

	const csv = readFile(csvPath);

	/** @type {AlfredItem[]} */
	const games = csv
		.split("\n")
		.slice(1, maxGames + 1) // skip header and limit games for performance reasons
		.map((line) => {
			// id,name,yearpublished,rank,bayesaverage,average,usersrated,is_expansion,abstracts_rank,cgs_rank,childrensgames_rank,familygames_rank,partygames_rank,strategygames_rank,thematic_rank,wargames_rank
			// 224517,"Brass: Birmingham",2018,1,8.3918,8.56131,59277,0,,,,,,1,,
			const [bggId, name, year, rank, _bavg, score, _rating, isExpansion] = line.split(",");

			const displayName =
				(name || "?").replace(/^"|"$/g, "") + (isExpansion === "1" ? " 🧩" : "");
			const displayRank = rank === "0" ? "" : " #" + rank;
			const displayScore = Number.parseFloat(score).toFixed(1);
			const subtitle = `${year}     ${displayScore}`;

			return {
				title: displayName + displayRank,
				subtitle: subtitle,
				arg: "https://boardgamegeek.com/boardgame/" + bggId,
			};
		});
	console.log("# games:", games.length);

	return JSON.stringify({
		items: games,
		cache: { seconds: 3600 * 24 * 7, loosereload: true },
	});
}
