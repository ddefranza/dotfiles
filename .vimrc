set nocompatible                " Vim sets this implicitly when sourcing .vimrc
                                " we set it explicitly for completeness

set nomodeline                  " Prevent modeline hijacking 

set encoding=utf-8              " Set internal encoding
set fileencoding=utf-8          " Set default file encoding for new files 
set fileencodings=utf-8         " and reading files
language messages en_US.utf-8   " Set the language and locale

set fileformat=unix             " Use linux line endings when saving
set fileformats=unix,dos        " Try to read files as unix, fallback to dos

set shell=/bin/bash             " Use bash in the terminal
set autochdir                   " Change working directory to open buffer
set hidden                      " Allow unsaved buffers

set nobackup                    " Don't create backups of working files
set noswapfile                  " Don't create swap files
set noundofile                  " Don't create persistent undo files

set t_Co=16                     " Use 256 colors

let &t_SI.="\e[5 q"             " Use blinking vertical bar cursor for insert mode
let &t_SR.="\e[4 q"             " Use solid underscore cursor for replace mode
let &t_EI.="\e[1 q"             " Use blinking block cursor for normal mode

set visualbell                  " Show the visual bell effect
set noerrorbells                " Do not play the error bell sound effect

set wildmenu                    " Show completions in that status line
set laststatus=2                " Always show the status line

set ruler                       " Show the row and column number in status line
set number relativenumber       " Show line numbers and relative line numbers
set showcmd                     " Autocomplete commands 

set backspace=indent,eol,start  " Make backspace behave as expected

set tabstop=4                   " Set the width of a tab character
set shiftwidth=4                " Set the number of spaces for each (auto)indent step
set expandtab                   " Convert tabs to spaces


filetype plugin indent on       " Enable file-type detection and language-
                                " dependent indenting
set smartindent                 " Auto-indent after '{', useful for R and Python
set autoindent                  " Automatically indent when starting a new line 
                                " in insert mode

let python_highlight_all=1      " Enable all Python syntax highlighting
syntax on                       " Use syntax highlighting

set colorcolumn=88              " Show a line break indicator at 80 characters
silent! highlight ColorColumn   " Change the color of the colorcolumn
    \ ctermbg=238
set wrap                        " Wrap long lines for readability
set linebreak                   " Break lines at word boundaries
set showbreak=++                " Visual indicator for wrapped lines
set breakindent                 " Maintain indentation on wrapped lines
autocmd FileType                " Break lines for tex, markdown, and text files
    \ tex,markdown,text 
    \ setlocal textwidth=88 
    \ formatoptions+=t
autocmd FileType                " Don't break lines for python, r, or html
    \ python,r,html
    \ setlocal textwidth=0 
    \ formatoptions-=t
set whichwrap=<,>,h,l           " Wrap the cursor to the next line using arrows
                                " or h, l
set showmatch                   " Highlight matching brackets

set spell spelllang=en_us       " Enable spell-checking
hi clear SpellBad               " Clear the misspelling indicator
hi SpellBad cterm=underline     " Use underline as the misspelling indicator

" Set list characters to indicate tabs and trailing white space
 set list
 set lcs=tab:»·
 set lcs+=trail:·

 set hlsearch                   " Highlight all search results
 set ignorecase                 " Make search case-insensitive
 set smartcase                  " Make search respect explicitly defined case
 set incsearch                  " Search for strings incrementally
 nnoremap <CR>
    \ :nohlsearch<CR><CR>       " Clear search highlighting with RET

" PLUGINS 

" ALE
"" Lint commonly used code
let g:ale_linters = {
            \ 'python':     ['pylint'],
            \ 'r':          ['lintr'],
            \ 'tex':        ['lacheck'],
            \ 'markdown':   ['marksman'],
            \ 'html':       ['tidy'],
            \ }

"" Automagically fix code styling
let g:ale_fixers = {
            \ 'python':     ['black'],
            \ 'r':          ['styler'],
            \ 'tex':        ['latexindent'],
            \ }
let g:ale_fix_on_save=1         " Always fix code on save

" REPL-vim
"" Send code to the interactive shell
let g:repl_program = {
            \ 'python':     'ipython',
            \ 'r':          'R',
            \ 'sh':         'bash',
            \ 'vim':        'bash',
            \ 'default':    'bash',
            \ '':           'bash',
            \ }

"" Toggle REPL with leader key
noremap <leader>r :REPLToggle <CR>

" fzf-vim
set rtp+=/opt/homebrew/opt/fzf      " Enable search with fzf

"" Build a quickfix list from results
function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
    copen
    cfirst
endfunction

"" Keybindings for fzf
let g:fzf_action = {
            \ 'ctrl-q': function('s:build_quickfix_list'),
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit',
            \ 'ctrl-y': {lines -> setreg('*', join(lines, "\n"))}
            \ }

noremap <leader>f :Files! <CR>  " Invoke fzf search with leader key
noremap <leader>g :Rg! <CR>     " Invoke ripgrep search with leader key

" Code templates
:autocmd BufNewFile  *.r 0r ~/.vim/templates/skeleton.r

" Load plugins (download from GitHub if missing)...
" Installs a plugin into pack/{vendor}/{start|opt}/{name} if it's missing.
if !exists('*s:ensure_plugin')
  function! s:ensure_plugin(name, repo, where) abort
    let l:pack_root = expand('~/.vim/pack/git-plugins/' . (a:where ==# 'opt' ? 'opt' : 'start'))
    let l:plug_dir  = l:pack_root . '/' . a:name

    if !isdirectory(l:plug_dir)
      if !executable('git')
        echohl ErrorMsg | echom 'git not found; cannot install ' . a:name | echohl None
        return
      endif
      call mkdir(l:pack_root, 'p')
      let l:cmd = printf('git clone --depth 1 %s %s',
            \ shellescape(a:repo), shellescape(l:plug_dir))
      echom 'Installing ' . a:name . ' ...'
      let l:out = system(l:cmd)
      if v:shell_error
        echohl ErrorMsg | echom 'Failed to install ' . a:name . ': ' . l:out | echohl None
        return
      endif
      " Generate helptags if the plugin ships docs
      if isdirectory(l:plug_dir . '/doc')
        execute 'silent! helptags ' . fnameescape(l:plug_dir . '/doc')
      endif
      echom 'Installed ' . a:name
    endif

    " Load optional packages immediately
    if a:where ==# 'opt'
      execute 'packadd ' . a:name
    endif
  endfunction
endif

augroup PackBootstrap | autocmd!
  autocmd VimEnter * call s:ensure_plugin('ale', 
              \ 'https://github.com/dense-analysis/ale', 'start')
  autocmd VimEnter * call s:ensure_plugin('fzf.vim', 
              \ 'https://github.com/junegunn/fzf.vim', 'start')
  autocmd VimEnter * call s:ensure_plugin('repl', 
              \ 'https://github.com/sillybun/vim-repl', 'start')
  autocmd VimEnter * call s:ensure_plugin('vim-fugitive',
              \ 'https://github.com/tpope/vim-fugitive', 'start')
augroup END
