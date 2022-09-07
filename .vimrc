" https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/

" disable vi compatibility
set nocompatible

syntax on
set nowrap
set number
set relativenumber
set cursorline
set scrolloff=7

" mostly used by `gq`
set textwidth=80

set tabstop=3
set softtabstop=3
set shiftwidth=3
set smartindent
set autoindent

" Gutter for LSP or linters
" set signcolumn

" show statusline containing current cursor position
set ruler " Show the mode you are on the last line.

" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2

set showmode
" show partial chord in the last line
set showcmd

" search options
set showmatch
set ignorecase
set smartcase
set incsearch
set hlsearch

" Trim Whitespace on Save
autocmd BufWritePre * %s/\s\+$//e

" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start

" By default, Vim doesn't let you hide a buffer (i.e. have a buffer that isn't
" shown in any window) that has unsaved changes. This is to prevent you from "
" forgetting about unsaved changes and then quitting e.g. via `:qa!`. We find
" hidden buffers helpful enough to disable this protection. See `:help hidden`
" for more information on this.
set hidden

" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start

" Enable mouse support.
set mouse+=a

" cursor look depending on mode
let &t_SI = "\e[5 q"
let &t_SR = "\e[3 q"
let &t_EI = "\e[0 q"
set ttimeoutlen=40	" don't wait when switching from insert to esc mode
" Ps = 0  -> blinking block
" Ps = 1  -> blinking block (default)
" Ps = 2  -> steady block
" Ps = 3  -> blinking underline
" Ps = 4  -> steady underline
" Ps = 5  -> blinking bar (xterm)
" Ps = 6  -> steady bar (xterm)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/junegunn/vim-plug
" call plug#begin('~/.vim/plugged')

" Plug 'neovim/nvim-lspconfig'
" Plug 'hrsh7th/cmp-nvim-lsp'

" " PLUGINS TO ADD
" " unimpaired
" " surround
" " commantary
" " sneak
" " highlightedyank
" https://github.com/neoclide/coc.nvim
" https://github.com/svermeulen/vim-subversive
" https://github.com/svermeulen/vim-cutlass
" https://github.com/tkhren/vim-textobj-numeral
" startify

" call plug#end()

" use fzf in vim
set rtp+=/opt/homebrew/opt/fzf

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""
" Basics
""""""""""""""""""""""

let mapleader=","

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

""""""""""""""""""""""
" Base Config
""""""""""""""""""""""

" yank to system clipboard
set clipboard=unnamed
set ignorecase
set smartcase
set incsearch
set hlsearch

" no modfier key for jumping to next word
noremap + *

" quicker find mode (by mirroring American keyboard layout on German keyboard layout)
noremap - /

nnoremap Y y$

" Have j and k navigate visual lines rather than logical ones
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

" HJKL behaves like hjkl, but bigger distance (best used with scroll offset plugin)
" h 0^ ensures scrolling to the left (when there is no wrapping)
nnoremap H 0^
vnoremap H ^
noremap L $
noremap J 7j
noremap K 7k

" cause easier to press, lol
noremap [ {
noremap ] }

" Goto Mark
nnoremap ä `

" Consistent with Insert Mode Selection
vnoremap <BS> "_d

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

" [M]erge lines
nnoremap M J

" Add Blank Line above/below
nnoremap = mzO<Esc>`z
nnoremap _ mzo<Esc>`z
" these require cursor being on the right end of the selection though...
vnoremap = <Esc>O<Esc>gv
vnoremap _ <Esc>o<Esc>gv

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

" append space
nnoremap ! a <Esc>hh

" Remove last character from line
nnoremap X mz$"_x`z

" Make indention work like in other editors
nnoremap <Tab> >>
nnoremap <S-Tab> <<
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" Change Word/Selection
nnoremap <Space> "_ciw
nmap <Space> ciw
vnoremap <Space> "_c

" Delete Word/Selection
nnoremap <S-Space> "_daw
vnoremap <S-Space> "_d

" [R]eplace Word with register content
nnoremap R viw"0p
vnoremap R "0P
