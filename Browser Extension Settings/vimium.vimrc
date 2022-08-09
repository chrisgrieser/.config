unmapAll

" Tabs
map wq closeTabsOnLeft
map we closeTabsOnRight
map wv moveTabToNewWindow
map W closeOtherTabs
map u removeTab
map x removeTab
map z restoreTab
map ww removeTab count=19
map b previousTab
map e nextTab
map gT previousTab
map gt nextTab
map t Vomnibar.activateTabSelection
map < moveTabLeft
map > moveTabRight
map 1 firstTab
map 9 lastTab
map gn createTab https://news.google.com/home?hl=de&gl=DE&ceid=DE:de
map wn createTab window
map yt duplicateTab

" Scrolling
map j scrollDown
map k scrollUp
map J scrollDown count=3
map K scrollUp count=3
map gl scrollRight
map gh scrollLeft
map gg scrollToTop
map G scrollToBottom

" History
map h goBack
map l goForward

" Pages (not history)
map H goPrevious
map L goNext

" url
map ge Vomnibar.activateEditUrl
map gu goUp
map gU goToRoot
map gi focusInput
map gs toggleViewSource
map yy copyCurrentUrl
map p openCopiedUrlInCurrentTab
map P openCopiedUrlInNewTab
map M toggleMuteTab
map a passNextKey
map gf nextFrame

" Modes
map i enterInsertMode
map v enterVisualMode
map V enterVisualLineMode

" Reload
map r reload
map R reload hard

" Link Mode
map f LinkHints.activateMode
map F LinkHints.activateModeToOpenInNewTab
map <c-f> LinkHints.activateModeWithQueue
map sf LinkHints.activateModeToDownloadLink
map yf LinkHints.activateModeToCopyLinkUrl

" Find
map - enterFindMode
map n performFind
map N performBackwardsFind

" Global Marks
" https://github.com/philc/vimium/wiki/Tips-and-Tricks#swapping-global-and-local-marks
map ä Marks.activateGotoMode swap
map m Marks.activateCreateMode swap

"Misc
map ? showHelp
