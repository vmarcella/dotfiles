vim.opt.colorcolumn = "80"
vim.g.copilot_assume_mapped = true

vim.keymap.set('i', '<M-j>', '<Plug>(copilot-next)')
vim.keymap.set('i', '<M-k>', '<Plug>(copilot-previous)')

vim.cmd([[
" ------------------------------------ PLUGINS ---------------------------------

" call plug#begin('~/.vim/plugged')

" Plug 'scrooloose/nerdtree'                      " File explorer.
" Plug 'vim-airline/vim-airline'                  " Powerline with buffers.
" Plug 'jlanzarotta/bufexplorer'                  " Buffer explorer.
" Plug 'airblade/vim-gitgutter'                   " Shows git diffs in 'gutter'.
" Plug 'ryanoasis/vim-devicons'                   " Icon pack.
" Plug 'RRethy/vm-illuminate'                    " Highlight under the cursor.
" Plug 'lilydjwg/colorizer'                       " Colorize hex color codes.
" Plug 'tmux-plugins/vim-tmux-focus-events'       " Grant tmux access to events.
" Plug 'tpope/vim-obsession'                      " Persist state of vim.
" Plug 'tikhomirov/vim-glsl'                      " GLSL syntax shading for vim.
" Plug 'github/copilot.vim'                       " Copilot for vim.

" nvim specific plugins:V

" Plug 'neoclide/coc.nvim', {'branch':'release'}  
" Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Plug 'nvim-lua/plenary.nvim'
" Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

" --- DISABLED ---
"
" Fuzzy file finder.
" Plug 'ctrlpvim/ctrlp.vim' 

" call plug#end() " Init all plugins

" ----------------------------------- LUA --------------------------------------

" ------------------------------------ AIRLINE ---------------------------------

" Add powerline to vim shell
" let g:airline_powerline_fonts = 1

" Enable tab lines
" let g:airline#extensions#tabline#enabled = 1

" enable rainbow plugin at startup
" let g:rainbow_active = 1



" ------------------------------------ RIPGREP ---------------------------------

" if executable('rg')
"    set grepprg=rg\ --color=never
"    let g:ctrlp_user_command = 'rg %s --files --hidden --color=never --glob ""'
"    let g:ctrlp_use_caching = 0
" endif

" ------------------------------- YANK FOR WINDOWS -----------------------------


let s:clip = '/mnt/c/Windows/System32/clip.exe'
if system('uname -r') =~ "microsoft" && executable(s:clip)
    augroup WSLYank
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
    augroup END
endif

" ------------------------------------ COC --------------------------------

" let g:coc_global_extensions = [
"     \ 'coc-snippets',
"    \ 'coc-pairs',
"    \ 'coc-tsserver',
"    \ 'coc-html',
"    \ 'coc-emmet',
"    \ 'coc-css',
"    \ 'coc-json',
"    \ 'coc-eslint',
"    \ 'coc-rust-analyzer',
"    \ 'coc-go',
"    \ 'coc-pyright',
"    \ 'coc-spell-checker',
"    \ 'coc-yaml',
"    \ 'coc-vetur'
"    \ ]

" -------------------------------- VIM CONFIG ----------------------------------

syntax on                        " Turn syntax highlighting on.
set nowrap                       " Don't wrap lines.
set backspace=indent,eol,start   " Backspace over anything.
set autoindent                   " Auto indent based on the current line.
set smartindent                  " Indent based upon language syntax.
set number                       " set line numbers.
set tabstop=2 shiftwidth=2       " Tabbing is always 2 spaces (hard tabs)
set expandtab                    " Insert tabs at the start of the line.
set showmatch                    " Show matching parantheses.
set visualbell                   " Don't beep
set noerrorbells                 " Plz don't beep
set hidden                       " Allow hidden buffers to exist.
set backup                       " Setup backup.
set backupdir=$HOME/.vim/backup/ " Where to save backup files. 
set dir=$HOME/.vim/swap/         " Swap file home location.
set autoread                     " poll for file updates automatically.
" set clipboard=unnamedplus      " Yanking will copy to the system clipboard.
set foldmethod=syntax            " Fold code based on the language syntax.
set encoding=UTF-8               " UTF-8 character encodings.
set exrc                         " enable per project configurations.
set secure                       " disable autocmd in files not owned by me.
set splitbelow                   " Always vertical split to below.
set splitright                   " Always horizontal split to the right.
set cmdheight=1                  " Set the cmd height.
set updatetime=300               " Change the update time.
set mouse=a                      " Enable mouse support without copy/paste.

" -------------------------------- ETC CONFIG ----------------------------------

set rtp+=$GOPATH/src/golang.org/x/lint/misc/vim    " Add golang linter
" autocmd BufNewFile,BufRead *.vue set filetype=typescript " Set Vue to use html plugins
filetype plugin indent on                          " Enable plugin indent

"
" ------------------------------------ COLORS ----------------------------------

" highlight! Comment ctermfg=246
" highlight! String ctermfg=81
" highlight! Number ctermfg=81
" highlight! Float ctermfg=81
" highlight! Constant ctermfg=231
" highlight! Function ctermfg=203
" highlight! Type ctermfg=121
" highlight! LineNr ctermfg=226

" ------------------------------------ INPUT -----------------------------------

" Go to normal mode and quit once in it
inoremap <silent> jj <ESC>
nnoremap <silent> ;; :q<CR>

" Key mapping for saving via ctrl-s in all modes
noremap <silent> <C-S> :update<CR>
vnoremap <silent> <C-S> <C-C>:update<CR>
inoremap <silent> <C-S> <C-O>:update<CR>

" Telescope mappings
nnoremap <C-P>j <cmd>Telescope find_files<cr>
nnoremap <C-P>i <cmd>Telescope live_grep<cr>
nnoremap <C-P>k <cmd>Telescope buffers<cr>
nnoremap <C-P>l <cmd>Telescope help_tags<cr>

" Buffers - explore/next/previous (Bufexplorer plugin)
nnoremap <silent> 00 :BufExplorer<CR>
nnoremap <silent> 99 :bn<CR>
nnoremap <silent> 88 :bp<CR>

" Key mapping for nerdtree
map <C-N> :NERDTreeToggle %<CR>
let NERDTreeShowHidden=1

" Disable highlighting.
nnoremap \\ :noh<return>

" Setup for vim splits. This lets you easily travel between splits.
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
"
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Disable arrow keys.
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

]])

