from fman import DirectoryPaneCommand, show_alert
from fman.url import as_human_readable, as_url
import os.path
from fman.fs import copy

class DuplicateFileDir(DirectoryPaneCommand):
    def __call__(self):
        selected_files = self.pane.get_selected_files()
        if len(selected_files) >= 1 or (len(selected_files) == 0 and self.get_chosen_files()):
            if len(selected_files) == 0 and self.get_chosen_files():
                selected_files.append(self.get_chosen_files()[0])
            #
            # Loop through each file/directory selected.
            #
            for filedir in selected_files:
                p = as_human_readable(filedir)
                filepath = os.path.abspath(p)
                if os.path.isdir(filepath):
                    #
                    # It is a directory. Process as a directory.
                    #
                    newDir = filepath + "-copy"
                    copy(as_url(filepath), as_url(newDir))
                else:
                    if os.path.isfile(filepath):
                        #
                        # It is a file. Process as a file.
                        #
                        dirPath, ofilenmc = os.path.split(filepath)
                        ofilenm, ext = os.path.splitext(ofilenmc)
                        nfilenm = os.path.join(dirPath,ofilenm + "-copy" + ext)
                        copy(as_url(filepath), as_url(nfilenm))
                    else:
                        show_alert('Bad file path : {0}'.format(filepath))
