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
let &t_SR = "\e[4 q"
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
" Clipboard
""""""""""""""""""""""

" yank to system clipboard
set clipboard=unnamed

" show register (i.e., clipboard history)
nnoremap <C-y> :reg<CR>

" Y consistent with D and C to the end of line
nnoremap Y y$

" always paste what was yanked (y), not what was deleted (d or c)
" (gets syntax highlighting of comments, but does work though)
nnoremap P "0p

""""""""""""""""""""""
" Search
""""""""""""""""""""""
" no modifier key for jumping to next word
nnoremap + *

" quicker find mode (by mirroring American keyboard layout on German keyboard layout)
nnoremap - /

" Quickly remove search highlights
nnoremap <C-m> :nohlsearch<CR>

""""""""""""""""""""""
" Editing
""""""""""""""""""""""

" backspace works in normal mode like in insert mode & consistent with <del>
nnoremap <BS> X
vnoremap <BS> xh

" allows Double Enter to add new line and indent
nnoremap <CR> A

" More logical undo
nnoremap U <C-r>

" quicker way to change word
nnoremap <Space> ciw
nnoremap <S-Space> daw
vnoremap <Space> c

""""""""""""""""""""""
" Insert Mode
""""""""""""""""""""""

" Kill line
inoremap <C-k> <Esc>C


""""""""""""""""""""""
" Misc
""""""""""""""""""""""
" quicker access to help command-ids
nnoremap ? :help
