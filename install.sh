brew install bat
brew install git

git config --global user.name "SirMorfield"
git config --global user.email "joppe.koers@gmail.com"

ln -s ~/.dotfiles/.zshrc ~
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
ln -s ~/.dotfiles/.tmux.conf ~

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install
