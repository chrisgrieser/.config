" cmd+s to save
nnoremap <D-s> :write<CR>
" cmd+a to save all
nnoremap <D-a> ggvG
" cmd+w to save&quit
nnoremap <D-w> ZZ
" cmd+d to duplicate
nnoremap <D-d> yyp
" Swap up/down (vim.unimpaired)
noremap <D-2> [e
noremap <D-3> ]e

" alt+right/left work like in macOS. Needed to make some macros work in Normal Mode
nnoremap <M-Right> e
nnoremap <M-Left> b

" Goto Mark
nnoremap ä `

" CASE SWITCH (added h for vertical navigation)
nnoremap Ü ~h
" Switch Case of first letter of the word = (toggle between Capital and lower case)
nnoremap ü mzlblgueh~`z

" TRANSPOSE
" current & next char
nnoremap ö xp
" current & previous char
nnoremap Ö xhhp
" current & next word
nnoremap Ä dawelpb

" Append punctuation to end of line
nnoremap <leader>, mzA,<Esc>`z
nnoremap <leader>; mzA;<Esc>`z
nnoremap <leader>. mzA.<Esc>`z
nnoremap <leader>" mzA"<Esc>`z
nnoremap <leader>' mzA'<Esc>`z
nnoremap <leader>: mzA:<Esc>`z
nnoremap <leader>) mzA)<Esc>`z
nnoremap <leader>( mzA(<Esc>`z
nnoremap <leader>] mzA]<Esc>`z
nnoremap <leader>[ mzA[<Esc>`z
nnoremap <leader>{ mzA{<Esc>`z
nnoremap <leader>} mzA}<Esc>`z
nnoremap <leader>} mzA}<Esc>`z

