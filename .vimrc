set nocompatible


"- AESTHETIC -"

set encoding=utf-8
syntax enable
set number

" Different cursor shapes in different modes
let &t_SI = "\<Esc>[4 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"


"- BASIC FUNCTIONALITY -"

inoremap jj <Esc>
let mapleader = ","

" Escape terminal mode
tnoremap <Esc> <C-\><C-n>

" Spellcheck
set spelllang=en
nnoremap s :setlocal spell!<cr>

" Comment out a line
nnoremap #  I#<Esc><Down><C-0>
nnoremap // I//<Esc><Down><C-0>

" Copy " register into Wayland clipboard
nnoremap <leader>w :call system('wl-copy', @")<cr>

" Disable annoying things
nnoremap q: <nop>
nnoremap Q  <nop>

" Only lint on save
let g:ale_lint_on_text_changed = "never"

set shiftwidth=4


"- SEARCH -"

set ignorecase | set smartcase
set incsearch
set grepprg=rg\ --vimgrep


"- AUTOCLOSE -"

" Automatically close braces/parenthesis/etc

inoremap { {}<Left>
inoremap ( ()<Left>
inoremap [ []<Left>

" These are easy to type, but sometimes problematic,
" so I just save the trip to the arrow keys.
inoremap "" ""<Left>
inoremap '' ''<Left>

vnoremap <leader>{ c{}<Left><Esc>p
vnoremap <leader>( c()<Left><Esc>p
vnoremap <leader>" c""<Left><Esc>p
vnoremap <leader>[ c[]<Left><Esc>p
vnoremap <leader>' c''<Left><Esc>p
vnoremap <leader>< c<><Left><Esc>p


"- WINDOWS -"

" Shortcuts for switching between windows
nnoremap H <C-w>h
nnoremap J <C-w>j
nnoremap K <C-w>k
nnoremap L <C-w>l

" Shortcuts for moving windows
nnoremap <C-H> <C-w>H
nnoremap <C-J> <C-w>J
nnoremap <C-K> <C-w>K
nnoremap <C-L> <C-w>L


"- MISCELLANEOUS -"

" Commands for quickly editing this file
nnoremap <leader>e :vsplit $MYVIMRC<cr>
nnoremap <leader>s :source $MYVIMRC<cr>

