"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=utf-8
set history=700

filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

set nocompatible
set showcmd
set showmode
set number

set clipboard=unnamed

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc

"Always show current position
set ruler

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
"set backspace=eol,start,indent
"set whichwrap+=<,>,h,l

" Search case and highlight
set ignorecase
set smartcase
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells

" No file explorer banner
let g:netrw_banner = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax enable

if has("win32")
  set gfn=Consolas\ 11
else
  set gfn="Source Code Pro"\ 11
endif

set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

colorscheme peachpuff

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set smarttab

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines
set tabstop=4
set shiftwidth=4
set list
set listchars=trail:~,tab:▷-,nbsp:␣
