" ------------------------------------ PLUGINS ---------------------------------

call plug#begin('~/.vim/plugged')

Plug 'sheerun/vim-polyglot'                     " Better syntax and indentation.
Plug 'scrooloose/nerdtree'                      " File explorer.
Plug 'vim-airline/vim-airline'                  " Powerline with buffers.
Plug 'jlanzarotta/bufexplorer'                  " Buffer explorer.
Plug 'airblade/vim-gitgutter'                   " Shows git diffs in 'gutter'.
Plug 'neoclide/coc.nvim', {'branch':'release'}  " Intellisense engine for LSPs.
Plug 'ryanoasis/vim-devicons'                   " Icon pack.
Plug 'RRethy/vim-illuminate'                    " Highlight under the cursor.
Plug 'lilydjwg/colorizer'                       " Colorize hex color codes.
Plug 'tmux-plugins/vim-tmux-focus-events'       " Grant tmux access to events.
Plug 'tpope/vim-obsession'                      " Persist state of vim.
Plug 'tikhomirov/vim-glsl'                      " GLSL syntax shading for vim.
Plug 'github/copilot.vim'                       " Copilot for vim.

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }


" --- DISABLED ---
"
" Fuzzy file finder.
" Plug 'ctrlpvim/ctrlp.vim' 

call plug#end() " Init all plugins

" ------------------------------------ AIRLINE ---------------------------------

" Add powerline to vim shell
let g:airline_powerline_fonts = 1

" Enable tab lines
let g:airline#extensions#tabline#enabled = 1

" enable rainbow plugin at startup
let g:rainbow_active = 1

" ------------------------------------ RIPGREP ---------------------------------

" if executable('rg')
"    set grepprg=rg\ --color=never
"    let g:ctrlp_user_command = 'rg %s --files --hidden --color=never --glob ""'
"    let g:ctrlp_use_caching = 0
" endif

" ------------------------------- YANK FOR WINDOWS -----------------------------

" if system('uname -r') =~ "microsoft"
"    augroup Yank
"        autocmd!
"        autocmd TextYankPost * :call system('/mnt/c/windows/system32/clip.exe ',@")
"        augroup END
" endif

" ------------------------------------ COC --------------------------------

let g:coc_global_extensions = [
    \ 'coc-snippets',
    \ 'coc-pairs',
    \ 'coc-tsserver',
    \ 'coc-html',
    \ 'coc-emmet',
    \ 'coc-css',
    \ 'coc-json',
    \ 'coc-eslint',
    \ 'coc-rust-analyzer',
    \ 'coc-go',
    \ 'coc-pyright',
    \ 'coc-spell-checker',
    \ 'coc-yaml',
    \ 'coc-vetur'
    \ ]

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
set background=dark              " Use a dark background.
set t_Co=256                     " Set the terminal to use 256 colors.
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

" ------------------------------------ COLORS ----------------------------------

hi! Comment ctermfg=246
hi! String ctermfg=81
hi! Number ctermfg=81
hi! Float ctermfg=81
hi! Constant ctermfg=231
hi! Function ctermfg=203
hi! Type ctermfg=121
hi! LineNr ctermfg=226

" Coc
" hi! CocFloating ctermfg=152 ctermbg=234

" C++
" hi! cppSTLFunction ctermfg=231
" hi! cppSTLType ctermfg=231
hi! cppStructure ctermfg=226

" Highlight text longer than 80 chars.
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

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

" Remap for complete
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" remap for complete to use tab and <cr>
inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#pum#next(1):
        \ <SID>check_back_space() ? "\<Tab>" :
        \ coc#refresh()

inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <c-space> coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Rename symbol.
nmap <leader>rn <Plug>(coc-rename)

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

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

" List all actions that can be taken on the current line.
nmap <leader>ac  <Plug>(coc-codeaction)

" Apply auto-fix (Usually the first option) to the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Select all of the inner function body in visual/operator mode.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)

" Select all of the function in visual/operator mode.
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for selection ranges.
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Show all diagnostics for the current project.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>

" Manage Coc extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>

" Show COC commands available for the current project.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>

" Find a symbol within current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>

" Search workspace for symbols. (Project searching)
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>

" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>

" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>

" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
