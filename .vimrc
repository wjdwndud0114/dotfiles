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
Plug 'tpope/vim-dispatch'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'vim-airline/vim-airline'
Plug 'majutsushi/tagbar'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'sheerun/vim-polyglot'
Plug 'dense-analysis/ale'
Plug 'mhinz/vim-signify'
Plug 'luochen1990/rainbow'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" Ale
let g:ale_linters = {
  \   'python': ['flake8', 'pylint'],
  \   'javascript': ['eslint', 'tslint'],
  \   'typescript': ['eslint', 'tslint'],
  \   'typescriptreact': ['eslint', 'tslint'],
  \   'vue': ['eslint']
  \}
let g:ale_fixers= {
  \   'javascript': ['eslint', 'tslint', 'prettier'],
  \   'typescript': ['eslint', 'tslint', 'prettier'],
  \   'typescriptreact': ['eslint', 'tslint', 'prettier'],
  \   'css': ['prettier'],
  \   'json': ['prettier']
  \}
let b:ale_set_balloons=1
let g:ale_open_list=0
let g:ale_list_window_size=3
let g:ale_lint_on_save=1
let g:ale_lint_on_text_changed='never'
let g:ale_lint_on_insert_leave=1
let g:ale_lint_delay=300
let g:ale_fix_on_save=1
let g:ale_sign_error='❌'
let g:ale_sign_warning='⚠️'
let g:ale_javascript_prettier_use_local_config=1
let g:airline#extensions#ale#enabled=1
" let g:ale_completion_enabled = 1
" let g:ale_completion_autoimport = 1
hi link ALEErrorSign    Error
hi link ALEWarningSign  Warning
execute "set <M-a>=\ea"
execute "set <S-F12>=\e[24~"
map <M-a> :ALEToggle<CR>
nnoremap <silent> ]r :ALENext<CR>     " move to the next ALE warning / error
nnoremap <silent> [r :ALEPrevious<CR> " move to the previous ALE warning / error
" nnoremap <F12> :ALEGoToDefinition<CR>
" nnoremap <leader><F12> :vsp<CR>:ALEGoToDefinition<CR>
" nnoremap <leader><S-F12> :vsp<CR><C-w>T:ALEGoToDefinition<CR>
" nnoremap K :ALEHover<CR>
" nnoremap <silent> gr :ALEFindReferences<CR>
" nnoremap <leader>rn :ALERename<CR>

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
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
" confirm choice with <CR>
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
"
" GoTo code navigation.
" nmap <silent> <F2> <Plug>(coc-rename)
nmap <silent> <F12> <Plug>(coc-definition)
nmap <silent> <leader><F12> :call CocActionAsync('jumpDefinition', 'vsplit')<CR>
nmap <silent> <leader><S-F12> :call CocActionAsync('jumpDefinition', 'drop')<CR>
nnoremap <silent> <leader>h :call CocActionAsync('doHover')<cr>
" nmap <silent> <S-F12> <Plug>(coc-type-definition)
" nmap <silent> <M-F12> <Plug>(coc-implementation)
nmap <silent> <leader>gr <Plug>(coc-references)
" NEED :CocInstall coc-tsserver coc-json
"   if error, need to downgrade tsserver to 4.2.4
"   ~/.config/coc/extensions/node_modules/coc-tsserver -> open package.json,
"   change version for tsserver, npm install

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

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
let g:netrw_winsize = 50
function! ToggleNetrw()
        let i = bufnr("$")
        let wasOpen = 0
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout " . i
                let wasOpen = 1
            endif
            let i-=1
        endwhile
    if !wasOpen
        silent Vexplore
    endif
endfunction
map <silent> <Leader>e :call ToggleNetrw()<CR>
" map <silent> <Leader>e :Lexplore<CR>
" Freed <C-l> in Netrw
nmap <leader><leader>l <Plug>NetrwRefresh

" Airline
set laststatus=2
set noshowmode

" FZF
nnoremap <C-p> :GFiles<CR>
nnoremap <Leader>H :History<CR>
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
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
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

" DROPBOX DBX
nnoremap <leader><leader>r :Dispatch! bzl itest-reload-current<CR>
nnoremap <leader><leader><S-r> :Dispatch bzl itest-reload-current<CR>
