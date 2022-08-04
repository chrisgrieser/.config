from fman import DirectoryPaneCommand
from fman.fs import is_dir

class OpenIfDirectory(DirectoryPaneCommand):
    def __call__(self, url=None):
        if url is None:
            file_under_cursor = self.pane.get_file_under_cursor()
            if file_under_cursor and is_dir(file_under_cursor):
                url = file_under_cursor
        if url:
            self.pane.set_path(url)
