#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

folder="Base"
count=$(osascript -l JavaScript -e "
	Application('SideNotes').folders.byName(\"$folder\").notes().length
")
unfinished_tasks=$(osascript -l JavaScript -e "
	const notesInFolder = Application('SideNotes').folders.byName(\"$folder\").notes();
	let totalTasks = 0;
	for (let i = 0; i < notesInFolder.length; i++) {
		const note = notesInFolder[i];
		const tasksInNote = note.text().match(/\[ \]/g)
		if (tasksInNote) totalTasks += tasksInNote.length;
	}
	totalTasks; // direct return
")
current_note=$(osascript -l JavaScript -e "
	Application('SideNotes').currentNote().text()
")

if [[ $count -eq 0 ]]; then
	icon=""
	label=""
elif [[ $unfinished_tasks -eq 0 ]]; then
	icon="󰛽"
	label="$count"
else
	icon="󰛽"
	label="$count ($unfinished_tasks 󰝣 )"
fi

# add preview of note to status bar (similar to the OneThing app)
if [[ $(echo "$current_note" | wc -l) -eq 1 ]]; then
	[[ ${#current_note} -lt 15 ]] && short_text="$current_note" || short_text="$(echo "$current_note" | cut -c-15)…"
	label="$label $short_text"
fi

sketchybar --set "$NAME" icon="$icon" label="$label"
