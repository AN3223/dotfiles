let g:airline_theme='tomorrow'
syntax on

set ignorecase
set smartcase

set spelllang=en
nnoremap s :setlocal spell!<cr>

" Use Esc to exit terminal mode
tnoremap <Esc> <C-\><C-n>

inoremap jj <Esc>

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
