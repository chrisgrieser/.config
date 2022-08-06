# FuzzySearchFilesInCurrentFolder

> Update: as of version 1.3.1 of FMAN you can achieve a similar effect natively by typing `*substring1*substring2`, see [article](https://fman.io/blog/filter-files-as-you-type/)

This is a plugin to locate with fuzzy search, your files and folders, starting from the current folder in [fman](https://fman.io/).

[fman](https://fman.io/) is the fastest file exploration tool that I've seen yet.
Dare I say finally even faster then Total Commander?
I say this because it has fuzzy search like Sublime and on top of that it works cross platform on Mac, Windows and Linux.

PS: If you are looking for these features in a terminal, check out [fzf](https://github.com/junegunn/fzf)

![Fuzzy search files and folders in all subfolders from current folder](https://raw.githubusercontent.com/kszcode/FuzzySearchFilesInCurrentFolder/master/resources/FuzzySearchInSubFolder.png)

## Features

- Search file in current folder: pressing CMD+F, CMD+E or CTRL+F will popup the quick search and you can fuzzy find the file or folder you need, pressing enter will place the cursor on it.
- Search file in current sub folders: pressing SHIFT+CMD+F or SHIFT+CTRL+F  will popup the quick search and you can fuzzy find the file or folder looking into all the subfolders. For performance reasons only 13000 files are loaded, this is also signaled in the status bar.

## Installation

Go to the command pallete: SHIFT+CMD+P > Install Plugin >FuzzySearchFilesInCurrentFolder

You can also install it manually just copy the contents of this folder to:

```~/Library/Application Support/fman/Plugins/User/FuzzySearchFilesInCurrentFolder```


## Further development

- comment code
- the loading of the subfolders should be done in a flat mode instead of recursive mode (see explanation below)
- stop after 100 matches are found, signal in status bar
- on every key stroke load more fiels from under the matched folder, this way we can explore the subdirectory quite deep without having performance problems
- consider the toggle of the hidden files (see explanation below)

Pull requests are welcome :)


### Flat loading vs. recursive loading

Consider this directory structure:

```
D1
    D11
        D111
    D12
D2
```

- Recursive mode loads D1, D11, D111, D12, D2 (basically if first loads the .git folder with all it's cryptic files, you can think of this as a deep first approach which exhaust the file limit very fast)
- Flat mode loads D1, D2, D11, D12, D111 (this mode is prefered when we explore a file system)
    - This can be achieved by putting all non traversed folders at the end of a FIFO list and then cycling through all of them with a while loop until the list is either empty or the file count limit is reached.

Pull requests are welcome :)

PS: This feature is not as important anymore because fman allows something similar to this out of the box. When you use GoTo pallete (CMD/CTRL+P) now you are able to advance to the subfolder using fuzzy search to select the next subfolder.

### Toggle the hidden files

See below code from [Michael Herrmann](https://fman.io/contact)

```
That is possible. You can get the setting for the current pane via:

settings = load_json('Panes.json', default=[], save_on_quit=True)
default = {'show_hidden_files': False}
pane_index = self.pane.window.get_panes().index(self.pane)
pane_info = settings[pane_index] if pane_index < len(settings) else default
show_hidden_files = pane_info['show_hidden_files']

- see the code of ToggleHiddenFiles in the Core plugin.
```

## Thank you!

I must thank [Michael Herrmann](https://fman.io/contact) who was extremely responsive and very helpful and enabled me to solve this issue, considering that I'm very much a beginner in python.

## Activism

- You have my thanks if you take a minute to sign this petition: http://www.dafoh.org/petition-to-the-united-nations/
- This is one of the biggest human rights violations of our time, see here: http://www.stoporganharvesting.org/
