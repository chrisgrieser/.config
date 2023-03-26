#!/usr/bin/env osascript -l JavaScript

// get first URL
const sidenote = Application("SideNotes");
const currentNote = sidenote.currentNote()
const content = currentNote.text()
const url = content.match(/https?:\/\/[^\s]+/)[0];
const noteHasOnlyUrl = content === url
//──────────────────────────────────────────────────────────────────────────────

// close sidenotes
Application("System Events").keystroke("w", {using: ["command down"]});

// open URL
const app = Application.currentApplication();
app.includeStandardAdditions = true;
app.openLocation(url);

//──────────────────────────────────────────────────────────────────────────────

if (noteHasOnlyUrl) currentNote.delete()
