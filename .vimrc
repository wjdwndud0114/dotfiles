set nocompatible "ward off unexpected things from distro + reset options

"Install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'
Plug 'rakr/vim-one'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-repeat'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'vim-airline/vim-airline'
Plug 'majutsushi/tagbar'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'sheerun/vim-polyglot'
Plug 'dense-analysis/ale'
Plug 'mhinz/vim-signify'
Plug 'luochen1990/rainbow'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" Ale
let g:ale_linters = {
  \   'python': ['flake8', 'pylint'],
  \   'javascript': ['eslint'],
  \   'typescript': ['eslint'],
  \   'typescriptreact': ['eslint'],
  \   'vue': ['eslint']
  \}
let g:ale_fixers= {
  \   'javascript': ['eslint', 'prettier'],
  \   'typescript': ['eslint', 'prettier'],
  \   'typescriptreact': ['eslint', 'prettier'],
  \   'css': ['prettier'],
  \   'json': ['prettier']
  \}
let g:ale_completion_enabled = 1
let g:ale_completion_autoimport = 1
let b:ale_set_balloons=1
let g:ale_open_list=0
let g:ale_list_window_size=3
let g:ale_lint_on_save=1
let g:ale_lint_on_text_changed=1
let g:ale_lint_delay=500
let g:ale_fix_on_save=1
let g:ale_sign_error='❌'
let g:ale_sign_warning='⚠️'
let g:ale_javascript_prettier_use_local_config=1
let g:airline#extensions#ale#enabled=1
hi link ALEErrorSign    Error
hi link ALEWarningSign  Warning
execute "set <M-a>=\ea"
map <M-a> :ALEToggle<CR>
" map <F12> :ALEGoToDefinition
nnoremap ]r :ALENext<CR>     " move to the next ALE warning / error
nnoremap [r :ALEPrevious<CR> " move to the previous ALE warning / error

" fugitive
nmap <leader>gb :G branch<space>
nmap <leader>gs :G<CR>
nmap <leader>gc :G checkout<space>
nmap <leader>gp :G push<space>
nmap <leader>gpu :G pull<space>

" signify
nmap <silent> <F7> :SignifyToggle<CR>
set updatetime=750

" coc.nvim
" Use tab for trigger completion with characters ahead and navigate.
" inoremap <silent><expr> <TAB>
"       \ pumvisible() ? "\<C-n>" :
"       \ <SID>check_back_space() ? "\<TAB>" :
"       \ coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" function! s:check_back_space() abort
"   let col = col('.') - 1
"   return !col || getline('.')[col - 1]  =~# '\s'
" endfunction

" inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
" inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
" confirm choice with <CR>
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
"
" GoTo code navigation.
" nmap <silent> <F2> <Plug>(coc-rename)
" nmap <silent> <F12> <Plug>(coc-definition)
" nmap <silent> <leader><F12> :call CocAction('jumpDefinition', 'vsplit')<CR>
" nmap <silent> <S-F12> <Plug>(coc-type-definition)
" nmap <silent> <M-F12> <Plug>(coc-implementation)
" nmap <silent> <M-S-F12> <Plug>(coc-references)

" Symbol renaming.
" nmap <leader>rn <Plug>(coc-rename)

" Tagbar
nmap <F8> :TagbarToggle<CR>

" NERDTree NOT USED ANYMORE
" map <C-n> :NERDTreeToggle<CR>
" map <Leader>r :NERDTreeFind<CR>
" let NERDTreeMapOpenSplit='s'
" let NERDTreeMapPreviewSplit='gs'
" let NERDTreeMapOpenVSplit='v'
" let NERDTreeMapPreviewVSplit='gv'
" let NERDTreeMapJumpNextSibling='<M-J>'
" let NERDTreeMapJumpPrevSibling='<M-K>'
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | e | ndif
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25

" Airline
set laststatus=2
set noshowmode

" FZF
nnoremap <C-p> :GFiles<CR>
nnoremap <Leader>h :History<CR>
nnoremap <Leader>H :History:<CR>
set rtp+=/usr/local/opt/fzf

if (has("termguicolors"))
  let &t_8f="[38;2;%lu;%lu;%lum"
  let &t_8b="[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" gruvbox
"let g:gruvbox_italic=1
" let g:gruvbox_contrast_dark="medium" "soft/medium/hard
" let g:gruvbox_contrast_light="medium"
" let g:airline_theme='gruvbox'
" colorscheme gruvbox

" one
let g:one_allow_italics=1
let g:airline_theme='one'
colorscheme one

syntax on
set background=dark
set t_ut=

set showmatch "show matching parenthesis
set number "show line numbers
set noerrorbells "no annoying error sounds
set belloff=all

set list "show tabs
set listchars=tab:>-,trail:-

"auto expanding
inoremap (<CR> (<CR>)<C-c>O
inoremap {<CR> {<CR>}<C-c>O
inoremap [<CR> [<CR>]<C-c>O

"splits
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
set splitbelow
set splitright

set autoread
set ruler
set cursorline
set showmatch
set scrolloff=3

"searching
set incsearch
set hlsearch
set ignorecase
set smartcase
set history=1000

"wildmenu
set wildmenu
set wildmode=longest:full,full

"Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
  set wildignore+=.git\*,.hg\*,.svn\*
else
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store 
endif

"indentation
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set smarttab
set cindent 
au FileType javascript setlocal formatprg=prettier
au FileType javascript.jsx setlocal formatprg=prettier
au FileType typescript setlocal formatprg=prettier\ --parser\ typescript
au FileType html setlocal formatprg=js-beautify\ --type\ html
au FileType scss setlocal formatprg=prettier\ --parser\ css
au FileType css setlocal formatprg=prettier\ --parser\ css

"cursor
" if exists('$TMUX')
"   let &t_SI="Ptmux;\e[6 q\\" " start insert mode
"   let &t_EI="Ptmux;\e[9 q\\" " end insert mode
" else
"   let &t_SI="\e[6 q" " start insert mode
"   let &t_EI="\e[9 q" " end insert mode
" endif
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_SR = "\<Esc>]50;CursorShape=2\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
" optional reset cursor on start:
augroup myCmds
au!
autocmd VimEnter * silent !echo -ne "$&t_EI"
autocmd VimLeave * silent !echo -ne "$&t_SI"
augroup END

set ttimeoutlen=0 "remove delay

filetype plugin indent on
