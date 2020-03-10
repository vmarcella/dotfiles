"Start the plugin process
call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim' " Fuzzy file finder.
Plug 'sheerun/vim-polyglot' " Better syntax and indentation.
Plug 'scrooloose/nerdtree' " File explorer.
Plug 'vim-airline/vim-airline' " Status line with buffers shown
Plug 'jlanzarotta/bufexplorer' " Buffer explorer
Plug 'airblade/vim-gitgutter' " Shows git diffs in 'gutter'
Plug 'Valloric/YouCompleteMe' " Code completion. (Disabled for now)
Plug 'wakatime/vim-wakatime' " Make sure that I am coding
Plug 'mattn/emmet-vim' " Provides a nice way to write html
Plug 'w0rp/ale' " Asyncrhonous linter for all linters
Plug 'luochen1990/rainbow' " Rainbow highlighting for braces and paranthesis
Plug 'RRethy/vim-illuminate' " Highlight words that match what's under the cursor throughout the file
Plug 'lilydjwg/colorizer' " Colorize hex color codes
Plug 'tmux-plugins/vim-tmux-focus-events' " Allow tmux to pass through on and off focus events into vim
Plug 'tpope/vim-obsession' " Write the current state of vim into a command
" Re enable when working on terrace
Plug 'grailbio/bazel-compilation-database' " For working with bazel projects like terrace

call plug#end() "Init all plugins

" plugin related variables/configs

" Add powerline to vim shell
let g:airline_powerline_fonts = 1

" Enable tab lines
let g:airline#extensions#tabline#enabled = 1

" Closes ycm context window after completion
let g:ycm_autoclose_preview_window_after_completion=1

let g:ycm_server_python_interpreter='/usr/bin/python3'

" Extra conf for ycm (C++ autocomplete)
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'

" enable rainbow plugin at startup
let g:rainbow_active=0

" Ale config

" Setup ale fixers
" Currently blocked out since it's being a bad boi
" \'cpp':['clang-format'],
let g:ale_fixers = {
\'python':['autopep8', 'black', 'isort'],
\'typescript':['prettier', 'eslint'],
\'javascript':['prettier', 'eslint'],
\'go':['gofmt', 'goimports']
\}

let g:ale_linters = {'css': ['stylelint'], 'javascript': ['eslint']}
let g:ale_linter_aliases = {'typescriptreact': 'typescript'}
let g:ale_python_autopep8_options = '--aggressive -i'
let g:ale_cpp_cpplint_options = '--filter=-build/include_subdir, -legal/copyright'
let g:ale_go_golint_options = '-w -s'
let g:ale_fix_on_save = 1

" Nerd tree config

let g:NERDTreeNodeDelimiter = "\u00a0"

" Add colors
hi link illuminatedWord Visual

" Add golang linter
set rtp+=$GOPATH/src/golang.org/x/lint/misc/vim

" For every vue file, 
autocmd BufNewFile,BufRead *.vue set filetype=html

"Enable plugin indent
filetype plugin on
filetype plugin indent on

set laststatus=2 "Display the status line for vim. (Needed for lightline)
syntax on "Turn syntax highlighting on. (Needed for polyglot)
set nowrap "Don't wrap lines.
set backspace=indent,eol,start "Allow everything to be backspaced over in insert mode.
set autoindent "Auto indents, at least I think
set copyindent "Copy previous indentation of autoindent.
set number "set line numbers
set tabstop=4 shiftwidth=4 "Tabbing is always 4 spaces (hard tabs)
set expandtab "INsert tabs on the start of a line according to shiftwidth
set showmatch "Show matching parantheses.
set visualbell "Don't beep
set noerrorbells "Plz don't beep
set hidden "Allow edited hidden buffers that aren't visible to exist in the back
set backup "Tells vim where to save backup files
set backupdir=$HOME/.vim/backup/ "Where to save backup files
set noswapfile "Remove the swap file
set dir=$HOME/.vim/swap/ "Where to save swap files
set background=dark "Set the background dark
set t_Co=256 "Set the terminal to use 256 colors
" set mouse=a "Set the mouse on
set autoread " Set vim to autoread from a file if it's been modified
set clipboard=unnamedplus " Allows access to the global clipboard
set foldmethod=syntax  "  Set the fold method to rely on the language
set nofoldenable " Remove folding

"Go to normal mode and quit once in it
inoremap <silent> jj <ESC>
nnoremap <silent> ;; :q<CR>

"Buffers - explore/next/previous (Bufexplorer plugin)
nnoremap <silent> 77 :BufExplorer<CR>
nnoremap <silent> 99 :bn<CR>
nnoremap <silent> 88 :bp<CR>

"Key mapping for saving via ctrl-s in all modes
noremap <silent> <C-S> :update<CR>
vnoremap <silent> <C-S> <C-C>:update<CR>
inoremap <silent> <C-S> <C-O>:update<CR>

"Key mapping for nerdtree
map <C-N> :NERDTreeToggle %<CR>
let NERDTreeShowHidden=1

"Add auto closing functionality for vim with just vanilla vim
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O}} } ] )' '" "

set exrc " enable per project configurations
set secure " disable autocmd to be run from files that arent' owned by me

" Disable arrow keys.
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" Highlight text over 80 chars.
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/
