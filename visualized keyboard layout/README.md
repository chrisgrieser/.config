# Visualized Keyboard Layout
Created with the fantastic [Keyboard Layout Editor](http://www.keyboard-layout-editor.com/#/). Bindings implemented via [Karabiner Elements](../.config/karabiner/).
<!-- MarkdownTOC -->

- [App Switcher](#app-switcher)
- [Hyper Bindings](#hyper-bindings)
- [Single Keystroke Bindings](#single-keystroke-bindings)
- [vimrc Remappings](#vimrc-remappings)
- [Base Layout](#base-layout)

<!-- /MarkdownTOC -->

## App Switcher
Activated with a single press of `left-ctrl` as leader key, followed by a letter key. 

![App Switcher Layout](app-switcher-layout.png)

## Hyper Bindings
`Hyper` is an artificial "fifth" modifier key equivalent to `⌘⌥⌃⇧`, bound to `Caps Lock`. Used for global, system-wide bindings.[^1] 

![Hyper Bindings Layout](hyper-bindings-layout.png)

## Single Keystroke Bindings
Since heavily relying and Vim Bindings, the keys at the periphery of the keyboard are practically never used. This enables the remapping of them for specific single keystroke bindings of actions that occur to rarely to justify a center spot in the keyboard, but often enough that they earn a separate key.

 ![Single Keystroke Bindings](single-keystroke-bindings.png)

## vimrc Remappings
A summary of the remappings in my `.vimrc`(s).

![vimrc remapping](vimrc-remapping.png)

## Base Layout
The basic look of my keyboard for reference. _Keychron K3 v.2 (70%), blue switches, ISO-de macOS Layout._

![Base Layout](base-keyboard-layout.png)

[^1]: Can also be implemented with various other methods other than Karabiner Elements; on macOS by using [Hyperkey](https://hyperkey.app/), [BetterTouchTool](https://thesweetsetup.com/macos-hyper-key-bettertouchtool/), or [Hammerspoon](https://evantravers.com/articles/2020/06/08/hammerspoon-a-better-better-hyper-key/).
