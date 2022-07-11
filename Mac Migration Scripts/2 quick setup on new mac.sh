# to get the config started

cd ~ || exit 1
git clone git@github.com:chrisgrieser/dotfiles.git
zsh ~/dotfiles/symlink-creation.sh


cd ~/dotfiles/Alfred.alfredpreferences/workflows/ || exit 1
git clone git@github.com:chrisgrieser/shimmering-obsidian.git
git clone git@github.com:chrisgrieser/alfred-bibtex-citation-picker.git
git clone git@github.com:chrisgrieser/pdf-annotation-extractor-alfred.git

