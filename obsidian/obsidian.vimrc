""""""""""""""""""""""
" Leader
""""""""""""""""""""""
" let mapleader=,
" can't set leaders in Obsidian vim, so the key just has to be used consistently.
" However, it needs to be unmapped, to not trigger default behavior: https://github.com/esm7/obsidian-vimrc-support#some-help-with-binding-space-chords-doom-and-spacemacs-fans
unmap ,

""""""""""""""""""""""
" Clipboard
""""""""""""""""""""""
" yank to system clipboard
set clipboard=unnamed

" Y consistent with D and C to the end of line
nmap Y y$

" don't pollute the register
" HACK to avoid recursion since Obsidian vimrc does not support noremap
nmap x "_dl

""""""""""""""""""""""
" Search
""""""""""""""""""""""
" no modifier key for jumping to next word
nmap + *

" Find Mode (by mirroring American keyboard layout on German keyboard layout)
map - /

" <Esc> clears notices & highlights (:nohl)
exmap clearNotices obcommand obsidian-smarter-md-hotkeys:hide-notice
nmap &c& :clearNotices
nmap &n& :nohl
nmap <Esc> &c&&n&

""""""""""""""""""""""
" Navigation
""""""""""""""""""""""

" Have j and k navigate visual lines rather than logical ones
nmap j gj
nmap k gk

" consistent with emacs bindings
nmap <C-e> A
nmap <C-a> I
vmap <C-e> <Esc>A
vmap <C-a> <Esc>I

" HJKL behaves like hjkl, but bigger distance
map H g0
map L g$
map J 6gj
map K 6gk

" Spelling / Diagnostics
" Emulate `z=` (and bind it zo `zl` because more convenient; mnemonic: [z]pelling list)
exmap contextMenu obcommand editor:context-menu
nmap zl :contextMenu

exmap nextSuggestion obcommand obsidian-languagetool-plugin:ltjump-to-next-suggestion
nmap ge :nextSuggestion

" Synonyms
exmap synonymSuggestion obcommand obsidian-wordy:wordy-syn
nmap zs :synonymSuggestion

" done via Obsdian Hotkeys, so they also work in Preview Mode
" nmap <C-h> :back
" nmap <C-l> :forward
" nmap <C-j> :nextHeading
" nmap <C-k> :prevHeading

" line movement
" (don't work as expected in visual mode)
exmap lineUp obcommand editor:swap-line-up
exmap lineDown obcommand editor:swap-line-down
nmap <Up> :lineUp
nmap <Down> :lineDown
nmap <Right> dlp
nmap <Left> dlhhp

" [m]atch parenthesis
" WARNING this prevents any use of `m` for sticky cursor mappings, since there
" is no noremap
nmap m %

" [g]oto [s]ymbol
" requires Another Quick Switcher Plugin
exmap gotoHeading obcommand obsidian-another-quick-switcher:header-floating-search-in-file
nmap gs :gotoHeading

" [g]oto [f]ile (= Follow Link under cursor)
exmap followLinkUnderCursor obcommand editor:follow-link
nmap gx :followLinkUnderCursor

exmap live-grep obcommand obsidian-another-quick-switcher:grep
nmap gF :live-grep

" [g]oto [o]pen file (= Quick Switcher)
exmap quickSwitcher obcommand obsidian-another-quick-switcher:search-command_recent-search
nmap go :quickSwitcher
vmap go :quickSwitcher

" go to last change - https://vimhelp.org/motion.txt.html#g%3B
nmap gc u<C-r>

""""""""""""""""""""""
" Editing
""""""""""""""""""""""

" UNDO consistently on one key
nmap U <C-r>

" Case Switch via Smarter MD Hotkeys Plugin
exmap caseSwitch obcommand obsidian-smarter-md-hotkeys:smarter-upper-lower
nmap ü :caseSwitch
vmap ü :caseSwitch

""""""""""""""""""""""
" Line-Based Editing
""""""""""""""""""""""

" [M]erge Lines
" can't remap to J, cause there is no noremap; also the merge from Code Editor 
" Shortcuts plugin is smarter since it removes list prefixes
exmap mergeLines obcommand obsidian-editor-shortcuts:joinLines
nmap M :mergeLines

" WHITESPACE CONTROL
exmap blankBelow obcommand obsidian-editor-shortcuts:insertLineBelow
exmap blankAbove obcommand obsidian-editor-shortcuts:insertLineAbove
nmap &a& :blankAbove
nmap &b& :blankBelow

" Smarter o and O (inserting prefix for markdown lists)
nmap o &b&i
nmap O &a&i

" Add Blank Line above/below 
" HACK not using mz...`z since m remapped 
" HACK adding in ^d$ to clear the line from list markers from the o/O remapping above
nmap = O<Esc>^d$j
nmap _ o<Esc>^d$k

""""""""""""""""""""""""""""
" Markdown/Obsidian specific
""""""""""""""""""""""""""""

" [i]nspect commands in console
nmap ,i :obcommand

" [c]lean alias part of next Wikilink
" (or Link Homepage when using Auto Title Plugin)
nmap ,c F[t|"_dt]

" append to [y]aml (line 3 = tags)
nmap ,y 3ggA

" [g]oto [d]efiniton -> footnotes
" requires Footnotes Shortcut Plugin
exmap gotoFootnoteDefinition obcommand obsidian-footnotes:insert-footnote
nmap gd :gotoFootnoteDefinition
nmap gf :gotoFootnoteDefinition

" Blockquote
exmap toggleBlockquote obcommand editor:toggle-blockquote
nmap ,< :toggleBlockquote
nmap ,> :toggleBlockquote

""""""""""""""""""""""
" Indentation
""""""""""""""""""""""
" <Tab> as indentation is already implemented in Obsidian

""""""""""""""""""""""
" Text Objects
""""""""""""""""""""""

" Change Word/Selection
nmap <Space> "_ciw
vmap <Space> "_c

" Delete Word/Selection
nmap <S-Space> "_daw
vmap <S-Space> "_d

" [R]eplicate (duplicate)
exmap duplicate obcommand obsidian-editor-shortcuts:duplicateLine
nmap R :duplicate

""""""""""""""""""""""
" Visual Mode
""""""""""""""""""""""

" so VV... in normal mode selects more lines
vmap V j

" so vv goes to visual block mode
vmap v <C-v>

""""""""""""""""""""""
" Text Objects
""""""""""""""""""""""
" quicker access to [m]assive word, [q]uote, [z]ingle quote, inline cod[e],
" [r]ectangular bracket, and [c]urly braces
map am aW
map im iW
map aq a"
map iq i"
map az a'
map iz i'
map ae a`
map ie i`
map ir i[
map ar a[
map ac a{
map ic i{

""""""""""""""""""""""
" Tabs, Splits & Alt-file
""""""""""""""""""""""

" Splits
exmap splitVertical obcommand workspace:split-vertical
exmap splitHorizontal obcommand workspace:split-horizontal
exmap only obcommand workspace:close-others
nmap <C-w>v :splitVertical
nmap <C-w>h :splitHorizontal
nmap <C-w>o :only

" Tabs
exmap nextTab obcommand workspace:next-tab
exmap prevTab obcommand workspace:previous-tab
nmap gt :nextTab
nmap gT :prevTab

" Alt Buffer (emulates `:buffer #`)
exmap altBuffer jsfile Meta/obsidian-vim-helpers.js {altBuffer()}
nmap <CR> :altBuffer

""""""""""""""""""""""
" Terminal
""""""""""""""""""""""
" requires Obsidian terminal plugin

exmap open-terminal obcommand obsidian-terminal-plugin:open-terminal
" exmap edit-in-terminal obcommand obsidian-terminal-plugin:open-terminal-editor
nmap 6 :open-terminal

""""""""""""""""""""""
" Folding
""""""""""""""""""""""
" Emulate vim folding command https://vimhelp.org/fold.txt.html#fold-commands
exmap unfoldall obcommand editor:unfold-all
exmap togglefold obcommand editor:toggle-fold
exmap foldall obcommand editor:fold-all
exmap foldless obcommand editor:fold-less
exmap foldmore obcommand editor:fold-more
nmap zo :togglefold
nmap zc :togglefold
nmap za :togglefold
nmap zm :foldmore
nmap zM :foldall
nmap zr :foldless
nmap zR :unfoldall

""""""""""""""""""""""""""""
" Sneak / Hop / Lightspeed
""""""""""""""""""""""""""""
" emulate various vim motion plugins

" Sneak
" exmap sneakForward jsfile Meta/obsidian-vim-helpers.js {moveToChars(true)}
" exmap sneakBack jsfile Meta/obsidian-vim-helpers.js {moveToChars(false)}
" nmap ö :sneakForward
" nmap Ö :sneakBack

" Hop
" exmap hop obcommand mrj-jump-to-link:activate-jump-to-anywhere
" nmap ö :hop

" Lightspeed
exmap lightspeed obcommand mrj-jump-to-link:activate-lightspeed-jump
nmap ö :lightspeed

" Link Jump (similar to Vimium's f)
exmap linkjump obcommand mrj-jump-to-link:activate-jump-to-link
nmap ,f :linkjump

""""""""""""""""""""""
" Substitute
""""""""""""""""""""""
" poor man's substitute.vim 🥲
nmap s Vp
nmap S vg$p

""""""""""""""""""""""
" Comment
""""""""""""""""""""""
" poor man's comment
exmap comment obcommand obsidian-smarter-md-hotkeys:smarter-html-comments
nmap qq :comment

""""""""""""""""""""""
" Option Toggling
""""""""""""""""""""""
exmap number obcommand obsidian-smarter-md-hotkeys:toggle-line-numbers
exmap readableLineLength obcommand obsidian-smarter-md-hotkeys:toggle-readable-line-length
exmap spellcheck obcommand editor:toggle-spellcheck
exmap enableDiagnostics obsidian-languagetool-plugin:ltcheck-text

" [O]ption: line [n]umbers
map ,on :number
" [O]ption: [s]pellcheck
map ,os :spellcheck
" [O]ption: [w]rap
map ,ow :readableLineLength
" [O]ption: [d]iagnostics (language tool check)
nmap ,od :enableDiagnostics

