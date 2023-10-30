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
nnoremap Y y$

" don't pollute the register (HACK since we can't map to `"_x` or `"_C`)
nnoremap C "_c$
nnoremap x "_dl
" nnoremap c "_c " BUG not working with vimrc plugin

""""""""""""""""""""""
" Navigation
""""""""""""""""""""""

" navigate visual lines rather than logical ones
nnoremap j gj
nnoremap k gk
nnoremap I g0i
nnoremap A g$a

" HJKL behaves like hjkl, but bigger distance
noremap H g0
noremap L g$
nnoremap J 6gj
nnoremap K 6gk
vnoremap J 6gj
vnoremap K 6gk

onoremap J 2j
onoremap K 2k

" Jumps
nnoremap <C-h> <C-o>
nnoremap <C-l> <C-i>

" :bnext/bprev
exmap goBack obcommand app:go-back
exmap goForward obcommand app:go-forward
nnoremap <BS> :goBack
nnoremap <S-BS> :goForward

" sentence navigation
noremap [ (
noremap ] )

" [z]pelling [l]ist (emulates `z=`)
exmap contextMenu obcommand editor:context-menu
nnoremap zl :contextMenu

" next diagnostic
exmap nextSuggestion obcommand obsidian-languagetool-plugin:ltjump-to-next-suggestion
nnoremap ge :nextSuggestion
vnoremap ge :nextSuggestion

" INFO doesn't work in reading mode: https://github.com/timhor/obsidian-editor-shortcuts/issues/20
exmap nextHeading obcommand obsidian-editor-shortcuts:goToNextHeading
exmap prevHeading obcommand obsidian-editor-shortcuts:goToPrevHeading
nnoremap <C-j> :nextHeading
nnoremap <C-k> :prevHeading

" INFO doesn't work in visual mode
exmap lineUp obcommand editor:swap-line-up
exmap lineDown obcommand editor:swap-line-down
nnoremap <Up> :lineUp
nnoremap <Down> :lineDown
nnoremap <Right> dlp
nnoremap <Left> dlhhp

" [m]atch parenthesis
nnoremap m %

" [g]oto [s]ymbol via "Another Quick Switcher" Plugin
exmap gotoHeading obcommand obsidian-another-quick-switcher:header-floating-search-in-file
nnoremap gs :gotoHeading

" [g]oto [w]riting chapters
exmap gotoScene obcommand longform:longform-jump-to-scene
nnoremap gw :gotoScene

" [g]oto definition / link (shukuchi makes it forward-seeking)
exmap followNextLink obcommand shukuchi:open-link
nnoremap gx :followNextLink
nnoremap ga :followNextLink
nnoremap gd :followNextLink

" [g]oto [o]pen file (= Quick Switcher)
exmap quickSwitcher obcommand obsidian-another-quick-switcher:search-command_recent-search
nnoremap go :quickSwitcher
nnoremap gr :quickSwitcher

" go to last change (HACK, only works to jump to the last location)
nnoremap gc u<C-r>

""""""""""""""""""""""
" Search
""""""""""""""""""""""
" no modifier key for jumping to next word
nnoremap + *

" Find Mode (by mirroring American keyboard layout on German keyboard layout)
nnoremap - /

" <Esc> clears highlights
nnoremap <Esc> :nohl

" Another Quick Switcher ripgrep-search
" somewhat close to Telescope's livegrep
exmap liveGrep obcommand obsidian-another-quick-switcher:grep
nnoremap gl :liveGrep

" Obsidian builtin Search & replace
exmap searchReplace obcommand editor:open-search-replace
nnoremap ,ff :searchReplace

""""""""""""""""""""""
" Git
""""""""""""""""""""""

" Git Plugin
exmap gitAdd obcommand obsidian-git:stage-current-file
nnoremap ,ga :gitAdd
nnoremap ,gA :gitAdd

exmap gitCommit obcommand obsidian-git:commit-staged-specified-message
nnoremap ,gc :gitCommit

""""""""""""""""""""""
" Editing
""""""""""""""""""""""

" undo/redo consistently on one key
nnoremap U <C-r>

" redo all
nnoremap ,ur 1000<C-r>

" split line
vnoremap ,s gq
nnoremap ,s gqq

" Case Switch via Code Editor Shortcuts Plugin
exmap caseSwitch obcommand obsidian-editor-shortcuts:toggleCase
nnoremap ö :caseSwitch
vnoremap ö :caseSwitch

" do not move to the right on toggling case
nnoremap ~ ~h

" Move words (equivalent to sibling-swap.nvim)
nnoremap ü "zdawel"zph
nnoremap Ü "zdawbh"zph

exmap aiWrite obcommand obsidian-textgenerator-plugin:insert-generated-text-From-template
nnoremap ,a :aiWrite

exmap toggleDevtools obcommand obsidian-theme-design-utilities:toggle-devtools
nnoremap ,b :toggleDevtools
vnoremap ,b :toggleDevtools

" pseudo-code-action: enhance URL with title
exmap enhanceUrlWithTitle obcommand obsidian-auto-link-title:enhance-url-with-title
nnoremap ,c :enhanceUrlWithTitle

" Change Word/Selection
nnoremap <Space> "_ciw
onoremap <Space> iw
onoremap a<Space> iW

" Delete Word/Selection
nnoremap <S-Space> "_daw

" [R]eplicate (duplicate)
exmap duplicate obcommand obsidian-editor-shortcuts:duplicateLine
unmap w
nnoremap ww :duplicate

" [M]erge Lines
" the merge from Code Editor Shortcuts plugin is smarter than just using `J`
" since it removes stuff like list prefixes
exmap mergeLines obcommand obsidian-editor-shortcuts:joinLines
nnoremap M :mergeLines

" Make o and O respect context (requires Code Editor Shortcuts Plugin)
exmap blankAbove obcommand obsidian-editor-shortcuts:insertLineAbove
nmap &a& :blankAbove
nmap O &a&i

exmap blankBelow obcommand obsidian-editor-shortcuts:insertLineBelow
nmap &b& :blankBelow
nmap o &b&i

" Add Blank Line above/below
nnoremap = mzO<Esc>`z
nnoremap _ mzo<Esc>`z

" Increment
nnoremap + <C-a>

""""""""""""""""""""""""""""
" Markdown/Obsidian specific
""""""""""""""""""""""""""""

" [l]og commands in console
nnoremap ,l :obcommand

" [g]oto [f]ootnotes
" requires Footnotes Shortcut Plugin
exmap gotoFootnote obcommand obsidian-footnotes:insert-autonumbered-footnote
nnoremap gf :gotoFootnote

" Blockquote
exmap toggleBlockquote obcommand editor:toggle-blockquote
nnoremap ,< :toggleBlockquote
nnoremap ,> :toggleBlockquote

" list
exmap toggleList obcommand editor:toggle-bullet-list
nnoremap ,- :toggleList

" markdown tasks
exmap checkList obcommand editor:toggle-checklist-status
nnoremap ,x :checkList

""""""""""""""""""""""
" Indentation
""""""""""""""""""""""
" <Tab> as indentation is already implemented in Obsidian

""""""""""""""""""""""
" Visual Mode
""""""""""""""""""""""

" so repeated "V" selects more lines
vnoremap V gj

" so 2x v goes to visual block mode
vnoremap v <C-v>

""""""""""""""""""""""
" Text Objects
""""""""""""""""""""""

" quicker access to [m]assive word, [q]uote, [z]ingle quote, inline cod[e],
" [r]ectangular bracket, and [c]urly braces
onoremap am aW
onoremap im iW
onoremap aq a"
onoremap iq i"
onoremap az a'
onoremap iz i'
onoremap ae a`
onoremap ie i`
onoremap ir i[
onoremap ar a[
onoremap ac a{
onoremap ic i{

vnoremap am aW
vnoremap im iW
vnoremap aq a"
vnoremap iq i"
vnoremap ay a'
vnoremap iy i'
vnoremap ae a`
vnoremap ie i`
vnoremap ir i[
vnoremap ar a[
vnoremap ac a{
vnoremap ic i{

" emulate some text objects from nvim-various-textobjs
onoremap rg G
vnoremap rg G
onoremap rp }
vnoremap rp }
onoremap m t]
vnoremap m t]
onoremap w t"
vnoremap w t"

""""""""""""""""""""""
" Substitute
""""""""""""""""""""""

" poor man's substitute.nvim: brut-forcing all possible text objects :'(
nunmap s
nnoremap ss Vp
nnoremap S vg$p
nnoremap sim viWp
nnoremap sam vaWp
nnoremap siw viwp
nnoremap saw vawp
nnoremap sis visp
nnoremap sas vasp
nnoremap sip vipp
nnoremap sap vapp
nnoremap sib vi)p
nnoremap saq va"p
nnoremap siq vi"p
nnoremap saz va'p
nnoremap siz vi'p
nnoremap sae va`p
nnoremap sie vi`p
nnoremap sab va)p
nnoremap sir vi]p
nnoremap sar va]p
nnoremap sic vi}p
nnoremap sac va}p

""""""""""""""""""""""
" Tabs, Splits & Alt-file
""""""""""""""""""""""

" Close
exmap closeWindow obcommand workspace:close-window
nnoremap ZZ :closeWindow

" Splits
exmap splitVertical obcommand workspace:split-vertical
nnoremap <C-w>v :splitVertical

" Tabs
exmap nextTab obcommand workspace:next-tab
exmap prevTab obcommand workspace:previous-tab
nnoremap gt :nextTab
nnoremap gT :prevTab

" Alt Buffer (emulates `:buffer #`)
exmap altBuffer obcommand grappling-hook:alternate-note
nnoremap <CR> :altBuffer

""""""""""""""""""""""
" Comments
""""""""""""""""""""""
" basically ts-comment-string, i.e. using the appropriate comment syntax when in
" a code block
exmap contextualComment obcommand contextual-comments:advanced-comments
nnoremap qq :contextualComment

""""""""""""""""""""""
" Folding
""""""""""""""""""""""
" Emulate vim folding command
exmap togglefold obcommand editor:toggle-fold
nnoremap za :togglefold
nnoremap zo :togglefold
nnoremap zc :togglefold
nnoremap ^ :togglefold

exmap unfoldall obcommand editor:unfold-all
exmap foldall obcommand editor:fold-all
nnoremap zm :foldall
nnoremap zr :unfoldall

""""""""""""""""""""""
" Option Toggling
""""""""""""""""""""""

" [O]ption: [s]pellcheck
exmap spellcheck obcommand editor:toggle-spellcheck
nnoremap ,os :spellcheck

" [O]ption: [d]iagnostics
exmap enableDiagnostics obcommand obsidian-languagetool-plugin:ltcheck-text
nnoremap ,od :enableDiagnostics

exmap disableDiagnostics obcommand obsidian-languagetool-plugin:ltclear
nnoremap ,oD :disableDiagnostics
