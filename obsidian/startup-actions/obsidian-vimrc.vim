"───────────────────────────────────────────────────────────────────────────────
" LEADER

" Can't set leaders in Obsidian vim, so the key just has to be used consistently.
" However, it needs to be unmapped, to not trigger default behavior:
" https://github.com/esm7/obsidian-vimrc-support#some-help-with-binding-space-chords-doom-and-spacemacs-fans
unmap ,

"───────────────────────────────────────────────────────────────────────────────
" META

" Open this vimrc
exmap pluginSettings obcommand pseudometa-startup-actions:open-plugin-settings
nnoremap g, :pluginSettings<CR>

" copy command ids to devtools
exmap openDevTools jscommand { electronWindow.openDevTools() }
nnoremap ? :obcommand<CR>:openDevTools<CR>

"───────────────────────────────────────────────────────────────────────────────
" CLIPBOARD

" yank to system clipboard
set clipboard=unnamed

" Y consistent with D and C to the end of line
nnoremap Y y$

" don't pollute the register (HACK since we can't map to `"_x` or `"_C` directly)
nnoremap C "_c$
nnoremap x "_dl
" nnoremap c "_c " not working with vimrc plugin

" don't override register
vnoremap p P

" paste at EoL
nnoremap P mzA<Space><Esc>p`z

" paste url into selection/cword
" macOS: as opposed to nvim, cmd-key mappings are <M-*>, not <D-*>
noremap <M-k> :pasteinto<CR>

"───────────────────────────────────────────────────────────────────────────────

" Copy Path segments
exmap copyAbsolutePath jsfile Meta/vimrc-jsfile.js { copyPathSegment("absolute") }
exmap copyRelativePath jsfile Meta/vimrc-jsfile.js { copyPathSegment("relative") }
exmap copyFilename jsfile Meta/vimrc-jsfile.js { copyPathSegment("filename") }
exmap copyObsidianUriMdLink jsfile Meta/vimrc-jsfile.js { copyObsidianUriMdLink() }

noremap <C-p> :copyAbsolutePath<CR>
inoremap <C-p> :copyAbsolutePath<CR>
noremap <C-t> :copyRelativePath<CR>
inoremap <C-t> :copyRelativePath<CR>
noremap <C-n> :copyFilename<CR>
inoremap <C-n> :copyFilename<CR>
noremap <C-o> :copyObsidianUriMdLink<CR>
inoremap <C-o> :copyObsidianUriMdLink<CR>

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
noremap ge :nextSuggestion<CR>

exmap prevSuggestion obcommand obsidian-languagetool-plugin:ltjump-to-previous-suggestion
noremap gE :prevSuggestion<CR>

exmap acceptSuggestion obcommand obsidian-languagetool-plugin:ltaccept-suggestion-1
noremap ga :acceptSuggestion<CR>

" next/prev heading 
" (ignoring H1 in pattern since they could also be comments in code blocks, and
" are not only used at the top of the document, where you can get to via `gg`.)
exmap gotoNextHeading jsfile Meta/vimrc-jsfile.js { gotoLineWithPattern("next", /^##+ .*/) }
nnoremap <C-j> :gotoNextHeading<CR>
exmap gotoPrevHeading jsfile Meta/vimrc-jsfile.js { gotoLineWithPattern("prev", /^##+ .*/) }
nnoremap <C-k> :gotoPrevHeading<CR>

" [m]atch parenthesis, useful to go to next pandoc citations
nnoremap m %

" [g]oto [s]ymbol (using Another Quick Switcher)
exmap gotoHeading obcommand obsidian-another-quick-switcher:header-floating-search-in-file
nnoremap gs :gotoHeading<CR>

" like vim's gx (if not standing on link, seek forward)
exmap openNextLink jsfile Meta/vimrc-jsfile.js { openNextLink("current-tab") }
nnoremap gx :openNextLink<CR>

exmap openNextLinkInNewTab jsfile Meta/vimrc-jsfile.js { openNextLink("new-tab") }
nnoremap gX :openNextLinkInNewTab<CR>

" [g]oto [f]ootnotes
" requires Footnotes Shortcut Plugin
exmap gotoFootnote obcommand obsidian-footnotes:insert-autonumbered-footnote
nnoremap gf :gotoFootnote<CR>

" go to last change (HACK, only works once to jump to the last location)
nnoremap g; u<C-r>

"───────────────────────────────────────────────────────────────────────────────

" go to last link in file
exmap gotoLastLinkInFile jsfile Meta/vimrc-jsfile.js { gotoLastLinkInFile() }
nnoremap g. :gotoLastLinkInFile<CR>

" go to next/prev paragraph with link in file
exmap gotoNextLinkInFile jsfile Meta/vimrc-jsfile.js { gotoLineWithPattern("next", /\[\[/) }
nnoremap gj :gotoNextLinkInFile<CR>
exmap gotoPrevLinkInFile jsfile Meta/vimrc-jsfile.js { gotoLineWithPattern("prev", /\[\[/) }
nnoremap gk :gotoPrevLinkInFile<CR>

"───────────────────────────────────────────────────────────────────────────────
" FILE-, TAB- AND WINDOW-NAVIGATION

" [g]oto [o]pen file (= Quick Switcher)
exmap quickSwitcher obcommand obsidian-another-quick-switcher:search-command_main-search
noremap go :quickSwitcher<CR>
noremap gr :quickSwitcher<CR>

exmap altSearch obcommand obsidian-another-quick-switcher:search-command_alt-search
noremap gO :altSearch<CR>

" :bnext/bprev
exmap goBack obcommand app:go-back
exmap goForward obcommand app:go-forward
noremap <BS> :goBack<CR>
noremap <S-BS> :goForward<CR>

" Close
exmap closeWindow obcommand workspace:close-window
nnoremap ZZ :closeWindow<CR>

" Splits
exmap splitVertical obcommand workspace:split-vertical
noremap <C-w>v :splitVertical<CR>
noremap <C-v> :splitVertical<CR>

" Tabs
exmap nextTab obcommand workspace:next-tab
exmap prevTab obcommand workspace:previous-tab
nnoremap gt :nextTab<CR>
nnoremap gT :prevTab<CR>

exmap closeOthers obcommand workspace:close-others
nnoremap <C-w>o :closeOthers<CR>

" Alt Buffer (emulates `:buffer #`)
exmap altBuffer obcommand grappling-hook:alternate-note
noremap <CR> :altBuffer<CR>

" Random File
exmap openRandomDataFile jsfile Meta/vimrc-jsfile.js { openRandomNoteIn("Data", "read", false) }
noremap <C-Tab> :openRandomDataFile<CR>

"───────────────────────────────────────────────────────────────────────────────
" SEARCH

" Find Mode (by mirroring American keyboard layout on German keyboard layout)
nnoremap - /

" <Esc> clears highlights & notices
" (HACK cannot combine excommands, therefore combining them to a mapping first)
exmap clearNotices jsfile Meta/vimrc-jsfile.js { clearNotices() }
nnoremap <Esc> :clearNotices<CR>:nohl<CR>

" Another Quick Switcher ripgrep-search (somewhat close to Telescope's livegrep)
exmap liveGrep obcommand obsidian-another-quick-switcher:grep
noremap gl :liveGrep<CR>

nnoremap ,ff :%s///g
nnoremap ,fs :%s///g

"───────────────────────────────────────────────────────────────────────────────
" EDITING

" Indentation
" <Tab> as indentation is already implemented in Obsidian

" Move lines (doesn't work in visual mode)
exmap lineUp obcommand editor:swap-line-up
exmap lineDown obcommand editor:swap-line-down
nnoremap <Up> :lineUp<CR>
nnoremap <Down> :lineDown<CR>

" Move character under cursor
nnoremap <Right> dlp
nnoremap <Left> dlhhp

" h1 -> h2, h2 -> h3, etc.
" <M-h> == cmd+h
exmap headingIncrement jsfile Meta/vimrc-jsfile.js { headingIncrementor(1) }
nnoremap <M-h> :headingIncrement<CR>
inoremap <M-h> :headingIncrement<CR>
exmap headingDecrement jsfile Meta/vimrc-jsfile.js { headingIncrementor(-1) }
nnoremap <M-S-h> :headingDecrement<CR>
inoremap <M-S-h> :headingIncrement<CR>

" Move words (equivalent to sibling-swap.nvim)
" nnoremap ä "zdawel"zph
" nnoremap Ä "zdawbh"zph
" above is for single words, below does not trip on ', etc.
nnoremap ä "zdawB"zPB
nnoremap Ä "zdawEl"zpB

" spelling suggestions (emulates `z=`)
exmap contextMenu obcommand editor:context-menu
noremap zl :contextMenu<CR>

" undo/redo consistently on one key
nnoremap U <C-r>

" redo all
nnoremap ,ur 1000<C-r>

" toggle lowercase/Titlecase
exmap toggleLowercaseTitleCase jsfile Meta/vimrc-jsfile.js { toggleLowercaseTitleCase() }
nnoremap < :toggleLowercaseTitleCase<CR>

" do not move to the right on toggling case
nnoremap ~ v~

" Change word/selection
nnoremap <Space> "_ciw
vnoremap <Space> "_c
onoremap <Space> iw
nnoremap <S-Space> "_daw

" [M]erge lines (removing list or blockquote)
exmap smartMerge jsfile Meta/vimrc-jsfile.js { smartMerge() }
nnoremap M :smartMerge<CR>

" [s]plit line
nnoremap ,s i<CR><CR><Esc>

" o and O (respecting list or blockquote)
exmap openBelow jsfile Meta/vimrc-jsfile.js { smartOpenLine("below") }
nnoremap o :openBelow<CR>
exmap openAbove jsfile Meta/vimrc-jsfile.js { smartOpenLine("above") }
nnoremap O :openAbove<CR>

" Add blank line above/below
nnoremap = mzO<Esc>`z
nnoremap _ mzo<Esc>`z

" Increment/decrement
nnoremap + <C-a>
nnoremap ü <C-x>

" JS Comments
nunmap q
exmap toggleJsLineComment jsfile Meta/vimrc-jsfile.js { toggleJsLineComment() }
nnoremap qq :toggleJsLineComment<CR>
exmap appendJsComment jsfile Meta/vimrc-jsfile.js { appendJsComment() }
nnoremap Q :appendJsComment<CR>

" markdown tasks
exmap checkList obcommand editor:toggle-checklist-status
nnoremap ,x :checkList<CR>

" blockquote
exmap toggleBlockquote obcommand editor:toggle-blockquote
nnoremap ,< :toggleBlockquote<CR>

exmap insertHr jscommand { editor.replaceSelection("\n---\n"); }
nnoremap qw :insertHr<CR>

"───────────────────────────────────────────────────────────────────────────────
" LEADER MAPPINGS

" [L]og Variable
exmap consoleLogFromWordUnderCursor jsfile Meta/vimrc-jsfile.js { consoleLogFromWordUnderCursor() }
nnoremap ,ll :consoleLogFromWordUnderCursor<CR>

" Enhance URL with title (same hotkey as [c]ode action in nvim)
exmap enhanceUrlWithTitle obcommand obsidian-auto-link-title:enhance-url-with-title
nnoremap ,cc :enhanceUrlWithTitle<CR>

" Freeze Interface
exmap freezeInterface jsfile Meta/vimrc-jsfile.js { freezeInterface() }
nnoremap ,F :freezeInterface<CR>

" Rephraser: [a]ccept/[r]eject
exmap acceptSuggestionsInLine jsfile Meta/vimrc-jsfile.js { highlightsAndStrikthrus("accept") }
nnoremap ,a :acceptSuggestionsInLine
exmap rejectSuggestionsInLine jsfile Meta/vimrc-jsfile.js { highlightsAndStrikthrus("reject") }
nnoremap ,r :rejectSuggestionsInLine<CR>

" set "[r]ead: true" property
exmap addYamlKey jsfile Meta/vimrc-jsfile.js { addYamlKey("read", true) }
nnoremap ,r :addYamlKey<CR>

" [i]nspect [w]ord count
exmap inspectWordCount jsfile Meta/vimrc-jsfile.js { inspectWordCount() }
nnoremap ,iw :inspectWordCount<CR>

" [i]nspect chrome [v]ersion
exmap inspectChromeVersion jscommand { new Notice ('Chrome version: ' + process.versions.chrome.split('.')[0], 4000) }
nnoremap ,iv :inspectChromeVersion<CR>

"───────────────────────────────────────────────────────────────────────────────
" META: PLUGIN- AND SETTING-RELATED BINDINGS

exmap updatePlugins jsfile Meta/vimrc-jsfile.js { updatePlugins() }
nnoremap ,pp :updatePlugins<CR>

" open [p]lugin [d]irectory
exmap openPluginDir jscommand { view.app.openWithDefaultApp(view.app.vault.configDir + '/plugins'); }
nnoremap ,pd :openPluginDir<CR>

" open [m]eta
exmap openMetaDir jscommand { view.app.openWithDefaultApp('/Meta'); }
nnoremap ,pm :openMetaDir<CR>

" open [s]nippet directory
exmap openSnippetDir jscommand { view.app.openWithDefaultApp(view.app.vault.configDir + '/snippets'); }
nnoremap ,ps :openSnippetDir<CR>

" open [t]heme directory
exmap openThemeDir jscommand { view.app.openWithDefaultApp(view.app.vault.configDir + '/themes'); }
nnoremap ,pt :openThemeDir<CR>

" open [a]ppearance settings
exmap openAppearanceSettings jsfile Meta/vimrc-jsfile.js { openAppearanceSettings() }
nnoremap ,pa :openAppearanceSettings<CR>

" open community plugin settings
exmap openCommunityPluginsSettings jsfile Meta/vimrc-jsfile.js { openCommunityPluginsSettings() }
nnoremap ,pl :openCommunityPluginsSettings<CR>

" [i] install [p]lugins
exmap installPlugins jscommand { view.app.workspace.protocolHandlers.get("show-plugin")({ id: ' ' }); }
nnoremap ,pi :installPlugins<CR>

" open trash
exmap openTrash jscommand { view.app.openWithDefaultApp("/.trash"); }
nnoremap ,t :openTrash<CR>

" dynamic [h]ighlights settings
exmap openDynamicHighlightsSettings jsfile Meta/vimrc-jsfile.js { openDynamicHighlightsSettings() }
nnoremap ,ph :openDynamicHighlightsSettings<CR>

" Cycle Colorscheme
exmap cycleColorscheme jsfile Meta/vimrc-jsfile.js { cycleColorscheme() }
nnoremap ,pc :cycleColorscheme<CR>

" Workspace
exmap loadWorkspace jsfile Meta/vimrc-jsfile.js { workspace("load", "Basic") }
nnoremap ,w :loadWorkspace<CR>
exmap saveWorkspace jsfile Meta/vimrc-jsfile.js { workspace("save", "Basic") }
nnoremap ,W :saveWorkspace<CR>

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
nnoremap za :togglefold<CR>
nnoremap ^ :togglefold<CR>
nnoremap zo :togglefold<CR>
nnoremap zc :togglefold<CR>

exmap unfoldall obcommand editor:unfold-all
exmap foldall obcommand editor:fold-all
nnoremap zm :foldall<CR>
nnoremap zz :foldall<CR>
nnoremap zr :unfoldall<CR>

"───────────────────────────────────────────────────────────────────────────────
" OPTION TOGGLING

" [O]ption: [s]pellcheck
exmap spellcheck obcommand editor:toggle-spellcheck
nnoremap ,os :spellcheck<CR>

" [O]ption: [n]umbers
exmap toggleLineNumbers jsfile Meta/vimrc-jsfile.js { toggleLineNumbers() }
nnoremap ,on :toggleLineNumbers<CR>

" [O]ption: [d]iagnostics
exmap enableDiagnostics obcommand obsidian-languagetool-plugin:ltcheck-text
nnoremap ,od :enableDiagnostics<CR>
exmap disableDiagnostics obcommand obsidian-languagetool-plugin:ltclear
nnoremap ,oD :disableDiagnostics<CR>

" [O]ption: [a]completion
exmap toggleAiCompletion obcommand copilot-auto-completion:toggle
nnoremap ,oa :toggleAiCompletion<CR>

"───────────────────────────────────────────────────────────────────────────────
" AI SUGGESTIONS

" <M-s> = cmd+s
" insert mode: accept suggestion
" normal mode: format
exmap acceptGhostText obcommand copilot-auto-completion:accept
inoremap <M-s> :acceptGhostText<CR>

exmap lint obcommand obsidian-linter:lint-file-unless-ignored
nnoremap <M-s> :lint<CR>