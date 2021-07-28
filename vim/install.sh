#!/bin/bash 
brew install neovim
brew install ripgrep

mkdir -p ~/.config/nvim
cp "$ZSH/vim/init.vim" ~/.config/nvim/

pip3 install --user pynvim

nvim +PlugInstall +qall
