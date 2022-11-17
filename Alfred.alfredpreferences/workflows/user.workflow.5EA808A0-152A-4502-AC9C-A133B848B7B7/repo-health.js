#!/usr/bin/env osascript -l JavaScript

const browser = Application("Brave Browser");
const repoID = browser.windows[0].activeTab.url();
const newURL = "https://repocheck.com/#" + encodeURIComponent(repoID);

browser.windows[0].activeTab.url = newURL;
