let g:airline_theme='tomorrow'
syntax on

set ignorecase
set smartcase

set spelllang=en
nnoremap s :setlocal spell!<cr>

inoremap jj <Esc>

" Use Esc to exit terminal mode
tnoremap <Esc> <C-\><C-n>

" Comment out a line
nnoremap #  I#<Esc><C-0><Down>
nnoremap // I//<Esc><C-0><Down>

" Autocomplete braces/parenthesis/quotation marks/brackets
inoremap { {}<Left>
inoremap ( ()<Left>
inoremap " ""<Left>
inoremap [ []<Left>

" Copy unnamed register into Wayland clipboard
nnoremap w :call system('wl-copy', @")<cr>

" Different cursor shapes in different modes
let &t_SI = "\<Esc>[4 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"
