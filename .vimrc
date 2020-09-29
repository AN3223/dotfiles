"- AESTHETIC -"

set relativenumber number bg=dark

" Different cursor shapes in different modes
let &t_SI = "\<Esc>[4 q" | let &t_SR = &t_SI
let &t_EI = "\<Esc>[2 q"


"- ESSENTIALS -"

let mapleader = ","
tnoremap <Esc> <C-\><C-n>
nnoremap s :setlocal spell!<cr>
nnoremap q: <nop>
nnoremap J gt
nnoremap K gT

set encoding=utf-8 ttimeoutlen=0


"- WAYLAND -"

" Writes the contents of @w into the clipboard when @w is updated
if len($WAYLAND_DISPLAY) > 0
	au TextYankPost * if v:event.regname == "w" | call system('wl-copy', @w)
endif


"- SEARCH -"

set ignorecase smartcase incsearch
if executable("rg")
	set grepprg=rg\ --vimgrep
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
inoremap <C-k> <C-o>c$


"- LINTING -"

autocmd FileType python compiler pylint
autocmd FileType sh,bash setl makeprg=shellcheck
autocmd FileType c setl makeprg=splint
nnoremap <leader>m :make %<cr>


"- FORMATTING -"

filetype plugin indent on
set autoindent tabstop=4 shiftwidth=0

" Strip trailing whitespace on write
autocmd BufWritePre * %s/\s\+$//e

set formatoptions+=aown
autocmd FileType sh,python,markdown,crontab,scheme setl fo-=t
autocmd FileType sh setl textwidth=72
autocmd FileType python setl textwidth=79
autocmd FileType json setl expandtab tabstop=2


"- MISC -"

" Help with performance
set lazyredraw nottyfast

" Show diff between the buffer and the original file
nnoremap <leader>d :w !diff % -<cr>

" Open a read-only mutt instance in a terminal window, and close it whenever
" the email is closed
autocmd FileType mail
	\ call term_start("mutt -R", {"term_finish": "close", "term_name": "mutt"})
	\ | call feedkeys("\<C-w>p")
	\ | au QuitPre /tmp/mutt-* ++once bdelete! mutt

syntax enable
packadd! matchit
silent! helptags ALL

