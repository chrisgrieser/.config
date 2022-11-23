# pseudometa's dotfiles

## Configurations of Interest
Most people tell me they find the following configurations useful:
- [neovim config](/nvim)
- [.zshrc setup](/zsh)
- [Starship Prompt](/starship/starship-alacritty.toml)
- [Pandoc configs & pointers on how to use pandoc](/pandoc)
- [complex modifications for Karabiner Elements](/karabiner)
- [obsidian.vimrc](obsidian-vim/obsidian.vimrc) via the [vimrc Support Plugin](https://obsidian.md/plugins?id=obsidian-vimrc-support)

> __Note__  
> I also have a [blog for intermediary-advanced neovim tips](https://nanotipsforvim.prose.sh/)

## What are "dotfiles?"
- Read this [primer what dotfiles are](https://www.freecodecamp.org/news/dotfiles-what-is-a-dot-file-and-how-to-create-it-in-mac-and-linux/).
- Here is an interesting [report on common contents of dotfiles](https://github.com/Kharacternyk/dotcommon).

## How this repository works
- These files are symlinked into iCloud for synchronization.
- `Hammerspoon` [is configured](hammerspoon/system-and-cron.lua) to run the script [git-dotfile-sync.sh](git-dotfile-sync.sh) every 15 minutes, or on wake/sleep. The Alfred keyword `shutdown` triggers the script before shutting down.
- The git repos that are nested inside this dotfile repository (i.e. Alfred git repositories, because the nesting can't be avoided in this case) are gitignored and pulled individually.
- [git-dotfile-backup.sh](git-dotfile-backup.sh) checks whether there have been any changes in dot files. If there are, it creates somewhat useful commit messages and runs the `git add commit pull push` sequence.
- [.gitignore](.gitignore) contains a list of files not to backups for several reasons, e.g., redundancy, privacy, or simply because they are too big for a git repo.

## About Me
In my day job, I am a sociologist studying the social mechanisms underlying the digital economy. For my PhD project, I investigate the governance of the app economy and how software ecosystems manage the tension between innovation and compatibility. If you are interested in this subject, feel free to get in touch.

<!-- markdown-link-check-disable -->
__Profiles__
- [Discord](https://discordapp.com/users/462774483044794368/)
- [Academic Website](https://chris-grieser.de/)
- [GitHub](https://github.com/chrisgrieser/)
- [Twitter](https://twitter.com/pseudo_meta)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)
