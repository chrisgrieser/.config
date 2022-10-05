""""""""""""""""""""""
" < Leader
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

" always paste what was yanked, not what was deleted
nmap P "0p
vmap P "0p

""""""""""""""""""""""
" < Search
""""""""""""""""""""""
" no modifier key for jumping to next word
nmap + *

" quicker Find Mode
" (by mirroring American keyboard layout on German keyboard layout)
map - /

""""""""""""""""""""""
" < Nagivation
""""""""""""""""""""""

" Have j and k navigate visual lines rather than logical ones
nmap j gj
nmap k gk

" HJKL behaves like hjkl, but bigger distance (best used with scroll offset plugin)
map H g0
map L g$
map J 7j
map K 7k

" Goto Mark
nmap ä `

" Emulate `z=` (and bind it zo `zl` because more convenient; mnemonic: [z]pelling [l]ist)
exmap contextMenu obcommand editor:context-menu
nmap zl :contextMenu
vmap zl :contextMenu

" Navigate headings, requires Code Editor Shortcuts plugin
exmap nextHeading obcommand obsidian-editor-shortcuts:goToNextHeading
exmap prevHeading obcommand obsidian-editor-shortcuts:goToPrevHeading
nmap <C-j> :nextHeading
nmap <C-k> :prevHeading

" History done via Obsdian Hotkeys, so they also work in Preview Mode
" nmap <C-h> :back
" nmap <C-l> :forward

" [g]oto [s]ymbol
" requires Another Quick Switcher Plugin
exmap gotoHeading obcommand obsidian-another-quick-switcher:header-floating-search-in-file
nmap gs :gotoHeading
vmap gs :gotoHeading

" [g]oto [f]ile (= Follow Link under cursor)
exmap followLinkUnderCursor obcommand editor:follow-link
exmap followLinkInTab obcommand editor:open-link-in-new-leaf
nmap gf :followLinkUnderCursor
nmap gx :followLinkUnderCursor
vmap gf :followLinkUnderCursor
vmap gx :followLinkUnderCursor
nmap gF :followLinkInTab
vmap gF :followLinkInTab

" [g]oto [o]pen file (= Quick Switcher)
exmap quickSwitcher obcommand obsidian-another-quick-switcher:search-command_recent-search
nmap go :quickSwitcher
vmap go :quickSwitcher

" go to last change - https://vimhelp.org/motion.txt.html#g%3B
nmap g; u<C-r>

" consistent with insert mode / emacs bindings
nmap <C-e> A
nmap <C-a> I

""""""""""""""""""""""
" < Editing
""""""""""""""""""""""

""""""""""""""""""""""
" << General Editing
""""""""""""""""""""""

" don't save small deletion in the register
" can't use "_x, cause Obsidian doesn't support noremap
nmap x "_dl
nmap cl "_dli

" Consistent with Insert Mode Selection
vmap <BS> "_d

" UNDO consistently on one key
nmap U <C-r>
vmap U <C-r>

" CASE SWITCH, (h to enable vertical navigation afterwards)
nmap Ü ~h
" Case Switch via Smarter MD Hotkeys Plugin
exmap caseSwitch obcommand obsidian-smarter-md-hotkeys:smarter-upper-lower
nmap ü :caseSwitch
" to CapitalCase without the plugin, use: nmap Ü mzlblgueh~`z
vmap ü :caseSwitch

""""""""""""""""""""""
" << Line-Based Editing
""""""""""""""""""""""

" [M]erge Lines
" can't remap to J, cause there is no noremap;
" also the merge from Code Editor Shortcuts plugin is smarter than J
exmap mergeLines obcommand obsidian-editor-shortcuts:joinLines
nmap M :mergeLines
vmap M :mergeLines

" Add Blank Line above/below
nmap = mzO<Esc>`z
nmap _ mzo<Esc>`z
" these require cursor being on the right end of the selection though...
vmap = <Esc>O<Esc>gv
vmap _ <Esc>o<Esc>gv

" Append punctuation to end of line
" `&§&` are helper commands for addings substitution to command chain,
" `A;<Esc>` does not work as insert mode keystrokes aren't supported
nmap &§&. :.s/$/./
nmap &§&, :.s/$/,/
nmap &§&; :.s/$/;/
nmap &§&" :.s/$/"/
nmap &§&' :.s/$/'/
nmap &§&: :.s/$/:/
nmap &§&) :.s/$/)/
nmap &§&] :.s/$/]/
nmap &§&} :.s/$/}/
nmap ,. mz&§&.`z
nmap ,, mz&§&,`z
nmap ,; mz&§&;`z
nmap ," mz&§&"`z
nmap ,' mz&§&'`z
nmap ,: mz&§&:`z
nmap ,) mz&§&)`z
nmap ,] mz&§&]`z
nmap ,} mz&§&}`z
" nmap ! a <Esc>hh does not work, cause insert mode keystrokes aren't supported

" Remove last character from line
nmap X mz$"_x`z

" commentary.vim emulation
nmap gcc :.s/^|$/%%/g

""""""""""""""""""""""
" << Markdown-specific
""""""""""""""""""""""

" allows Double Enter to add new line and indent with bullet points
nmap <CR> A

" delete alias part of next Wikilink
" (or Link Homepage when using Auto Title Plugin)
nmap | t|"_dt]

" append to [y]aml (line 3 = tags)
nmap ,y 3ggA

" complete a Markdown task
exmap toggleTask obcommand editor:toggle-checklist-status
nmap ,x :toggleTask

" [g]oto [d]efiniton ~= footnotes
" requires Footnotes Shortcut Plugin
exmap gotoFootnoteDefinition obcommand obsidian-footnotes:insert-footnote
nmap gd :gotoFootnoteDefinition

" Prepend Bullet or Blockquote
exmap toggleBullet obcommand editor:toggle-bullet-list
exmap toggleBlockquote obcommand editor:toggle-blockquote
nmap ,- :toggleBullet
vmap ,- :toggleBullet
nmap ,< :toggleBlockquote
vmap ,< :toggleBlockquote
nmap ,> :toggleBlockquote
vmap ,> :toggleBlockquote

" turn bolded bullet points to h2 (##)
" has to be done this complicated way cause vim substitutes called here can't
" properly process spaces
nmap &§&#a :.s/\*\*//g
nmap &§&#b :.s/^-/##/
nmap ,+ mz&§&#a&§&#bO<Esc>`z

""""""""""""""""""""""
" << Indentation
""""""""""""""""""""""
" <Tab> as indentation is already implemented in Obsidian

""""""""""""""""""""""
" < Text Objects
""""""""""""""""""""""

" Change Word/Selection
nmap <Space> "_ciw
vmap <Space> "_c

" Delete Word/Selection
nmap <S-Space> "_daw
vmap <S-Space> "_d

" [R]eplace Word with register content
nmap R viw"0p
vmap R "0P

" Change Quote Content
nmap Q "_ci"
nmap q "_ci'

""""""""""""""""""""""
" < Mode
""""""""""""""""""""""
imap jj <Esc>

" move to BOL/EOL
imap <C-a> <Esc>I
imap <C-e> <Esc>A

" Kill line
imap <C-k> <Esc>lC

" so that VV... in normal mode just selects more lines
vmap V j

""""""""""""""""""""""
" < Tabs/Window
""""""""""""""""""""""

" https://vimhelp.org/index.txt.html#CTRL-W
exmap focusRight obcommand editor:focus-right
exmap focusLeft obcommand editor:focus-left
exmap focusTop obcommand editor:focus-top
exmap focusBottom obcommand editor:focus-bottom
nmap <C-w>h :focusLeft
nmap <C-w>j :focusBottom
nmap <C-w>k :focusTop
nmap <C-w>l :focusRight

exmap splitVertical obcommand workspace:split-vertical
nmap <C-w>v :splitVertical
exmap splitHorizontal obcommand workspace:split-horizontal
nmap <C-w>s :splitHorizontal

exmap only obcommand workspace:close-others
nmap <C-w>o :only
exmap close obcommand workspace:close
nmap ZZ :close
nmap ZQ :close

" Emulate Original gt and gT https://vimhelp.org/tabpage.txt.html#gt
exmap nextTab obcommand workspace:next-tab
exmap prevTab obcommand workspace:previous-tab
nmap gt :nextTab
nmap gT :prevTab

" orginal vim: <C-w>_ for vertical maximizing, <C-w>= for equal size
exmap toggle-maximize-pane obcommand pane-relief:maximize
nmap <C-w>+ :toggle-maximize-pane
vmap <C-w>+ :toggle-maximize-pane
nmap <C-w>= :toggle-maximize-pane
vmap <C-w>= :toggle-maximize-pane

" swap pane position (Original Vim Bindings)
" requires Pane Relief Plugin
" exmap swapPane obcommand pane-relief:swap-next
" map <C-w>x :swapPane

" [g]oto next/prev [w]indow (= pane)
" requires Pane Relief Plugin
exmap nextPane obcommand pane-relief:go-next
exmap prevPane obcommand pane-relief:go-prev
map gw :nextPane
map gW :prevPane

""""""""""""""""""""""
" < Folding
""""""""""""""""""""""
" Emulate Original Folding command https://vimhelp.org/fold.txt.html#fold-commands
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

""""""""""""""""""""""
" < Sneak
""""""""""""""""""""""
" emulate vim-sneak (somewhat)
" vim sneak
" exmap nextTwoCharMatch jsfile Meta/obsidian-vim-helpers.js {moveToChars(true)}
" exmap prevTwoCharMatch jsfile Meta/obsidian-vim-helpers.js {moveToChars(false)}
" nmap s :nextTwoCharMatch
" nmap S :prevTwoCharMatch

""""""""""""""""""""""
" < Sorting
""""""""""""""""""""""
" [s]ort [s]election
vmap ,ss :'<,'>sort

" [s]ort [g]lobally
nmap ,sg :sort

" [s]ort [p]aragraph
nmap ,sp vip,ss

""""""""""""""""""""""
" < Options
""""""""""""""""""""""

" emulate shortcuts from vim.unimpaired, requires smarter MD hotkeys plugin
exmap number obcommand obsidian-smarter-md-hotkeys:toggle-line-numbers
exmap readableLineLength obcommand obsidian-smarter-md-hotkeys:toggle-readable-line-length
exmap spellcheck obcommand editor:toggle-spellcheck
" [O]ption: line [n]umbers
map ,on :number
" [O]ption: [s]pellcheck
map ,os :spellcheck
" [O]ption: line [w]rap
map ,ow :readableLineLength

