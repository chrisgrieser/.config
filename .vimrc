" https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/

" disable vi compatibility
set nocompatible

syntax on
set nowrap
set number
set relativenumber
set cursorline
set scrolloff=7

" vertical ruler
set colorcolumn=80
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/junegunn/vim-plug
" call plug#begin('~/.vim/plugged')

" Plug 'neovim/nvim-lspconfig'
" Plug 'hrsh7th/cmp-nvim-lsp'
" Plug 'Lokaltog/vim-easymotion'
" Plug 'airblade/vim-gitgutter'

" " PLUGINS TO ADD
" " unimpaired
" " surround
" " commantary
" " sneak
" " highlightedyank
" https://github.com/vim-syntastic/syntastic
" startify

" call plug#end()

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
" Swap up/down (vim.unimpaired)
noremap <D-2> [e
noremap <D-3> ]e

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

" Goto Mark: remapping since ` not working
nnoremap ö `

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
" Switch Modes
""""""""""""""""""""""

" quick switch to insert mode
inoremap jj <Esc>

" already built in: presss v in visual mode to go back
vnoremap J <Esc>

""""""""""""""""""""""
" Insert Mode
""""""""""""""""""""""

" mirroring HL in Normal Mode
inoremap <C-l> <Esc>A
inoremap <C-h> <Esc>I

" Kill line
inoremap <C-k> <Esc>C

" Kill line backwards
inoremap <C-j> <Esc>c^

""""""""""""""""""""""
" Misc
""""""""""""""""""""""
" quicker access to help command-ids
nnoremap ? :help

" copy path of current file
noremap <C-p> "%y


