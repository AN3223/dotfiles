"- AESTHETIC -"

set encoding=utf-8
syntax enable
set relativenumber number

set bg=dark

" Different cursor shapes in different modes
let &t_SI = "\<Esc>[4 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"


"- BASIC FUNCTIONALITY -"

let mapleader = ","

tnoremap <Esc> <C-\><C-n>

nnoremap s :setlocal spell!<cr>

" The w buffer will go into the Wayland clipboard
autocmd TextYankPost * if v:event.regname == "w" | call system('wl-copy', @w)

nnoremap q: <nop>
nnoremap Q  <nop>


"- INDENTATION -"

filetype plugin indent on
set autoindent
set tabstop=4 shiftwidth=0


"- COMMENTS -"

nnoremap #  I#<Esc>
nnoremap // I//<Esc>
nnoremap -- I--<Esc>
nnoremap /* I/* <Esc>A */<Esc>
vnoremap /* c/*<C-r>"*/<Esc>

nnoremap ;; A;<Esc>


"- SEARCH -"

set ignorecase smartcase
set incsearch
set grepprg=rg\ --vimgrep


"- AUTOCLOSE -"

vnoremap <leader>{ c{<C-r>"}<Esc>
vnoremap <leader>( c(<C-r>")<Esc>
vnoremap <leader>" c"<C-r>""<Esc>
vnoremap <leader>[ c[<C-r>"]<Esc>
vnoremap <leader>' c'<C-r>"'<Esc>
vnoremap <leader>< c<<C-r>"><Esc>


"- READLINE -"
" This isn't even close to complete but it's all that matters to me.

inoremap <C-a> <Home>
cnoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Delete>
cnoremap <C-d> <Delete>
inoremap <C-f> <Right>
cnoremap <C-f> <Right>
inoremap <C-b> <Left>
cnoremap <C-b> <Left>
inoremap <C-k> <C-o>c$
" TODO cnoremap <C-k> if possible?


"- WINDOWS -"

nnoremap H <C-w>h
nnoremap J <C-w>j
nnoremap K <C-w>k
nnoremap L <C-w>l


"- LINTING -"

autocmd FileType python compiler pylint
autocmd FileType sh setlocal makeprg=shellcheck
autocmd FileType bash setlocal makeprg=shellcheck
autocmd FileType c setlocal makeprg=gcc\ -Wall\ -std=c90\ %;splint\ %
nnoremap <leader>m :make %<cr>
nnoremap <leader>c :cwindow<cr>


"- MISCELLANEOUS -"

nnoremap <leader>e :vsplit $MYVIMRC<cr>
nnoremap <leader>s :source $MYVIMRC<cr>

packloadall
silent! helptags ALL
