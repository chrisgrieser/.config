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
" disabled due to koala's PR
set clipboard=unnamed

" Y consistent with D and C to the end of line
nmap Y y$

" always paste what was yanked, not what was deleted
nmap P "0p

" append to register
map gy "Yy
map gx "Yd
" paste from register
map gp "yp

""""""""""""""""""""""
" < Search
""""""""""""""""""""""
" no modifier key for jumping to next word
nmap + *

" quicker Find Mode
" (by mirroring American keyboard layout on German keyboard layout)
map - /

" [M]ute search highlights
nmap <C-m> :nohlsearch

""""""""""""""""""""""
" < Nagivation
""""""""""""""""""""""
imap jj <Esc>

" Scroll horizontally back
nmap Q mz0`z

" Have j and k navigate visual lines rather than logical ones
nmap j gj
nmap k gk

" g0 and g$ fix by @koala
exmap endOfVisualLine jsfile Meta/obsidian-vim-helpers.js {goToEnd()}
exmap startOfVisualLine jsfile Meta/obsidian-vim-helpers.js {goToStart()}
nmap g0 :startOfVisualLine
nmap g$ :endOfVisualLine

" // Save these as "Meta/obsidian-vim-helpers.js" in your vault
" function movementHelper() {
"     const editor = app.workspace.activeLeaf.view.editor
"     let pos = {from: editor.posToOffset(editor.getCursor('from')), to: editor.posToOffset(editor.getCursor('to')), head: editor.posToOffset(editor.getCursor('head')), anchor: editor.posToOffset(editor.getCursor('anchor')), empty: true}
"     return pos
" }
" function goToEnd() {
"     const pos = movementHelper()
"     const endOfLine = editor.cm.moveToLineBoundary(pos, true)
"     editor.setCursor(editor.offsetToPos(endOfLine.from -1))
" }
" function goToStart() {
"     const pos = movementHelper()
"     const startOfLine = editor.cm.moveToLineBoundary(pos, false)
"     editor.setCursor(editor.offsetToPos(startOfLine.from))
" }

" HJKL behaves like hjkl, but bigger distance (best used with scroll offset plugin)
nmap H g0
vmap H g0
nmap L g$
vmap L g$
nmap J 6j
vmap J 6j
nmap K 6k
vmap K 6k

" cause easier to press, lol
nmap [ (
nmap ] )

" Goto Mark
nmap ä `

" Add to Dictionary (not directly accessible, only via Context Menu)
exmap contextMenu obcommand editor:context-menu
nmap zg :contextMenu
vmap zg :contextMenu

" Navigate headings, requires Code Editor Shortcuts plugin
exmap nextHeading obcommand obsidian-editor-shortcuts:goToNextHeading
exmap prevHeading obcommand obsidian-editor-shortcuts:goToPrevHeading
nmap <C-j> :nextHeading
nmap <C-k> :prevHeading

" Navigating Pane History done via Obsdian Hotkeys, so they also work
" in Preview Mode
" exmap back obcommand app:go-back
" nmap <C-h> :back
" exmap forward obcommand app:go-forward
" nmap <C-l> :forward

" [g]oto [s]ymbol
" requires Another Quick Switcher Plugin
exmap gotoHeading obcommand obsidian-another-quick-switcher:header-search-in-file
nmap gs :gotoHeading
vmap gs :gotoHeading

" [g]oto [f]ile (= Follow Link under cursor)
exmap followLinkUnderCursor obcommand editor:follow-link
exmap followLinkInNewPane obcommand editor:open-link-in-new-leaf
nmap gf :followLinkUnderCursor
vmap gf :followLinkUnderCursor
nmap gF :followLinkInNewPane
vmap gF :followLinkInNewPane

" [g]oto [o]pen file (= Quick Switcher)
exmap quickSwitcher obcommand obsidian-another-quick-switcher:filename-recent-search
nmap go :quickSwitcher
vmap go :quickSwitcher

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

" TRANSPOSE
" (can't use x, cause it sends to black hole registry, due to missing noremap)
" current & next char
nmap ö dlp
imap <C-t> <Esc>dlpi
" current & previous char
nmap Ö dlhhp
" current & next word
nmap Ä dawelpb

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
" `A;<Esc>` does not work as insert mode mappings aren't remembered
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
" nmap ,x mz^lllrx`z

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
" has to be done this complicated way cause vim substitutes called in maps can't
" properly process spaces
nmap &§&#a :.s/\*\*//g
nmap &§&#b :.s/^-/##/
nmap ,+ mz&§&#a&§&#bO<Esc>`z

""""""""""""""""""""""
" << Indentation
""""""""""""""""""""""
" Tab as indentation is already implemented in Obsidian

" Can't `map ° =` due to missing noremap... :/

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

""""""""""""""""""""""
" < Insert Mode
""""""""""""""""""""""
" mirroring emacs commands available globally on Mac

" move to BOL/EOL
imap <C-a> <Esc>I
imap <C-e> <Esc>A

" Kill line
imap <C-k> <Esc>lC

" Kill line backwards
imap <C-j> <Esc>c^

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
nmap <C-w>q :close
nmap <C-w>c :close

" Original gt and gT https://vimhelp.org/tabpage.txt.html#gt
" requires Pane Relief Plugin
exmap nextPane obcommand pane-relief:go-next
exmap prevPane obcommand pane-relief:go-prev
nmap gt :nextPane
nmap gT :prevPane

" Cycle Window (Original Vim Bindings)
" requires Pane Relief Plugin
nmap <C-w><C-w> :nextPane
nmap <C-w>w :nextPane

" [g]oto next/prev [w]indow (in Obsidian essentially the same as gt)
" requires Pane Relief Plugin
nmap gw :nextPane
vmap gw :nextPane
nmap gW :prevPane
vmap gW :prevPane

" swap pane position (Original Vim Bindings)
" requires Pane Relief Plugin
exmap swapPane obcommand pane-relief:swap-next
exmap movePaneToFarLeft obcommand pane-relief:put-1st
exmap movePaneToFarRight obcommand pane-relief:put-last
nmap <C-w>x :swapPane
vmap <C-w>x :swapPane
nmap <C-w>H :movePaneToFarLeft
vmap <C-w>H :movePaneToFarLeft
nmap <C-w>L :movePaneToFarRight
vmap <C-w>L :movePaneToFarRight

""""""""""""""""""""""
" < Folding
""""""""""""""""""""""
" Emulate Folding https://vimhelp.org/fold.txt.html#fold-commands
exmap togglefold obcommand editor:toggle-fold
nmap zo :togglefold
nmap zc :togglefold
nmap za :togglefold

exmap unfoldall obcommand editor:unfold-all
nmap zR :unfoldall
exmap foldall obcommand editor:fold-all
nmap zM :foldall

" more folding things available when using the Creases plugin
" https://discord.com/channels/686053708261228577/716028884885307432/979141099878760449
" exmap foldCurrent obcommand creases:increase-fold-level-at-cursor
" exmap unfoldCurrent obcommand creases:decrease-fold-level-at-cursor
" exmap increaseFolding obcommand creases:decrease-fold-level
" exmap reduceFolding obcommand creases:increase-fold-level
" nmap zc :foldCurrent
" nmap zo :unfoldCurrent
" nmap zm :increaseFolding
" nmap zr :reduceFolding

""""""""""""""""""""""
" < Sneak
""""""""""""""""""""""
" emulate vim-sneak (somewhat)
" vim sneak
exmap nextTwoCharMatch jsfile Meta/obsidian-vim-helpers.js {moveToChars(true)}
exmap prevTwoCharMatch jsfile Meta/obsidian-vim-helpers.js {moveToChars(false)}
nmap s :nextTwoCharMatch
nmap S :prevTwoCharMatch

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

" shortcuts from vim.unimpaired
exmap number obcommand obsidian-smarter-md-hotkeys:toggle-line-numbers
exmap readableLineLength obcommand obsidian-smarter-md-hotkeys:toggle-readable-line-length
exmap spellcheck obcommand editor:toggle-spellcheck

" [O]ption: line [n]umbers
map ,on :number
" [O]ption: [s]pellcheck
map ,os :spellcheck
" [O]ption: line [w]rap
map ,ow :readableLineLength

""""""""""""""""""""""
" < unused keys
""""""""""""""""""""""
" ? !
