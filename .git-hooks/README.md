1. Motivation: version control & sync hooks across devices
2. By setting them in the global git config, there is no more need to run `git
   config --global core.hooksPath .git-hooks` after every clone.
3. Caveat: this trick only works on repos solely managed by the user of this
   dotfile repo, it does not work to enforce hooks on other people's clones.
