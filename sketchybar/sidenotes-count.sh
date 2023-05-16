#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

folder="Base"
count=$(osascript -l JavaScript -e "
	Application('SideNotes').folders.byName(\"$folder\").notes().length
")
unfinishedTasks=$(osascript -l JavaScript -e "
	const notesInFolder = Application('SideNotes').folders.byName(\"$folder\").notes();
	let totalTasks = 0;
	for (let i = 0; i < notesInFolder.length; i++) {
		const note = notesInFolder[i];
		const tasksInNote = note.text().match(/\[ \]/g)
		if (tasksInNote) totalTasks += tasksInNote.length;
	}
	totalTasks; // direct return
")

if [[ $count -eq 0 ]]; then
	icon=""
	label=""
elif [[ $unfinishedTasks -eq 0 ]]; then
	icon="󰛽"
	label="$count"
else
	icon="󰛽"
	label="$count ($unfinishedTasks 󰝣 )"
fi

sketchybar --set "$NAME" icon="$icon" label="$label"
