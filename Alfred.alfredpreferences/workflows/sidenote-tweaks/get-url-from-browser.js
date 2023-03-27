#!/usr/bin/env osascript -l JavaScript

const sidenotes = Application("SideNotes")

//──────────────────────────────────────────────────────────────────────────────

const installedThemes = sidenotes.searchThemes("");



sidenotes.setTheme(selectedTheme);
