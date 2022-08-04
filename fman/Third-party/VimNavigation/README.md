# VimNavigation
[fman](https://fman.io) plugin for vim key style navigation.

## Usage
 * `shift+h` goes up a directory.
 * `shift+l` opens the currently selected directory.
 * `shift+j` moves cursor up one
 * `shift+k` moves cursor down one
 * `shift+d` Move the file to trash
 * `shift+g` Move cursor to bottom
 * `ctrl+g`  Move cursor to the top

I set it up using shift and the letter so that I can still type out names of files/directories and the cursor will move to them. A little less convient, but not too bad.

This is a modified version of ArrowNavigation plugin for fman.

## Installation

Install with [fman's built-in command for installing plugins](https://fman.io/docs/installing-plugins).

## Problems

The `move_to_bottom` doesn't always go to the bottom. It goes to the last entry in the current directory. Fman sorts all directories at the top and files afterwards.
