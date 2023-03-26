#!/usr/bin/env osascript -l JavaScript

// get first URL
const sidenote = Application("SideNotes");
const currentNote = sidenote.currentNote();
const content = currentNote.text();
const url = content.match(/https?:\/\/[^\s]+/)[0];
//──────────────────────────────────────────────────────────────────────────────

// close sidenotes
Application("System Events").keystroke("w", { using: ["command down"] });

// open URL
const app = Application.currentApplication();
app.includeStandardAdditions = true;
app.openLocation(url);

//──────────────────────────────────────────────────────────────────────────────
// delete note when only URL or only second line is URL
const noteHasOnlyUrl = content === url;
const secondLineOnlyUrl = content.split("\n")[1] === url;
if (noteHasOnlyUrl || secondLineOnlyUrl) currentNote.delete();
