- By setting them in the global git config, there is no more need to run `git
  config --global core.hooksPath .git-hooks` after every clone.
- Caveat: this trick only works on repos solely managed by the user of this
  dotfile repo, it does not work to enforce hooks on other people's clones.
