const notesInFolder = Application("SideNotes").folders.byName("Base").notes();
let totalTasks = 0;
for (let i = 0; i < notesInFolder.length; i++) {
	const note = notesInFolder[i];
	const tasksInNote = note.text().match("/☐|☑/")
	if (tasksInNote) totalTasks += tasksInNote.length;
}
totalTasks; // direct return
