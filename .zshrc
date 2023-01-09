export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

export UPDATE_ZSH_DAYS=30

DISABLE_UNTRACKED_FILES_DIRTY="true"

# set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd/mm/yyyy"

# ZSH_TMUX_AUTOSTART=true
plugins=(zsh-autosuggestions docker docker-compose tmux)

source $ZSH/oh-my-zsh.sh

# remove all aliases set by system and oh-my-zsh
unalias -a

# PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )" # default
PROMPT='%{$fg[green]%}%n@%m%}%{$fg[white]%}:%{$fg_bold[cyan]%}'
PROMPT+='%{$fg[cyan]%}${(%):-%~}%{$reset_color%} $(git_prompt_info)
%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$reset_color%}' # MAYBE use $ insead of ➜

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

# Set preferred editor
export EDITOR='vim'
export VISUAL='vim'

# Fix language error in perl and others
export LANGUAGE="$LANG"
export LC_ALL="$LANG"

# De duplicating paths inside $PATH https://www.linuxjournal.com/content/removing-duplicate-path-entries
export PATH=$(echo $PATH | awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print $0}')

function add_path() {
	[ -d "$1" ] && export PATH="$1:$PATH"
}

# source file if it exists and is not empty (-s)
function source_if_exists() {
	[ -s "$1" ] && source "$1"
}

# run file if it exists and is not empty (-s)
function run_if_exists() {
	[ -s "$1" ] && . "$1"
}

function log_and_run() {
	echo "$@"
	echo
	eval "$@"
}

ROOT="$HOME/git/dotfiles"
if [ ! -d "$ROOT" ]; then
	echo "FATAL: dotfiles not found at $ROOT"
fi

# if mac
if [ "$(uname -s)" = "Darwin" ]; then
	add_path "/opt/homebrew/bin"
	add_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

# if Q42 work laptop
if [ "$(hostname)" = "qlaptop" ]; then
	export NVM_DIR="$HOME/.nvm"
	run_if_exists "/opt/homebrew/opt/nvm/nvm.sh"
	run_if_exists "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

	# set npm secret
	if [ -f "$HOME/.npmrc" ]; then
		export NPM_TOKEN=$(sed -n -e 's/^.*Token=//p' $HOME/.npmrc)
	fi

	# gpg signing git
	export GPG_TTY=$(tty)

	# import secrets
	source_if_exists $ROOT/q42-secrets.sh

	# Google Cloud SDK
	run_if_exists "$HOME/.google-cloud-sdk/path.zsh.inc"
	run_if_exists "$HOME/.google-cloud-sdk/completion.zsh.inc"

	alias hue="node $HOME/q/Hue/tools/hue-cli/dist/index.js"

	export GOPATH="$HOME/.go"

	source_if_exists ~/.config/op/plugins.sh
fi

# if codam mac
if [[ $(hostname) == *".codam.nl"* ]] && [[ $(whoami) == "jkoers" ]]; then
	add_path "$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
	add_path "$HOME/.brew/bin"

	mkdir -p /sgoinfre/jkoers
	chown jkoers /sgoinfre/jkoers

	# save docker images on goinfre
	mkdir -p $HOME/goinfre/Library/Containers/com.docker.docker
	rm -rf $HOME/Library/Containers/com.docker.docker
	ln -s $HOME/goinfre/Library/Containers/com.docker.docker $HOME/Library/Containers/com.docker.docker
fi

# Aliases
if [ "$(uname -s)" = "Linux" ]; then
	alias ls="ls --color=auto"
	alias clip="xclip -selection c"
	alias ope="xdg-open"
else
	alias ls="ls -G"
fi
alias rcp="rsync -ah --info=progress2"
alias l="ls -Ahlk"

alias sshfs1="sshfs -o follow_symlinks joppe@192.168.2.1: $HOME/server1/"
alias sshfsp1="sshfs -o follow_symlinks -p 10001 joppe@joppekoers.nl: $HOME/server1/"

alias leak="valgrind --leak-check=full --show-leak-kinds=definite,indirect,possible --track-origins=yes"

alias notes="code $HOME/git/notes"
alias dc="docker compose"

# alias netstat="netstat -tulpn | grep :"

function drop {
	curl -X POST -F "upfile=@$1" https://joppekoers.nl/drop/upload -F "identifier=$2";
}
export drop

function droplocal {
	curl -X POST -F "upfile=@$1" http://localhost:8080/drop/upload -F "identifier=$2";
}
export droplocal

function mkcd {
	mkdir "$1" && cd "$1";
}
export mkcd

function profile {
	TMP=$(mktemp -d)
	valgrind -q --tool=callgrind --callgrind-out-file=$TMP/callgrind.out $@
	gprof2dot --format=callgrind --output=$TMP/out.dot $TMP/callgrind.out
	dot -Gdpi=400 -Tpng $TMP/out.dot -o profile.png
	dot -Tsvg $TMP/out.dot -o profile.svg
	rm -f $TMP/out.dot
}

function copygit {
	find "$1" -mindepth 1 -maxdepth 1 -not -name .git -exec cp -rf {} $2 \;
}

# This rsync remove is way faster than rm -r
function rrm {
	emptydir=$(mktemp -d)
	for dir in "$@"; do
		rsync -a --delete $emptydir/ "$dir"
		rm -rf "$dir"
	done
	rm -rf $emptydir
}

function loop {
	while true; do
		$@
	done
}

function gam {
	log_and_run "git --no-pager diff --stat HEAD -- $@"
	log_and_run "git add $@ && git commit --amend --no-edit"
}

function drs {
	log_and_run "docker stop $1; docker start $1; docker logs -f -n 10000 $1"
}

function dps {
	docker container list --no-trunc --format "table {{.Names}}\t{{.Status}}\t{{.Command}}\t{{.Ports}}"
}

# batcat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
if [ "$(uname -s)" = "Linux" ]; then
	export BAT_PAGER="less -RF"
fi

# Disable brew update before every package install
# Manually update with: `brew update`
export HOMEBREW_NO_AUTO_UPDATE=1

add_path "$HOME/.local/bin"

# Only ignore duplicate terminal commands, save the ones prefixed with whitespace
export HISTCONTROL=ignoredups

function preexec() {}
function precmd() {}

# allow * matcing in terminal
setopt no_bare_glob_qual

# disable rm * conformation prompt
setopt rmstarsilent

# Fix slowness of pastes (meant for zsh-syntax-highlighting.zsh but still works)
pasteinit() {
	OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
	zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}
pastefinish() {
	zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# disable escaping characters in url / url-quote-magic
zstyle :urlglobber url-other-schema

# Fzf
source_if_exists ~/.fzf.zsh
run_if_exists /etc/zsh.cnf

# Bun
source_if_exists "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
add_path "$BUN_INSTALL/bin"
