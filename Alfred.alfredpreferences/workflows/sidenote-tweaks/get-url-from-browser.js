#!/usr/bin/env osascript -l JavaScript
const url = Application("Vivaldi").windows[0].activeTab.url();
const title = Application("Vivaldi").windows[0].activeTab.title();

const out = title + "\n" + url;
out; // direct return
