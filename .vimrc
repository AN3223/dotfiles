let g:airline_theme='serene'
syntax on

set ignorecase
set smartcase

set spelllang=en
nmap s :setlocal spell!<CR>

" Use Esc to exit terminal mode
tnoremap <Esc> <C-\><C-n>

imap jj <Esc>

" Comment out a line
nmap #  I#<Esc><C-0><Down>
nmap // I//<Esc><C-0><Down>

" Autocomplete braces/parenthesis/quotation marks/brackets
inoremap { {}<Left>
inoremap ( ()<Left>
inoremap " ""<Left>
inoremap [ []<Left>

