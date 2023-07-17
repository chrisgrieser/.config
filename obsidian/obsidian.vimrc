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
nmap C "_d$a

""""""""""""""""""""""
" Search
""""""""""""""""""""""
" no modifier key for jumping to next word
nmap + *

" Find Mode (by mirroring American keyboard layout on German keyboard layout)
nmap - /

" <Esc> clears notices & highlights (:nohl)
exmap clearNotices obcommand obsidian-smarter-md-hotkeys:hide-notice
nmap &c& :clearNotices
nmap &n& :nohl
nmap <Esc> &c&&n&

""""""""""""""""""""""
" Navigation
""""""""""""""""""""""

" navigate visual lines rather than logical ones
noremap j gj
noremap k gk
nmap I g0i
nmap A g$a

" HJKL behaves like hjkl, but bigger distance
noremap H g0
noremap L g$
nmap J 6gj
nmap K 6gk

" sentence navigation
nmap [ (
nmap ] )

" [z]pelling [l]ist (emulates `z=`)
exmap contextMenu obcommand editor:context-menu
nmap zl :contextMenu

" next diagnostic
exmap nextSuggestion obcommand obsidian-languagetool-plugin:ltjump-to-next-suggestion
nmap ge :nextSuggestion

" INFO don't work in reading mode: https://github.com/timhor/obsidian-editor-shortcuts/issues/67
exmap nextHeading obcommand obsidian-editor-shortcuts:goToNextHeading
exmap prevHeading obcommand obsidian-editor-shortcuts:goToPrevHeading
nmap <C-j> :nextHeading
nmap <C-k> :prevHeading

" done via Obsidian Hotkeys, so they also work in Preview Mode
" nmap <C-h> :back
" nmap <C-l> :forward

" line/character movement
" (don't work as expected in visual mode)
exmap lineUp obcommand editor:swap-line-up
exmap lineDown obcommand editor:swap-line-down
nmap <Up> :lineUp
nmap <Down> :lineDown
nmap <Right> dlp
nmap <Left> dlhhp

" [m]atch parenthesis
" INFO `noremap` is only supported for mappings that are included in default
" mappings https://github.com/replit/codemirror-vim/blob/master/src/vim.js#L765
noremap m %

" [g]oto [s]ymbol
" requires Another Quick Switcher Plugin
exmap gotoHeading obcommand obsidian-another-quick-switcher:header-floating-search-in-file
nmap gs :gotoHeading

" [g]oto [w]riting chapters
exmap gotoScene obcommand longform:longform-jump-to-scene
nmap gw :gotoScene

" [g]oto definition / link (shukuchi makes it forward-seeking)
exmap followNextLink obcommand shukuchi:open-link
nmap gx :followNextLink
nmap ga :followNextLink
nmap gd :followNextLink

" HACK temporary workaround, since shukuchi does not work in 1.4.0 on URLs
exmap followLink obcommand editor:follow-link
nmap gX :followLink

" [g]oto [o]pen file (= Quick Switcher)
exmap quickSwitcher obcommand obsidian-another-quick-switcher:search-command_recent-search
nmap go :quickSwitcher
nmap gr :quickSwitcher

" go to last change (HACK, only works to jump to the last location)
nmap gc u<C-r>

""""""""""""""""""""""
" Search & replace
""""""""""""""""""""""

" exmap liveGrep obcommand omnisearch:show-modal
exmap liveGrep obcommand obsidian-another-quick-switcher:grep
nmap gl :liveGrep

exmap searchReplace obcommand editor:open-search-replace
nmap ,ff :searchReplace

exmap globalSearchReplace obcommand global-search-and-replace:search-and-replace
nmap ,v :globalSearchReplace

""""""""""""""""""""""
" Diffview, Git, Undo
""""""""""""""""""""""

exmap diffview obcommand obsidian-version-history-diff:open-git-diff-view
nmap ,gd :diffview

" closest thing we get to the undohistory :(
exmap undohistory obcommand obsidian-version-history-diff:open-recovery-diff-view
nmap ,ut :diffview

" Stage & Commit
exmap gitAdd obcommand obsidian-git:stage-current-file
nmap ,ga :gitAdd
nmap ,gA :gitAdd

exmap gitCommit obcommand obsidian-git:commit-staged-specified-message
nmap ,gc :gitCommit

""""""""""""""""""""""
" Editing
""""""""""""""""""""""

" undo consistently on one key
nmap U <C-r>

" Case Switch via Smarter MD Hotkeys Plugin
exmap caseSwitch obcommand obsidian-smarter-md-hotkeys:smarter-upper-lower
nmap ö :caseSwitch

" do not move to the right on toggling case of a character
nmap ~ ~h

" Move words (equivalent to sibling-swap.nvim)
nmap ü "zdawel"zph
nmap Ü "zdawbh"zph

""""""""""""""""""""""
" Line-Based Editing
""""""""""""""""""""""

" [M]erge Lines
" can't remap to J, cause there is no noremap; also the merge from Code Editor
" Shortcuts plugin is smarter since it removes list prefixes
exmap mergeLines obcommand obsidian-editor-shortcuts:joinLines
exmap mergeLines obcommand obsidian-editor-shortcuts:joinLines
nmap M :mergeLines

" Make o and O respect context
" requires Code Editor Shortcuts Plugin
exmap blankAbove obcommand obsidian-editor-shortcuts:insertLineAbove
nmap &a& :blankAbove
nmap O &a&i

exmap blankBelow obcommand obsidian-editor-shortcuts:insertLineBelow
nmap &b& :blankBelow
nmap o &b&i

" Add Blank Line above/below
" HACK not using mz...`z since m remapped
" HACK adding in 0d$ to clear the line from list markers from the o/O remapping above
nmap = O<Esc>0"_d$j
nmap _ o<Esc>0"_d$k

""""""""""""""""""""""""""""
" Markdown/Obsidian specific
""""""""""""""""""""""""""""

" [a]i completion
exmap aiComplete obcommand obsidian-textgenerator-plugin:generate-text
nmap ,a :aiComplete

" [l]og commands in console
nmap ,l :obcommand

" [c]lean alias part of next Wikilink
" (or link homepage when using Auto Title Plugin)
nmap ,c F[t|"_dt]

" append to [y]aml (line 3 = tags)
nmap ,y 3ggA

" [g]oto [f]ootnotes
" requires Footnotes Shortcut Plugin
exmap gotoFootnoteDefinition obcommand obsidian-footnotes:insert-autonumbered-footnote
nmap gf :gotoFootnoteDefinition

" Blockquote
exmap toggleBlockquote obcommand editor:toggle-blockquote
nmap ,< :toggleBlockquote
nmap ,> :toggleBlockquote

exmap checkList obcommand editor:toggle-checklist-status
nmap ,x :checkList
vmap ,x :checkList

""""""""""""""""""""""
" Indentation
""""""""""""""""""""""
" <Tab> as indentation is already implemented in Obsidian

""""""""""""""""""""""
" Text Objects
""""""""""""""""""""""

" Change Word/Selection
nmap <Space> "_ciw

" Delete Word/Selection
nmap <S-Space> "_daw

" [R]eplicate (duplicate)
exmap duplicate obcommand obsidian-editor-shortcuts:duplicateLine
unmap w
nmap ww :duplicate

""""""""""""""""""""""
" Visual Mode
""""""""""""""""""""""

" so VV... in normal mode selects more lines
vmap V gj

" so vv goes to visual block mode
vmap v <C-v>

""""""""""""""""""""""
" Text Objects
""""""""""""""""""""""
" quicker access to [m]assive word, [q]uote, [z]ingle quote, inline cod[e],
" [r]ectangular bracket, and [c]urly braces
omap am aW
omap im iW
omap aq a"
omap iq i"
omap az a'
omap iz i'
omap ae a`
omap ie i`
omap ir i[
omap ar a[
omap ac a{
omap ic i{
omap rg G
omap rp {

vmap am aW
vmap im iW
vmap aq a"
vmap iq i"
vmap ay a'
vmap iy i'
vmap ae a`
vmap ie i`
vmap ir i[
vmap ar a[
vmap ac a{
vmap ic i{
vmap rg G
vmap rp {

""""""""""""""""""""""
" Surround
""""""""""""""""""""""
" https://github.com/esm7/obsidian-vimrc-support#surround-text-with-surround

exmap surround_wiki surround [[ ]]
exmap surround_double_quotes surround " "
exmap surround_single_quotes surround ' '
exmap surround_backticks surround ` `
exmap surround_brackets surround ( )
exmap surround_square_brackets surround [ ]
exmap surround_curly_brackets surround { }
exmap surround_underscore surround __ __
exmap surround_asterisk surround * *

nunmap s
nmap sR :surround_wiki
nmap sq :surround_double_quotes
nmap sy :surround_single_quotes
nmap se :surround_backticks
nmap sb :surround_brackets
nmap sr :surround_square_brackets
nmap sc :surround_curly_brackets
nmap sa :surround_asterisk
nmap su :surround_underscore

vunmap s
vmap sR :surround_wiki
vmap sq :surround_double_quotes
vmap sy :surround_single_quotes
vmap se :surround_backticks
vmap sb :surround_brackets
vmap sr :surround_square_brackets
vmap sc :surround_curly_brackets
vmap sa :surround_asterisk
vmap su :surround_underscore

""""""""""""""""""""""
" Substitute
""""""""""""""""""""""
" poor man's substitute.nvim 🥲
nmap ss Vp
nmap S vg$p

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
nmap <BS> :nextTab
nmap gt :nextTab
nmap gT :prevTab

" Alt Buffer (emulates `:buffer #`)
exmap altBuffer obcommand grappling-hook:alternate-note
nmap <CR> :altBuffer

""""""""""""""""""""""
" Comments
""""""""""""""""""""""
" basically ts-comment-string, i.e. using the appropriate comment syntax when in
" a code block
exmap contextualComment obcommand contextual-comments:advanced-comments
nmap qq :contextualComment

""""""""""""""""""""""
" Folding
""""""""""""""""""""""
" Emulate vim folding command
exmap unfoldall obcommand editor:unfold-all
exmap togglefold obcommand editor:toggle-fold
exmap foldall obcommand editor:fold-all
exmap foldless obcommand editor:fold-less
exmap foldmore obcommand editor:fold-more

" nmap zo :togglefold
" nmap zc :togglefold
" nmap za :togglefold
nmap zm :foldmore
nmap zM :foldall
nmap zr :foldless
nmap zR :unfoldall

" mapped to ^ via karabiner
nmap <F1> :togglefold

""""""""""""""""""""""""""""
" Sneak / Hop / Lightspeed
""""""""""""""""""""""""""""
" emulate various vim motion plugins

" Hop
" exmap hop obcommand mrj-jump-to-link:activate-jump-to-anywhere
" nmap ö :hop

" Lightspeed
" exmap lightspeed obcommand mrj-jump-to-link:activate-lightspeed-jump
" nmap ö :lightspeed

" Link Jump (similar to Vimium's f)
" exmap linkjump obcommand mrj-jump-to-link:activate-jump-to-link
" nmap ,l :linkjump

""""""""""""""""""""""
" Move selection to new file (nvim-genghis)
""""""""""""""""""""""
exmap selectionToNewFile obcomamnd templater-obsidian:Meta/Templater/>_Create_Related_Note.md
vmap X :selectionToNewFile

""""""""""""""""""""""
" Option Toggling
""""""""""""""""""""""

" [O]ption: line [n]umbers
exmap number obcommand obsidian-smarter-md-hotkeys:toggle-line-numbers
nmap ,on :number

" [O]ption: [s]pellcheck
exmap spellcheck obcommand editor:toggle-spellcheck
nmap ,os :spellcheck

" [O]ption: [w]rap
exmap readableLineLength obcommand obsidian-smarter-md-hotkeys:toggle-readable-line-length
nmap ,ow :readableLineLength

" [O]ption: [d]iagnostics (language tool check)
exmap enableDiagnostics obcommand obsidian-languagetool-plugin:ltcheck-text
nmap ,od :enableDiagnostics
