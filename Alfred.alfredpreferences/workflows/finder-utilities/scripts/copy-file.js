// https://github.com/JXA-Cookbook/JXA-Cookbook/wiki/User-Interaction-with-Files-and-Folders#copy-a-file-to-pasteboard
ObjC.import('AppKit');

/** @param {string} path */
function copyPathToClipboard(path) {
  const pasteboard = $.NSPasteboard.generalPasteboard
  pasteboard.clearContents
  return pasteboard.setPropertyListForType($([path]), $.NSFilenamesPboardType)
}

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv){
  const path = argv[0];
  copyPathToClipboard(path);
}

