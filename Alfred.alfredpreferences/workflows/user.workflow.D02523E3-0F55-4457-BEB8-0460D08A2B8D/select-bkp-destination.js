#!/usr/bin/env osascript -l JavaScript
app = Application.currentApplication();
app.includeStandardAdditions = true;
var single_volumes = app.doShellScript("ls /Volumes").split("\r");

//function to remove elements from Array
function arrayRemove(arr, value) {
    return arr.filter(function(elem){
        return !elem.includes(value);
    });
}
var single_volumes = arrayRemove(single_volumes, "TimeMachine");
var single_volumes = arrayRemove(single_volumes, "Macintosh");
var single_volumes = arrayRemove(single_volumes, "HDD");
var single_volumes = arrayRemove(single_volumes, "SSD");
var single_volumes = arrayRemove(single_volumes, "GoogleDrive");

let volume_array = [];
if (single_volumes.length == 0) {
    volume_array.push ({
        'title': "No mounted volume recognized.",
        'subtitle': "Press [Esc] to abort or select folder instead.",
        'arg': "folder"
    });
} else {
   single_volumes.forEach(element => {
      let disk_space = app.doShellScript('df -h | grep "' + element + '" | tr -s " " | cut -d " " -f 2-5 | tr "i." "b," ').split(" ");
      let space_info =
         "Total: " + disk_space[0]
         + "   Available: " + disk_space[2]
         + "   Used: " + disk_space[1]
         + " (" + disk_space[3] + ")";
      volume_array.push ({
         'title': element,
         'subtitle': space_info,
         'arg': "/Volumes/"+ element
      })
   });
}
volume_array.push ({
      'title': "Select a Folder",
      'subtitle': "",
      'arg': "folder",
		'icon': {'path':'foldericon.png'}
});
volume_array.push ({
      'title': "Disk Utility",
      'subtitle': "",
      'arg': "disk_utility",
		'icon': {'path':'disk_utility.png'}
});

JSON.stringify({ 'items': volume_array });
