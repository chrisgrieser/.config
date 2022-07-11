# pseudometa's dotfiles

## Table of Contents
<!-- MarkdownTOC -->

- [Configurations of Interest](#configurations-of-interest)
- [What is this repository?](#what-is-this-repository)
- [Got an idea for an improvement?](#got-an-idea-for-an-improvement)
- [About Me](#about-me)

<!-- /MarkdownTOC -->
## Configurations of Interest
Most people tell me they find the following configurations useful:
- [.zshrc setup](/zsh/)
- Pandoc configs & my pointers on [how to use pandoc](/pandoc/#Pandoc)
- [complex modifications for Karabiner Elements](/.config/karabiner)
- [starship prompt](/.config/starship/starship.toml)
- Various Vim Emulation Configs
	- System wide: [Vim Utilities](/.config/karabiner#vim-utilities) and [Vim Mode](/.config/karabiner#vim-mode) via Karabiner Elements
	- Browser: [Vimium configs](/Browser%20Extension%20Settings/vimium.vimrc) via [Vimium](https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb)
	- Obsidian: [.obsidian.vimrc](obsidian.vimrc) via [Vimrc Support Plugin](https://obsidian.md/plugins?id=obsidian-vimrc-support) 
	- Sublime: [.neovintageousrc](Sublime%20User%20Folder/.neovintageousrc) via [Neovintageous](https://github.com/NeoVintageous/NeoVintageous)

## What is this repository?
Essentially, it's all of my dotfiles, that I put online for backup, version history, and easy sharing with others.

__What are "dotfiles"?__
- Read this excellent [primer what dotfiles are](https://www.freecodecamp.org/news/dotfiles-what-is-a-dot-file-and-how-to-create-it-in-mac-and-linux/).
- Here is an interesting [report on common contents of dotfiles](https://github.com/Kharacternyk/dotcommon).

__How this repository works__
- These files are symlinked into iCloud for synchronization.
- `crontab` on my main machine [is configured](Cron%20Jobs/30-min.sh) to run the script [30-min.sh](Cron%20Jobs/30-min.sh) every 30 minutes.
- [30-min.sh](Cron%20Jobs/30-min_%5BBrowser-Path%5D.sh) runs various tasks that should run regularly, one of them is to trigger the shell script [git-dotfile-backup.sh](git-dotfile-backup.sh).
- [git-dotfile-backup.sh](git-dotfile-backup.sh) checks whether there have been any changes in dot files. If there are, it creates somewhat useful commit messages and runs the `git add commit pull push` sequence.
- [.gitignore](.gitignore) contains a list of files not to backups for various reasons, e.g. redundancy, privacy, or simply because they are too big for a git repo.

## Got an idea for an improvement?
Feel free to [open an issue](https://github.com/chrisgrieser/dotfiles/issues) to suggest an improvement to my settings! :blush:

## About Me
In my day job, I am a sociologist studying the social mechanisms underlying the digital economy. For my PhD project, I investigate the governance of the app economy and how software ecosystems manage the tension between innovation and compatibility. If you are interested in this subject, feel free to get in touch!

<!-- markdown-link-check-disable -->
__Profiles__
- [Discord](https://discordapp.com/users/462774483044794368/)
- [Academic Website](https://chris-grieser.de/)
- [GitHub](https://github.com/chrisgrieser/)
- [Twitter](https://twitter.com/pseudo_meta)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)
