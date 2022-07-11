" Closing Tabs
map wq closeTabsOnLeft
map we closeTabsOnRight
map w2 moveTabToNewWindow
map ww closeOtherTabs
map u removeTab
map U restoreTab
" W = close window
map W removeTab count=19

" Scrolling Fast
map J scrollDown count=3
map K scrollUp count=3
map gl scrollRight
map gh scrollLeft

" History
map h goBack
map l goForward

" Reload
map R reload hard

" Pages (not history)
map H goPrevious
map L goNext

" Tabs
map t Vomnibar.activateTabSelection
map b previousTab
map e nextTab
map < moveTabLeft
map > moveTabRight
map 0 firstTab
map $ lastTab

" Link Mode
map <c-f> LinkHints.activateModeWithQueue

" mimic American keyboard layout
map - enterFindMode

" Global Marks
" https://github.com/philc/vimium/wiki/Tips-and-Tricks#swapping-global-and-local-marks
map ä Marks.activateGotoMode swap
map m Marks.activateCreateMode swap

" Misc
map M toggleMuteTab
map a passNextKey

" unmap unneeded stuff
unmap d
unmap B
unmap T
unmap o
unmap O
unmap `
unmap <c-e>
unmap <c-y>
unmap /
unmap ^
unmap >>
unmap <<
unmap <a-m>
unmap <a-p>
unmap X
unmap g0
unmap g$
unmap gE
unmap [[
unmap ]]
unmap <a-f>
