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

colorscheme dracula             " Use the dracula colorscheme (requires plugin)

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

 " Yank to the system clipboard
nnoremap "+y :call system('wl-copy', @\")<CR>
" Paste from the system clipboard
nnoremap "+p :let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>',
            \'', 'g')<CR>p

" PLUGINS 

" ALE
let g:ale_linters_explicit = 1          " Disable built-in linters
let g:ale_lint_on_insert_leave = 1  " Lint every time we exit insert mode

"" Lint commonly used code
let g:ale_linters = {
            \ 'python':     ['pylint'],
            \ 'r':          ['custom_lintr'],
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

" Define a custom lintr to work around ALE and lintr dependencies
call ale#linter#Define('r', {
\   "name": "custom_lintr",
\   "executable": "lintr",
\   "command": "lintr \%s",
\   "output_stream": "stdout",
\   "format": "%f:%l:%c: %t: [%n] %m",
\   "callback": "ale#handlers#gcc#HandleGCCFormat"
\})

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
set rtp+=/usr/bin/fzf      " Enable search with fzf

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
            \ 'ctrl-o': ':r !echo',
            \ 'ctrl-y': {lines -> setreg('*', join(lines, "\n"))}
            \ }

noremap <leader>f :Files! <CR>  " Invoke fzf search with leader key
noremap <leader>g :Rg! <CR>     " Invoke ripgrep search with leader key

" Code templates
:autocmd BufNewFile  *.r 0r ~/.vim/templates/skeleton.r

" Settings for vim-markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_fenced_languages = ['python=py', 'r', 'html', 'css', 'javascript',
            \ 'markdown=md', 'viml=vim', 'bash=sh']
let g:vim_markdown_math = 1

" Taking notes in Vim
"" Insert a date-time indexed log entry
""" For Normal Mode: Open a new line above and insert the date
nnoremap <leader>t O<C-R>=strftime('* %Y-%m-%d %T: ')<CR>
""" For Insert Mode: Exit to normal mode, open a line above, then insert the date
inoremap <leader>t <Esc>O<C-R>=strftime('* %Y-%m-%d %T: ')<CR>

"" Create a new note with a timestamped filename
function! NewNote(title)
  " 1. Get the current timestamp in YYYYMMDDHHMMSS format
  let l:timestamp = strftime('%Y%m%d%H%M%S')

  " 2. Process the title: make it lowercase and replace spaces with underscores
  let l:processed_title = substitute(tolower(a:title), ' ', '_', 'g')

  " 3. Combine them into the final filename
  let l:filename = l:timestamp . '_' . l:processed_title . '.md'

  " 4. Open the new file for editing
  execute 'edit ' . l:filename
endfunction

"" Create a user command that calls the function
command! -nargs=+ NewNote call NewNote(<q-args>)

"" Map <leader>z to the command in normal mode
nnoremap <leader>z :NewNote 

"" Auto-updating Zettelkasten Index (Location-Independent)

" Set the absolute path to your notes directory
let g:zettelkasten_dir = expand('~/Documents/notes/')

" Keybinding to open the Zettelkasten index file from anywhere
" Press <leader>zi (e.g., \ni) to open the index.
nnoremap <leader>zi :execute 'e ' . fnameescape(g:zettelkasten_dir . '00_index.md')<CR>
"" Press <leader>zl (e.g., \ni) to open the index from any other note.
nnoremap <leader>zl :execute 'e ' . fnameescape(g:zettelkasten_dir . '02_research_log.md')<CR>

" Define an autocommand group to prevent duplicate autocommands
augroup ZettelkastenIndex
  autocmd!
  " Run the function whenever you open your index file
  autocmd BufRead,BufEnter 00_index.md call GenerateZettelIndex()
augroup END

" The main function to generate the index content
function! GenerateZettelIndex()
  " --- Configuration ---
  let s:log_file = '02_research_log.md'
  let s:excluded_files = ['00_index.md', '01_LITERATURE.bib', s:log_file]

  " Save current directory and switch to the notes directory
  let l:original_dir = getcwd()
  if !isdirectory(g:zettelkasten_dir)
    echom "Zettelkasten Error: Directory not found at " . g:zettelkasten_dir
    return
  endif
  execute 'lcd' fnameescape(g:zettelkasten_dir)

  " A list to hold the lines of our new index file
  let l:lines = []
  
  " --- 1. Header ---
  call add(l:lines, '# Notebook Index')
  call add(l:lines, '')
  
  " --- 2. Recent Log Entries ---
  call add(l:lines, '## Recent log')
  if filereadable(s:log_file)
    " *** MODIFIED: Read the whole file, then take a slice to skip the header ***
    let l:all_log_lines = readfile(s:log_file)
    " Check if there are more than 2 lines, then get lines 3 through 7 (indices 2 to 6)
    let l:log_entries = (len(l:all_log_lines) > 2) ? l:all_log_lines[2:6] : []

    for entry in l:log_entries
      if !empty(entry)
        " call add(l:lines, '* ' . entry)
        call add(l:lines, entry)
      endif
    endfor
  endif
  call add(l:lines, '')
  
  " --- 3. Notes ---
  call add(l:lines, '## Notes')
  let l:note_files = filter(split(globpath('.', '*'), '\n'), 'index(s:excluded_files, v:val) == -1')
  for filename in sort(l:note_files)
    call add(l:lines, '* ' . filename)
  endfor
  call add(l:lines, '')
  
  " --- 4. Tags ---
  call add(l:lines, '## Tags')
  let l:tags = {}
  for filename in l:note_files
    for line in readfile(filename)
      let l:pos = 0
      while l:pos >= 0
          let l:tag_pattern = '#[a-zA-Z0-9-]\+'
          let l:pos = match(line, l:tag_pattern, l:pos)
          if l:pos >= 0
            let l:tag_end = matchend(line, l:tag_pattern, l:pos)
            let l:tag = strpart(line, l:pos, l:tag_end - l:pos)
            let l:tags[l:tag] = 1
            let l:pos = l:tag_end
          endif
      endwhile
    endfor
  endfor
  
  for tag in sort(keys(l:tags))
    call add(l:lines, '* ' . tag)
  endfor

  " --- Final Step: Update the buffer ---
  let l:modified_status = &modified
  setlocal modifiable
  
  %d_
  call append(0, l:lines)
  1d_
  
  let &modified = l:modified_status
  setlocal nomodified

  " *** NEW: Restore the original directory ***
  execute 'lcd' l:original_dir
endfunction

"" Load all plugins on start
for dir in split(glob('~/.vim/pack/git-plugins/start/*'), '\n')
    let plugin = fnamemodify(dir, ':t')
    exec 'packadd! ' . plugin
endfor
