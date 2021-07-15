"- AESTHETIC -"

set number bg=dark

" Different cursor shapes in different modes
let &t_SI = "\<Esc>[4 q" | let &t_SR = &t_SI
let &t_EI = "\<Esc>[2 q"

"- ESSENTIALS -"

let mapleader = ","
nnoremap s :setlocal spell!<cr>
nnoremap q: <nop>
nnoremap J gt
nnoremap K gT

set encoding=utf-8 ttimeoutlen=0
set ignorecase smartcase

" Save cursor positions for up to ten files and restore them on file load
set viminfo='10,<0,h,f1
au BufReadPost * if line("'\"") && line("'\"") <= line("$") && &ft !~# 'commit'
	\ | exe "normal! g`\""
	\ | endif

"- WAYLAND -"

" Writes the contents of @w into the clipboard when @w is updated
if len($WAYLAND_DISPLAY) > 0
	au TextYankPost * if v:event.regname == "w" | call system('wl-copy', @w)
endif

"- READLINE -"

inoremap <C-a> <Home>
cnoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Delete>
cnoremap <C-d> <Delete>
inoremap <C-f> <Right>
cnoremap <C-f> <Right>
inoremap <C-b> <Left>
cnoremap <C-b> <Left>
inoremap <C-k> <C-\><C-N><Right>c$
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

"- FORMATTING -"

filetype plugin indent on
set autoindent tabstop=2 shiftwidth=0

" Strip trailing whitespace on write
autocmd BufWritePre * %s/\s\+$//e

" Fix annoying highlighting around $() in shell code
let g:is_posix = 1

set hlsearch

set formatoptions+=own
autocmd FileType sh,python,markdown,crontab,scheme setl fo-=t
autocmd FileType sh setl textwidth=72
autocmd FileType python setl textwidth=79
autocmd FileType json setl expandtab

"- MISC -"

" Help with performance
set lazyredraw nottyfast

" Show diff between the buffer and the file on disk
nnoremap <leader>d :w !diff % -<cr>

set modeline
syntax enable
packadd! matchit
silent! helptags ALL

