#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────
// Items follow the same pattern
function makeItems(itemNames) {
  return itemNames.map(name => {
    return {
      "uid": name,
      "title": name,
      "subtitle": "Search “" + name + "” on Google",
      "arg": name
    }
  })
}

// Check values from previous runs this session
const oldArg = $.NSProcessInfo.processInfo.environment.objectForKey("oldArg").js
const oldResults = $.NSProcessInfo.processInfo.environment.objectForKey("oldResults").js

// Build items
function run(argv) {
  // If the user is typing, return early to guarantee the top entry is the currently typed query
  // If we waited for the API, a fast typer would search for an incomplete query
  if (argv[0] !== oldArg) {
    return JSON.stringify({
      "rerun": 0.1,
      "skipknowledge": true,
      "variables": { "oldResults": oldResults, "oldArg": argv[0] },
      "items": makeItems(argv.concat(oldResults?.split("\n").filter(line => line)))
    })
  }

  // Make the API request
  const encodedQuery = encodeURIComponent(argv[0])
  const queryURL = $.NSURL.URLWithString("https://suggestqueries.google.com/complete/search?output=chrome&ie=utf8&oe=utf8&q=" + encodedQuery)
  const requestData = $.NSData.dataWithContentsOfURL(queryURL);
  const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js
  const newResults = JSON.parse(requestString)[1].filter(result => result !== argv[0])

  // Return final JSON
  return JSON.stringify({
    "skipknowledge": true,
    "variables": { "oldResults": newResults.join("\n"), "oldArg": argv[0] },
    "items": makeItems(argv.concat(newResults))
  })
}
