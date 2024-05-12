"───────────────────────────────────────────────────────────────────────────────
" LEADER

" equivalent to `let mapleader = ,`
" can't set leaders in Obsidian vim, so the key just has to be used consistently.
" However, it needs to be unmapped, to not trigger default behavior:
" https://github.com/esm7/obsidian-vimrc-support#some-help-with-binding-space-chords-doom-and-spacemacs-fans
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

"───────────────────────────────────────────────────────────────────────────────

" Copy Absolute Path
exmap copyAbsolutePath jsfile Meta/vimrc-jscommands.js { copyAbsolutePath() }
noremap <C-p> :copyAbsolutePath
inoremap <C-p> :copyAbsolutePath

" Copy Relative Path
exmap copyRelativePath jsfile Meta/vimrc-jscommands.js { copyRelativePath() }
noremap <C-t> :copyRelativePath
inoremap <C-t> :copyRelativePath

" Copy Name
exmap copyFilename jsfile Meta/vimrc-jscommands.js { copyFilename() }
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
nnoremap ge :nextSuggestion
vnoremap ge :nextSuggestion

exmap prevSuggestion obcommand obsidian-languagetool-plugin:ltjump-to-previous-suggestion
nnoremap gE :prevSuggestion
vnoremap gE :prevSuggestion

exmap acceptSuggestion obcommand obsidian-languagetool-plugin:ltaccept-suggestion-1
nnoremap ga :acceptSuggestion
vnoremap ga :acceptSuggestion

" next/prev heading
exmap gotoNextHeading jsfile Meta/vimrc-jscommands.js { gotoHeading("next") }
nnoremap <C-j> :gotoNextHeading
exmap gotoPrevHeading jsfile Meta/vimrc-jscommands.js { gotoHeading("prev") }
nnoremap <C-k> :gotoPrevHeading

" [m]atch parenthesis
nnoremap m %

" [g]oto [s]ymbol (via "Another Quick Switcher" Plugin)
exmap gotoHeading obcommand obsidian-another-quick-switcher:header-floating-search-in-file
nnoremap gs :gotoHeading

" [g]oto [p]roject chapters
exmap gotoScene obcommand longform:longform-jump-to-scene
nnoremap gp :gotoScene

" [g]oto definition / link (shukuchi makes it forward-seeking)
exmap followNextLink obcommand shukuchi:open-link
exmap followNextLinkInNewTab obcommand shukuchi:open-link-in-new-tab
nnoremap gx :followNextLink
nnoremap gX :followNextLinkInNewTab
nnoremap gd :followNextLink
nnoremap gD :followNextLinkInNewTab

" [g]oto [f]ootnotes
" requires Footnotes Shortcut Plugin
exmap gotoFootnote obcommand obsidian-footnotes:insert-autonumbered-footnote
nnoremap gf :gotoFootnote

" go to last change (HACK, only works to jump to the last location)
nnoremap g, u<C-r>

" repeat f/t
nnoremap ö ;
nnoremap Ö ,

"───────────────────────────────────────────────────────────────────────────────
" FILE-, TAB- AND WINDOW-NAVIGATION

" [g]oto [o]pen file (= Quick Switcher)
exmap quickSwitcher obcommand obsidian-another-quick-switcher:search-command_recent-search
nnoremap go :quickSwitcher
nnoremap gr :quickSwitcher

exmap propertySearch obcommand obsidian-another-quick-switcher:search-command_property-search
nnoremap gO :propertySearch

" :bnext/bprev
exmap goBack obcommand app:go-back
exmap goForward obcommand app:go-forward
nnoremap <BS> :goBack
nnoremap <S-BS> :goForward

" Close
exmap closeWindow obcommand workspace:close-window
nnoremap ZZ :closeWindow

" Splits
exmap splitVertical obcommand workspace:split-vertical
nnoremap <C-w>v :splitVertical
nnoremap <C-v> :splitVertical

" Tabs
exmap nextTab obcommand workspace:next-tab
exmap prevTab obcommand workspace:previous-tab
nnoremap gt :nextTab
nnoremap gT :prevTab

exmap closeOthers obcommand workspace:close-others
nnoremap <C-w>o :closeOthers

" Alt Buffer (emulates `:buffer #`)
exmap altBuffer obcommand grappling-hook:alternate-note
nnoremap <CR> :altBuffer

"───────────────────────────────────────────────────────────────────────────────
" SEARCH

" Find Mode (by mirroring American keyboard layout on German keyboard layout)
nnoremap - /

" <Esc> clears highlights & notices
" (cannot combine excommands, therefore combining them to a mapping first)
exmap clearNotices jsfile Meta/vimrc-jscommands.js { clearNotices() }
nmap &c& :clearNotices
nmap &n& :nohl
nmap <Esc> &c&&n&

" Another Quick Switcher ripgrep-search
" somewhat close to Telescope's livegrep
exmap liveGrep obcommand obsidian-another-quick-switcher:grep
nnoremap gl :liveGrep

" Obsidian builtin Search & replace
exmap searchReplace obcommand editor:open-search-replace
nnoremap ,ff :searchReplace
nnoremap ,fs :searchReplace

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

" split line
vnoremap ,s gq
nnoremap ,s gqq

" case switch via Code Editor Shortcuts Plugin
exmap caseSwitch obcommand obsidian-editor-shortcuts:toggleCase
nnoremap < :caseSwitch

" do not move to the right on toggling case
nnoremap ~ ~h

" Change Word/Selection
nnoremap <Space> "_ciw
vnoremap <Space> "_c
onoremap <Space> iw
nnoremap <S-Space> "_daw

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

" Increment/Decrement
nnoremap + <C-a>
nnoremap ü <C-x>

" JS Comments
nunmap q
exmap toggleJsLineComment jsfile Meta/vimrc-jscommands.js { toggleJsLineComment() }
nnoremap qq :toggleJsLineComment
exmap appendJsComment jsfile Meta/vimrc-jscommands.js { appendJsComment() }
nnoremap Q :appendJsComment

" markdown tasks
exmap checkList obcommand editor:toggle-checklist-status
nnoremap ,x :checkList

" blockquote
exmap toggleBlockquote obcommand editor:toggle-blockquote
nnoremap ,< :toggleBlockquote
nnoremap ,> :toggleBlockquote

exmap insertHr jscommand { editor.replaceSelection("\n---\n"); }
nnoremap qw :insertHr

"───────────────────────────────────────────────────────────────────────────────
" LEADER MAPPINGS
" (the weird mappings are due to mirroring my nvim-mappings)

exmap fileRecovery obcommand file-recovery:open
nnoremap ,ut :fileRecovery
nnoremap ,gd :fileRecovery

" Open Console
exmap toggleDevtools jscommand { electronWindow.toggleDevTools() }
nnoremap ,l :toggleDevtools

" Enhance URL with title
exmap enhanceUrlWithTitle obcommand obsidian-auto-link-title:enhance-url-with-title
nnoremap ,cc :enhanceUrlWithTitle

" Workspace
exmap loadWorkspace jsfile Meta/vimrc-jscommands.js { workspace('load', 'Basic') }
nnoremap ,w :loadWorkspace
exmap saveWorkspace jsfile Meta/vimrc-jscommands.js { workspace('save', 'Basic') }
nnoremap ,W :saveWorkspace

" Freeze Interface
exmap freezeInterface jsfile Meta/vimrc-jscommands.js { freezeInterface() }
nnoremap ,F :freezeInterface

"───────────────────────────────────────────────────────────────────────────────
" OBSIDIAN-SPECIFIC LEADER BINDINGS

" Critic Markup: accept all
exmap acceptAll obcommand commentator:commentator-accept-all-suggestions
nnoremap ,a :acceptAll

" Critic Markup: reject all
exmap rejectAll obcommand commentator:commentator-reject-all-suggestions
nnoremap ,A :rejectAll

" Add [y]aml property
exmap addProperty obcommand markdown:add-metadata-property
nnoremap ,y :addProperty

" set "[r]ead: true" property
exmap addYamlKey jsfile Meta/vimrc-jscommands.js { addYamlKey("read", true) }
nnoremap ,r :addYamlKey

" [i]nspect [w]ord count
exmap inspectWordCount jsfile Meta/vimrc-jscommands.js { inspectWordCount() }
nnoremap ,iw :inspectWordCount

" [i]nspect chrome [v]ersion
exmap inspectChromeVersion jscommand { new Notice ('Chrome version: ' + process.versions.chrome.split('.')[0], 4000) }
nnoremap ,iv :inspectChromeVersion

"───────────────────────────────────────────────────────────────────────────────
" PLUGIN- AND SETTING-RELATED BINDINGS

exmap updatePlugins jsfile Meta/vimrc-jscommands.js { updatePlugins() }
nnoremap ,pp :updatePlugins

" open [p]lugin [d]irectory
exmap openPluginDir jscommand { view.app.openWithDefaultApp(view.app.vault.configDir + '/plugins'); }
nnoremap ,pd :openPluginDir

" open [s]nippet directory
exmap openSnippetDir jscommand { view.app.openWithDefaultApp(view.app.vault.configDir + '/snippets'); }
nnoremap ,ps :openSnippetDir

" [i] install [p]lugins
exmap installPlugins jscommand { view.app.workspace.protocolHandlers.get("show-plugin")({ id: ' ' }); }
nnoremap ,pi :installPlugins

" open trash
exmap openTrash jscommand { view.app.openWithDefaultApp("/.trash"); }
nnoremap ,t :openTrash

" dynamic [h]ighlights settings
exmap openDynamicHighlightsSettings jsfile Meta/vimrc-jscommands.js { openDynamicHighlightsSettings() }
nnoremap ,ph :openDynamicHighlightsSettings

" Cycle Themes
exmap cycleThemes jsfile Meta/vimrc-jscommands.js { cycleThemes() }
nnoremap ,pc :cycleThemes

" Open this vimrc file
exmap openVimrc jscommand { view.app.openWithDefaultApp("Meta/obsidian-vimrc.vim"); }
nnoremap <C-,> :openVimrc

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

exmap duplicate obcommand obsidian-editor-shortcuts:duplicateLine
nnoremap ww :duplicate

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

exmap toggleLineNumbers jsfile Meta/vimrc-jscommands.js { toggleLineNumbers() }
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

" insert mode: accept suggestion
" normal mode: format
" HACK `<C-ü>` remapped to cmd-s via Karabiner, since cmd-s (<M-s>) does not
" trigger reliably in normal mode.
" INFO not mapping via Obsidian hotkeys, so we have have the distinction between
" normal and insert mode, like in nvim
exmap acceptGhostText obcommand copilot-auto-completion:accept
inoremap <C-ü> :acceptGhostText

exmap lint obcommand obsidian-linter:lint-file
nnoremap <C-ü> :lint
