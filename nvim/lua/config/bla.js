#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────
console.log("hi")
Application("iTerm").open("https://github.com/iterm2/iterm2");
