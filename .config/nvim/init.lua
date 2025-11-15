--
-- AESTHETIC
--

vim.opt.scrolloff = 15
vim.opt.guicursor = 'i-r:hor20,v:blinkwait700-blinkoff400-blinkon250'
vim.opt.hlsearch = true

--
-- ESSENTIALS
--

vim.g.mapleader = ','

vim.keymap.set('n', 's', ':setlocal spell!<CR>', { noremap = true })
vim.keymap.set('n', 'q:', '<Nop>', { noremap = true })
vim.keymap.set('n', 'J', 'gt', { noremap = true })
vim.keymap.set('n', 'K', 'gT', { noremap = true })
vim.keymap.set('n', '<Space>', '<C-f>', { noremap = true })

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.dir = vim.fn.expand("~/.vimswap")

--
-- READLINE
--

vim.keymap.set('i', '<C-a>', '<Home>', { noremap = true })
vim.keymap.set('c', '<C-a>', '<Home>', { noremap = true })
vim.keymap.set('i', '<C-e>', '<End>', { noremap = true })
vim.keymap.set('i', '<C-d>', '<Delete>', { noremap = true })
vim.keymap.set('c', '<C-d>', '<Delete>', { noremap = true })
vim.keymap.set('i', '<C-f>', '<Right>', { noremap = true })
vim.keymap.set('c', '<C-f>', '<Right>', { noremap = true })
vim.keymap.set('i', '<C-b>', '<Left>', { noremap = true })
vim.keymap.set('c', '<C-b>', '<Left>', { noremap = true })
vim.keymap.set('c', '<C-p>', '<Up>', { noremap = true })
vim.keymap.set('c', '<C-n>', '<Down>', { noremap = true })

--
-- FORMATTING
--

vim.cmd("filetype plugin indent on")
vim.opt.autoindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0

vim.opt.formatoptions:append("wn")

--
-- MISC
--

-- Show diff between the buffer and the file on disk
vim.keymap.set('n', '<leader>d', ':w !diff % -<CR>', { noremap = true })

vim.opt.modeline = true
