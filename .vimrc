"Start the plugin process
call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim' " Fuzzy file finder.
Plug 'sheerun/vim-polyglot' " Better syntax and indentation.
Plug 'scrooloose/nerdtree' " File explorer.
Plug 'vim-airline/vim-airline' " Status line with buffers shown
Plug 'jlanzarotta/bufexplorer' " Buffer explorer
Plug 'airblade/vim-gitgutter' " Shows git diffs in 'gutter'
Plug 'neoclide/coc.nvim', {'branch':'release'}
Plug 'ryanoasis/vim-devicons' " Install devicon Install devicons
Plug 'wakatime/vim-wakatime' " Make sure that I am coding
Plug 'mattn/emmet-vim' " Provides a nice way to write html
Plug 'w0rp/ale' " Asyncrhonous linter for all linters
Plug 'luochen1990/rainbow' " Rainbow highlighting for braces and paranthesis
Plug 'RRethy/vim-illuminate' " Highlight words that match what's under the cursor throughout the file
Plug 'lilydjwg/colorizer' " Colorize hex color codes
Plug 'tmux-plugins/vim-tmux-focus-events' " Allow tmux to pass through on and off focus events into vim
Plug 'tpope/vim-obsession' " Write the current state of vim into a command

" Plug 'grailbio/bazel-compilation-database' For working with bazel projects like terrace
call plug#end() " Init all plugins

" Add powerline to vim shell
let g:airline_powerline_fonts = 1

" Enable tab lines
let g:airline#extensions#tabline#enabled = 1

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

let g:ale_linters = {
\'css': ['stylelint'], 
\'javascript': ['eslint'], 
\'cpp': ['cpplint']
\}

let g:ale_linter_aliases = {'typescriptreact': 'typescript'}
let g:ale_python_autopep8_options = '--aggressive -i'
let g:ale_cpp_cpplint_options = '--filter=-build/include_subdir, -legal/copyright'
let g:ale_go_golint_options = '-w -s'
let g:ale_fix_on_save = 1

" Nerd tree config

" let g:NERDTreeNodeDelimiter = "\u00a0"

" Add colors
" hi link illuminatedWord Visual

" Add golang linter
set rtp+=$GOPATH/src/golang.org/x/lint/misc/vim

" For every vue file, 
autocmd BufNewFile,BufRead *.vue set filetype=html

"Enable plugin indent
filetype plugin on
filetype plugin indent on

" Coc plugin updates

let g:coc_global_extensions = [
    \ 'coc-snippets',
    \ 'coc-pairs',
    \ 'coc-tsserver',
    \ 'coc-html',
    \ 'coc-emmet',
    \ 'coc-css',
    \ 'coc-json',
    \ 'coc-eslint',
    \ 'coc-clangd',
    \ 'coc-rls',
    \ 'coc-go',
    \ 'coc-python',
    \ 'coc-spell-checker',
    \ 'coc-yaml'
    \ ]

" Set the color of the floating background.
hi! CocFloating ctermfg=152 ctermbg=234

set cmdheight=1 " Set the cmd height
set updatetime=300 " Change the update time.

" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if has('patch8.1.1068')
  " Use `complete_info` if your (Neo)Vim version supports it.
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and all it's references.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Rename symbols
nmap <leader>rn <Plug>(coc-rename)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for selection ranges.
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

"
" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" Vanilla vim modifications
" let laststatus=2 "Display the status line for vim. (Needed for lightline)
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
set autoread " Set vim to autoread from a file if it's been modified
set clipboard=unnamedplus " Allows access to the global clipboard
set foldmethod=syntax  "  Set the fold method to rely on the language
set nofoldenable " Remove folding
set encoding=UTF-8 " UTF-8 character encodings

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

set exrc " enable per project configurations
set secure " disable autocmd to be run from files that arent' owned by me

" Setup for vim splits. This lets you easily travel between splits.
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Set splits to be default on the bottom and right.
set splitbelow
set splitright

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
