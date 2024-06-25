"───────────────────────────────────────────────────────────────────────────────
" LEADER

" Can't set leaders in Obsidian vim, so the key just has to be used consistently.
" However, it needs to be unmapped, to not trigger default behavior: https://github.com/esm7/obsidian-vimrc-support#some-help-with-binding-space-chords-doom-and-spacemacs-fans
unmap ,

"───────────────────────────────────────────────────────────────────────────────
" CLIPBOARD

" yank to system clipboard
set clipboard=unnamed

" Y consistent with D and C to the end of line
nnoremap Y y$

" don't pollute the register (HACK since we can't map to `"_x` or `"_C`)
nnoremap C "_c$
nnoremap x "_dl
" nnoremap c "_c " BUG not working with vimrc plugin

" don't override register
vnoremap p P

" paste url into selection/cword
" macOS: as opposed to nvim, cmd-key mappings are <M-*>, not <D-*>
noremap <M-k> :pasteinto

"───────────────────────────────────────────────────────────────────────────────

" Copy Path segments
exmap copyAbsolutePath jsfile Meta/vimrc-jsfile.js { copyPathSegment("absolute") }
exmap copyRelativePath jsfile Meta/vimrc-jsfile.js { copyPathSegment("relative") }
exmap copyFilename jsfile Meta/vimrc-jsfile.js { copyPathSegment("filename") }

noremap <C-p> :copyAbsolutePath
inoremap <C-p> :copyAbsolutePath
noremap <C-t> :copyRelativePath
inoremap <C-t> :copyRelativePath
noremap <C-n> :copyFilename
inoremap <C-n> :copyFilename

"───────────────────────────────────────────────────────────────────────────────
" NAVIGATION

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
vnoremap J 6j
vnoremap K 6k

" dj = delete 2 lines, dJ = delete 3 lines
onoremap J 2j

" Jumps
nnoremap <C-h> <C-o>
nnoremap <C-l> <C-i>

" Language tools: next/prev/accept suggestion
exmap nextSuggestion obcommand obsidian-languagetool-plugin:ltjump-to-next-suggestion
noremap ge :nextSuggestion

exmap prevSuggestion obcommand obsidian-languagetool-plugin:ltjump-to-previous-suggestion
noremap gE :prevSuggestion

exmap acceptSuggestion obcommand obsidian-languagetool-plugin:ltaccept-suggestion-1
noremap ga :acceptSuggestion

" next/prev heading
exmap gotoNextHeading jsfile Meta/vimrc-jsfile.js { gotoHeading("next") }
nnoremap <C-j> :gotoNextHeading
exmap gotoPrevHeading jsfile Meta/vimrc-jsfile.js { gotoHeading("prev") }
nnoremap <C-k> :gotoPrevHeading

" [m]atch parenthesis
nnoremap m %

" [g]oto [s]ymbol (using Another Quick Switcher)
exmap gotoHeading obcommand obsidian-another-quick-switcher:header-floating-search-in-file
nnoremap gs :gotoHeading

" [g]oto [w]riting
exmap gotoScene obcommand longform:longform-jump-to-scene
nnoremap gw :gotoScene

" like vim's gx (if not standing on link, seek forward)
exmap openNextLink jsfile Meta/vimrc-jsfile.js { openNextLink("current-tab") }
nnoremap gx :openNextLink

exmap openNextLinkInNewTab jsfile Meta/vimrc-jsfile.js { openNextLink("new-tab") }
nnoremap gX :openNextLinkInNewTab

" [g]oto [f]ootnotes
" requires Footnotes Shortcut Plugin
exmap gotoFootnote obcommand obsidian-footnotes:insert-autonumbered-footnote
nnoremap gf :gotoFootnote

" go to last change (HACK, only works to jump to the last location)
nnoremap g; u<C-r>

" repeat f/t
nnoremap ö ;
nnoremap Ö ,

"───────────────────────────────────────────────────────────────────────────────
" FILE-, TAB- AND WINDOW-NAVIGATION

" [g]oto [o]pen file (= Quick Switcher)
exmap quickSwitcher obcommand obsidian-another-quick-switcher:search-command_main-search
noremap go :quickSwitcher
noremap gr :quickSwitcher

exmap propertySearch obcommand obsidian-another-quick-switcher:search-command_property-search
noremap gp :propertySearch

" :bnext/bprev
exmap goBack obcommand app:go-back
exmap goForward obcommand app:go-forward
noremap <BS> :goBack
noremap <S-BS> :goForward

" Close
exmap closeWindow obcommand workspace:close-window
nnoremap ZZ :closeWindow

" Splits
exmap splitVertical obcommand workspace:split-vertical
noremap <C-w>v :splitVertical
noremap <C-v> :splitVertical

" Tabs
exmap nextTab obcommand workspace:next-tab
exmap prevTab obcommand workspace:previous-tab
nnoremap gt :nextTab
nnoremap gT :prevTab

exmap closeOthers obcommand workspace:close-others
nnoremap <C-w>o :closeOthers

" Alt Buffer (emulates `:buffer #`)
exmap altBuffer obcommand grappling-hook:alternate-note
noremap <CR> :altBuffer

" Random File
exmap openRandomDataFile jsfile Meta/vimrc-jsfile.js { openRandomNoteIn("Data", "read", false) }
noremap <C-Tab> :openRandomDataFile

"───────────────────────────────────────────────────────────────────────────────
" SEARCH

" Find Mode (by mirroring American keyboard layout on German keyboard layout)
nnoremap - /

" <Esc> clears highlights & notices
" (cannot combine excommands, therefore combining them to a mapping first)
exmap clearNotices jsfile Meta/vimrc-jsfile.js { clearNotices() }
nmap &c& :clearNotices
nmap &n& :nohl
nmap <Esc> &c&&n&

" Another Quick Switcher ripgrep-search (somewhat close to Telescope's livegrep)
exmap liveGrep obcommand obsidian-another-quick-switcher:grep
nnoremap gl :liveGrep

" Obsidian's builtin search & replace
exmap searchReplace obcommand editor:open-search-replace
nnoremap ,ff :searchReplace
nnoremap ,fs :searchReplace
vnoremap ,ff y:searchReplace
vnoremap ,fs y:searchReplace

"───────────────────────────────────────────────────────────────────────────────
" EDITING

" Indentation
" <Tab> as indentation is already implemented in Obsidian

" Move lines (doesn't work in visual mode)
exmap lineUp obcommand editor:swap-line-up
exmap lineDown obcommand editor:swap-line-down
nnoremap <Up> :lineUp
nnoremap <Down> :lineDown

" Move character under cursor
nnoremap <Right> dlp
nnoremap <Left> dlhhp

" Move words (equivalent to sibling-swap.nvim)
" nnoremap ä "zdawel"zph
" nnoremap Ä "zdawbh"zph
" above is for single words, below does not trip on ', etc.
nnoremap ä "zdawB"zPB
nnoremap Ä "zdawEl"zpB

" spelling suggestions (emulates `z=`)
exmap contextMenu obcommand editor:context-menu
nnoremap zl :contextMenu
vnoremap zl :contextMenu

" undo/redo consistently on one key
nnoremap U <C-r>

" redo all
nnoremap ,ur 1000<C-r>

" toggle lowercase/Titlecase
exmap toggleLowercaseTitleCase jsfile Meta/vimrc-jsfile.js { toggleLowercaseTitleCase() }
nnoremap < :toggleLowercaseTitleCase

" do not move to the right on toggling case
nnoremap ~ ~h

" Change word/selection
nnoremap <Space> "_ciw
vnoremap <Space> "_c
onoremap <Space> iw
nnoremap <S-Space> "_daw

" [M]erge lines (removing list or blockquote)
exmap smartMerge jsfile Meta/vimrc-jsfile.js { smartMerge() }
nnoremap M :smartMerge

" [s]plit line
nnoremap ,s i<CR><CR><Esc>

" o and O (respecting list or blockquote)
exmap blankBelow jsfile Meta/vimrc-jsfile.js { smartInsertBlank("below") }
nnoremap o :blankBelow
exmap blankAbove jsfile Meta/vimrc-jsfile.js { smartInsertBlank("above") }
nnoremap O :blankAbove

" Add Blank Line above/below
nnoremap = mzO<Esc>`z
nnoremap _ mzo<Esc>`z

" Increment/Decrement
nnoremap + <C-a>
nnoremap ü <C-x>

" JS Comments
nunmap q
exmap toggleJsLineComment jsfile Meta/vimrc-jsfile.js { toggleJsLineComment() }
nnoremap qq :toggleJsLineComment
exmap appendJsComment jsfile Meta/vimrc-jsfile.js { appendJsComment() }
nnoremap Q :appendJsComment

" markdown tasks
exmap checkList obcommand editor:toggle-checklist-status
nnoremap ,x :checkList

" blockquote
exmap toggleBlockquote obcommand editor:toggle-blockquote
nnoremap ,< :toggleBlockquote

exmap insertHr jscommand { editor.replaceSelection("\n---\n"); }
nnoremap qw :insertHr

"───────────────────────────────────────────────────────────────────────────────
" LEADER MAPPINGS

" [d]evTools
exmap toggleDevtools jscommand { electronWindow.toggleDevTools() }
nnoremap ,d :toggleDevtools

" [L]og Variable
exmap consoleLogFromWordUnderCursor jsfile Meta/vimrc-jsfile.js { consoleLogFromWordUnderCursor() }
nnoremap ,ll :consoleLogFromWordUnderCursor

" Enhance URL with title (same hotkey as [c]ode action in nvim)
exmap enhanceUrlWithTitle obcommand obsidian-auto-link-title:enhance-url-with-title
nnoremap ,cc :enhanceUrlWithTitle

" Workspace
exmap loadWorkspace jsfile Meta/vimrc-jsfile.js { workspace("load", "Basic") }
nnoremap ,w :loadWorkspace
exmap saveWorkspace jsfile Meta/vimrc-jsfile.js { workspace("save", "Basic") }
nnoremap ,W :saveWorkspace

" Freeze Interface
exmap freezeInterface jsfile Meta/vimrc-jsfile.js { freezeInterface() }
nnoremap ,F :freezeInterface

" Rephraser: [a]ccept/[r]eject
exmap acceptSuggestionsInLine jsfile Meta/vimrc-jsfile.js { highlightsAndStrikthrus("accept") }
nnoremap ,a :acceptSuggestionsInLine
exmap rejectSuggestionsInLine jsfile Meta/vimrc-jsfile.js { highlightsAndStrikthrusInLine("reject") }
nnoremap ,r :rejectSuggestionsInLine

" Add [y]aml property
exmap addProperty obcommand markdown:add-metadata-property
nnoremap ,y :addProperty

" set "[r]ead: true" property
exmap addYamlKey jsfile Meta/vimrc-jsfile.js { addYamlKey("read", true) }
nnoremap ,r :addYamlKey

" [i]nspect [w]ord count
exmap inspectWordCount jsfile Meta/vimrc-jsfile.js { inspectWordCount() }
nnoremap ,iw :inspectWordCount

" [i]nspect chrome [v]ersion
exmap inspectChromeVersion jscommand { new Notice ('Chrome version: ' + process.versions.chrome.split('.')[0], 4000) }
nnoremap ,iv :inspectChromeVersion

"───────────────────────────────────────────────────────────────────────────────
" META: PLUGIN- AND SETTING-RELATED BINDINGS

exmap updatePlugins jsfile Meta/vimrc-jsfile.js { updatePlugins() }
nnoremap ,pp :updatePlugins

" open [p]lugin [d]irectory
exmap openPluginDir jscommand { view.app.openWithDefaultApp(view.app.vault.configDir + '/plugins'); }
nnoremap ,pd :openPluginDir

" open [s]nippet directory
exmap openSnippetDir jscommand { view.app.openWithDefaultApp(view.app.vault.configDir + '/snippets'); }
nnoremap ,ps :openSnippetDir

" open [a]ppearance settings
exmap openAppearanceSettings jsfile Meta/vimrc-jsfile.js { openAppearanceSettings() }
nnoremap ,pa :openAppearanceSettings

" [i] install [p]lugins
exmap installPlugins jscommand { view.app.workspace.protocolHandlers.get("show-plugin")({ id: ' ' }); }
nnoremap ,pi :installPlugins

" open trash
exmap openTrash jscommand { view.app.openWithDefaultApp("/.trash"); }
nnoremap ,t :openTrash

" dynamic [h]ighlights settings
exmap openDynamicHighlightsSettings jsfile Meta/vimrc-jsfile.js { openDynamicHighlightsSettings() }
nnoremap ,ph :openDynamicHighlightsSettings

" Cycle Colorscheme
exmap cycleColorscheme jsfile Meta/vimrc-jsfile.js { cycleColorscheme() }
nnoremap ,pc :cycleColorscheme

" Open this vimrc file
exmap openVimrc jscommand { view.app.openWithDefaultApp("Meta/obsidian-vimrc.vim"); }
nnoremap g, :openVimrc

"───────────────────────────────────────────────────────────────────────────────
" VISUAL MODE

" so repeated "V" selects more lines
vnoremap V gj

" so 2x v goes to visual block mode
vnoremap v <C-v>

"───────────────────────────────────────────────────────────────────────────────
" TEXT OBJECTS

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
nnoremap ygg ggyG
nnoremap dgg ggdG
nnoremap cgg ggcG

onoremap rg G
vnoremap rg G
onoremap rp }
vnoremap rp }
onoremap m t]
vnoremap m t]
onoremap w t"
vnoremap w t"
onoremap k i"
onoremap K a"

"───────────────────────────────────────────────────────────────────────────────
" SUBSTITUTE

" HACK poor man's substitute.nvim: brut-forcing all possible text objects 💀
nunmap s

nnoremap ss VP
nnoremap S vg$P
nnoremap sj VjP
nnoremap sJ VjjP
nnoremap sim viWP
nnoremap sam vaWP
nnoremap siw viwP
nnoremap saw vawP
nnoremap sis visP
nnoremap sas vasP
nnoremap sip VipP
nnoremap sap VapP
nnoremap sib vi)P
nnoremap saq va"P
nnoremap siq vi"P
nnoremap sk vi"P
nnoremap saz va'P
nnoremap siz vi'P
nnoremap sae va`P
nnoremap sie vi`P
nnoremap sab va)P
nnoremap sir vi]P
nnoremap sar va]P
nnoremap sic vi}P
nnoremap sac va}P
nnoremap srg vGP
nnoremap srp v}P
nnoremap sgg vggGP
nnoremap sm vt]P

"───────────────────────────────────────────────────────────────────────────────

" HACK poor man's duplicate.nvim: brut-forcing all possible text objects 💀
unmap w
nunmap w

nnoremap ww yyp
nnoremap W y$$p

nnoremap wj yjjp
nnoremap wim yiWp
nnoremap wam yaWp
nnoremap wiw yiwp
nnoremap waw yawp
nnoremap wis yisp
nnoremap was yasp
nnoremap wip yipP
nnoremap wap yapP
nnoremap wib yi)p
nnoremap waq ya"p
nnoremap wiq yi"p
nnoremap wk yi"p
nnoremap waz ya'p
nnoremap wiz yi'p
nnoremap wae ya`p
nnoremap wie yi`p
nnoremap wab ya)p
nnoremap wir yi]p
nnoremap war ya]p
nnoremap wic yi}p
nnoremap wac ya}p
nnoremap wrg yGp
nnoremap wrp y}p
nnoremap wm yt]p

"───────────────────────────────────────────────────────────────────────────────
" FOLDING

" Emulate vim folding command
exmap togglefold obcommand editor:toggle-fold
nnoremap za :togglefold
nnoremap ^ :togglefold
nnoremap zo :togglefold
nnoremap zc :togglefold

exmap unfoldall obcommand editor:unfold-all
exmap foldall obcommand editor:fold-all
nnoremap zm :foldall
nnoremap zz :foldall
nnoremap zr :unfoldall

"───────────────────────────────────────────────────────────────────────────────
" OPTION TOGGLING

" [O]ption: [s]pellcheck
exmap spellcheck obcommand editor:toggle-spellcheck
nnoremap ,os :spellcheck

" [O]ption: [n]umbers
exmap toggleLineNumbers jsfile Meta/vimrc-jsfile.js { toggleLineNumbers() }
nnoremap ,on :toggleLineNumbers

" [O]ption: [d]iagnostics
exmap enableDiagnostics obcommand obsidian-languagetool-plugin:ltcheck-text
nnoremap ,od :enableDiagnostics
exmap disableDiagnostics obcommand obsidian-languagetool-plugin:ltclear
nnoremap ,oD :disableDiagnostics

" [O]ption: [a]completion
exmap toggleAiCompletion obcommand copilot-auto-completion:toggle
nnoremap ,oa :toggleAiCompletion

"───────────────────────────────────────────────────────────────────────────────
" AI SUGGESTIONS

" macOS: as opposed to nvim, cmd-key mappings are <M-*>, not <D-*>
" insert mode: accept suggestion
" normal mode: format
exmap acceptGhostText obcommand copilot-auto-completion:accept
inoremap <M-s> :acceptGhostText

exmap lint obcommand obsidian-linter:lint-file
nnoremap <M-s> :lint
