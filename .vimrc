let g:airline_theme = 'tomorrow'
syntax enable
set number

" Different cursor shapes in different modes
let &t_SI = "\<Esc>[4 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

set ttimeout
set ttimeoutlen=40

set ignorecase | set smartcase

set spelllang=en
nnoremap s :setlocal spell!<cr>

inoremap jj <Esc>

" Comment out a line
nnoremap #  I#<Esc><C-0><Down>
nnoremap // I//<Esc><C-0><Down>

" Autocomplete braces/parenthesis/quotation marks/brackets
inoremap { {}<Left>
inoremap ( ()<Left>
inoremap " ""<Left>
inoremap [ []<Left>

let mapleader = ","

" Commands for quickly editing this file
nnoremap <leader>e :vsplit $MYVIMRC<cr>
nnoremap <leader>s :source $MYVIMRC<cr>

" Copy unnamed register into Wayland clipboard
nnoremap <leader>w :call system('wl-copy', @")<cr>

nnoremap <leader>8 :set encoding=utf-8<cr>

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

