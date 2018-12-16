"Change default movement keys
"noremap ; l
"noremap l k
"noremap k j
"noremap j h

"P l u g
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"Colorscheme with pywal
call plug#begin()
Plug 'dylanaraps/wal.vim'
call plug#end()
colorscheme wal
