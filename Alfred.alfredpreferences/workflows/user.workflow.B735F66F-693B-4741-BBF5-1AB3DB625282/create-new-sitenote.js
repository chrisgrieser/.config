#!/usr/bin/env osascript -l JavaScript

//──────────────────────────────────────────────────────────────────────────────
ObjC.import("stdlib");

  const folderID = $.getenv("new_note_folder");
  const text = $.getenv("text");
  const isPath = $.getenv("isPath");
  const app = Application("SideNotes");

  app.createNote({
    folder: app.folders.whose({ id: folderID })[0](),
    text: text,
    ispath: isPath,
  });

  return text; // direct return for notification
