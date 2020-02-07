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

nnoremap <leader>s :setlocal spell!<cr>

nnoremap q: <nop>
nnoremap Q  <nop>

set ttimeoutlen=0 showcmd


"- WAYLAND -"

" Writes the contents of @w into the clipboard when @w is updated
if len($WAYLAND_DISPLAY) > 0
	augroup writeclip
		au!
		au TextYankPost * if v:event.regname == "w" | call system('wl-copy', @w)
	augroup END
endif


"- INDENTATION -"

filetype plugin indent on
set autoindent
set tabstop=4 shiftwidth=0


"- SEARCH -"

set ignorecase smartcase
set incsearch
if executable("rg")
	set grepprg=rg\ --vimgrep
endif


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


"- LINTING -"

autocmd FileType python compiler pylint
autocmd FileType sh setlocal makeprg=shellcheck
autocmd FileType bash setlocal makeprg=shellcheck
autocmd FileType c setlocal makeprg=splint
nnoremap <leader>m :make %<cr>
nnoremap <leader>c :cwindow<cr>


"- FORMATTING -"

" Highlight trailing whitespace only in normal mode (it's pretty distracting
" when highlighted in insert mode)
highlight TrailingWhitespace ctermbg=red
match TrailingWhitespace /\s\+$/
autocmd InsertLeave,WinEnter * highlight TrailingWhitespace ctermbg=red
autocmd InsertEnter * highlight clear TrailingWhitespace

" Remove trailing whitespace
nnoremap <leader>w :%s/\s\+$//e<cr>

" Set default formatoptions
set formatoptions+=aown

" Fix broken format options for certain filetypes
autocmd FileType sh setl tw=72 fo-=t
autocmd FileType python setl tw=79 fo-=t
autocmd FileType markdown setl fo-=t
autocmd FileType crontab setl fo-=t

" Fallback for naughty files
function ToggleFormatting()
	if stridx(&fo, "t") >= 0
		setl fo-=t
	else
		setl fo+=t
	endif
endfunc
nnoremap <leader>f :call ToggleFormatting()<cr>


"- MAIL -"

" Opens mutt in a terminal window while I write emails
function OpenMail()
	call term_start("mutt", {"term_finish": "close"})
	call feedkeys("\<C-w>p")
endfunc
autocmd FileType mail call OpenMail()


"- MISCELLANEOUS -"

" Show the diff between the buffer and the original file
nnoremap <leader>d :w !diff % -<cr>

packloadall
silent! helptags ALL
