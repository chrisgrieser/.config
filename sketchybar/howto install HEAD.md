I have found a couple of problems with the inheritance system and popups and have tried to resolve them. Could you try with current master version by running:

```bash
brew services stop sketchybar
brew uninstall sketchybar
brew install sketchybar --head
brew services start sketchybar
```

after testing, you can go back to the stable repository by running:

```bash
brew services stop sketchybar
brew uninstall sketchybar
brew install sketchybar
brew services start sketchybar
```
