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

nnoremap q: <nop>
nnoremap Q  <nop>

set ttimeoutlen=0 showcmd

"- WAYLAND -"

" Bidirectional sync @w with the Wayland clipboard
if len($WAYLAND_DISPLAY) > 0
	augroup writeclip
		au!
		au TextYankPost * if v:event.regname == "w" | call system('wl-copy', @w)
	augroup END

	" FIXME this should probably strip trailing newlines and ignore empty
	" strings
	func! ReadClip(channel, msg)
		noautocmd let @w = a:msg
	endfunc

	call job_start('wl-paste --watch cat', {"out_cb": "ReadClip"})

	" Hack to flush the pipe's buffer if the clipboard doesn't end with a
	" newline, since wl-paste --watch doesn't seem to have an option to always
	" print newlines after the clipboard contents
	nnoremap <leader>wnl :call system('wl-copy', "\n")<cr>
endif


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
autocmd FileType c setlocal makeprg=splint
nnoremap <leader>m :make %<cr>
nnoremap <leader>c :cwindow<cr>


"- FORMATTING -"

" Strip trailing whitespace
autocmd BufWritePre * %s/\s\+$//e

autocmd FileType sh setlocal textwidth=72 formatoptions-=t
autocmd FileType python setlocal textwidth=79 formatoptions-=t
set formatoptions+=aown


"- MISCELLANEOUS -"

nnoremap <leader>e :vsplit $MYVIMRC<cr>
nnoremap <leader>s :source $MYVIMRC<cr>

" Show the diff between the buffer and the original file
nnoremap <leader>d :w !diff % -<cr>

packloadall
silent! helptags ALL
