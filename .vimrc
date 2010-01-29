" my vimrc file.
" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
	finish
endif

set nocompatible
set showmatch

set backspace=indent,eol,start
set shiftwidth=8

set nofoldenable " disables this annoying feature.

set nobackup		" do not keep a backup file, use versions instead
set history=1000	" keep 1000 lines of command line history
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

set showtabline=2	"sets vim to always show its tab bar.

set ruler		" show the cursor position all the time
set laststatus=2	" makes the ruler/status bar like 10x more readable & use-able

set autoindent	" always set autoindenting on
" don't auto indent '#' comments
"inoremap # X^H#

" Don't use Ex mode, use Q for formatting
map Q gq

" In many terminal emulators the mouse works just fine, thus enable it.
set mouse=a

if &t_Co > 2 || has("gui_running")
	syntax on
	set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

	" Enable file type detection.
	" Use the default filetype settings, so that mail gets 'tw' set to 72,
	" 'cindent' is on in C files, etc.
	" Also load indent files, to automatically do language-dependent indenting.
	filetype plugin indent on

	" Put these in an autocmd group, so that we can delete them easily.
	augroup vimrcEx
	au!

	" For all text files set 'textwidth' to 78 characters.
	autocmd FileType text setlocal textwidth=78

	" When editing a file, always jump to the last known cursor position.
	" Don't do it when the position is invalid or when inside an event handler
	" (happens when dropping a file on gvim).
	autocmd BufReadPost *
	  \ if line("'\"") > 0 && line("'\"") <= line("$") |
	  \   exe "normal! g`\"" |
	  \ endif

	augroup END

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
	 	\ | wincmd p | diffthis

map Y y$


