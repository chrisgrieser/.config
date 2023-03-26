#!/usr/bin/env osascript -l JavaScript

const sidenote = Application("SideNotes");

const currentNote = sidenote.currentNote()
const url = currentNote.text().match(/https?:\/\/[^\s]+/)[0];

//──────────────────────────────────────────────────────────────────────────────

// close sidenotes
Application("System Events").keystroke("w", {using: ["command down"]});

const app = Application.currentApplication();
app.includeStandardAdditions = true;
app.openLocation(url);
