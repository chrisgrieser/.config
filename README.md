# pseudometa's dotfiles

## Configurations of Interest
Most people tell me they find the following configurations useful:
- [neovim config](/nvim) (5000+ LoC)
- [hammerspoon config](/hammerspoon) (2000+ LoC)
- [.zshrc](/zsh) (1400+ LoC)
- [Pandoc configs & pointers on how to use pandoc](/pandoc)
- [complex modifications for Karabiner Elements](/karabiner)
- [obsidian.vimrc](obsidian-vim/obsidian.vimrc) via the [vimrc Support Plugin](https://obsidian.md/plugins?id=obsidian-vimrc-support)
- [Starship Prompt](/starship/starship.toml) – see below

<img width=60% alt="Starship Prompt" src="https://user-images.githubusercontent.com/73286100/229211019-e763d775-d89f-43da-99ef-06c57fd1e485.png">

> __Note__  
> I also have a [blog for intermediary-advanced neovim tips](https://nanotipsforvim.prose.sh/)

## What are "dotfiles?"
- Read this [primer what dotfiles are](https://www.freecodecamp.org/news/dotfiles-what-is-a-dot-file-and-how-to-create-it-in-mac-and-linux/).
- Here is an interesting [report on common contents of dotfiles](https://github.com/Kharacternyk/dotcommon).

## How this repository works
- These files are symlinked into iCloud for synchronization.
- Hammerspoon [is configured](hammerspoon/lua/system-and-cron.lua) to run the script [git-dotfile-sync.sh](git-dotfile-sync.sh) every 15 minutes, or on wake and sleep. The Alfred keyword `shutdown` triggers the script before shutting down.
- The git repos that are nested inside this dotfile repository (that is Alfred git repositories, because the nesting cannot be avoided in this case) are gitignored and pulled individually.
- [git-dotfile-backup.sh](git-dotfile-backup.sh) checks whether there have been any changes in dotfiles. If there are, it creates somewhat useful commit messages and runs the `git add commit pull push` sequence.
- [.gitignore](.gitignore) contains a list of files not to backups for several reasons, for example redundancy, privacy, or because they are too big for a git repo.

<!-- vale Google.FirstPerson = NO --> <!-- vale Microsoft.FirstPerson = NO -->
## About me
In my day job, I am a sociologist studying the social mechanisms underlying the digital economy. For my PhD project, I investigate the governance of the app economy and how software ecosystems manage the tension between innovation and compatibility. If you are interested in this subject, feel free to get in touch.

__Profiles__
- [Discord](https://discordapp.com/users/462774483044794368/)
- [Academic Website](https://chris-grieser.de/)
- [GitHub](https://github.com/chrisgrieser/)
- [Twitter](https://twitter.com/pseudo_meta)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

