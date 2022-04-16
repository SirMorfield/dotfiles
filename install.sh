#!/bin/bash

# git config --global user.name ""
# git config --global user.email ""

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	sudo apt install -y zsh git
else
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# fix permissions
	# sudo chown -R $(whoami):admin /usr/local/share/zsh /usr/local/share/zsh/site-functions
	# sudo chown -R $(whoami):admin /usr/local/var/homebrew
	# sudo chown -R $(whoami):admin /usr/local/Homebrew
	# sudo chown -R $(whoami):admin /usr/local/share
	# sudo chown -R $(whoami):admin /usr/local/opt
	# sudo chown -R $(whoami):admin /usr/local/bin
	brew install zsh git

	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
rm -f ~/.zshrc
ln -s ~/.dotfiles/.zshrc ~
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
ln -s ~/.dotfiles/.tmux.conf ~

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	sudo apt install -y bat
	mkdir -p ~/.local/bin
	ln -s /usr/bin/batcat ~/.local/bin/bat
else
	mkdir -p ~/.local/bin/
	cd /tmp/
	curl -L https://github.com/sharkdp/bat/releases/download/v0.20.0/bat-v0.20.0-x86_64-apple-darwin.tar.gz -o bat-v0.20.0-x86_64-apple-darwin.tar.gz
	tar -xf bat-v0.20.0-x86_64-apple-darwin.tar.gz
	mv  bat-v0.20.0-x86_64-apple-darwin/bat ~/.local/bin/
	rm -rf bat-v0.20.0-x86_64-apple-darwin*
	cd -
fi
