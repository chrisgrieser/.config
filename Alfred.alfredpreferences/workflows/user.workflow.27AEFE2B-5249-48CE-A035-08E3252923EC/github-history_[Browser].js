#!/usr/bin/env osascript -l JavaScript

const browser = Application("Brave Browser");

const url = browser.windows[0].activeTab.url();
const newURL = url.replace("github.com", "github.githistory.xyz");

browser.windows[0].activeTab.url = newURL;

