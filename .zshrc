export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

export UPDATE_ZSH_DAYS=30

DISABLE_UNTRACKED_FILES_DIRTY="true"

# set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd/mm/yyyy"

# ZSH_TMUX_AUTOSTART=true
plugins=(cmdtime zsh-autosuggestions docker docker-compose z fzf-zsh-plugin)

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

RESET='\e[0m'
PURPLE='\e[0;35m'

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
	echo $PURPLE$@$RESET
	echo
	eval "$@"
}

ROOT="$HOME/git/dotfiles"
if [ ! -d "$ROOT" ]; then
	echo "FATAL: dotfiles not found at $ROOT"
fi

if [ "$(uname -s)" = "Darwin" ]; then
	# Disable brew update before every package install
	# Manually update with: `brew update`
	export HOMEBREW_NO_AUTO_UPDATE=1

	add_path "/opt/homebrew/bin"
	add_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

# if codam mac
if [[ $(hostname) == *".codam.nl"* ]] && [[ $(whoami) == "jkoers" ]]; then
	add_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
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
	export SYSTEMD_EDITOR=vim
else
	alias ls="ls -G"
fi
alias rcp="rsync -ah --info=progress2"
alias l="ls -Ahlk" # TODO -h not working on OSX?

alias sshfs1="sshfs -o follow_symlinks joppe@192.168.2.1: $HOME/server1/"
alias sshfsp1="sshfs -o follow_symlinks -p 10001 joppe@joppekoers.nl: $HOME/server1/"

alias leak="valgrind --leak-check=full --show-leak-kinds=definite,indirect,possible --track-origins=yes"

alias notes="code $HOME/git/notes"
alias dc="docker compose"

# quick navigator: https://github.com/agkozak/zsh-z
alias z='zshz 2>&1'

# GIT aliases
alias gf='git fetch --all --prune'
alias gch='git checkout'
alias gcm='git commit -m'
function gam {
	log_and_run "git --no-pager diff --stat HEAD -- $@"
	log_and_run "git add $@ && git commit --amend --no-edit"
}
function copygit {
	log_and_run find "$1" -mindepth 1 -maxdepth 1 -not -name .git -exec cp -rf {} $2 \;
}
function ghrename {
	if [ $# -ne 1 ]; then
		echo "Renames local branch and push to remote"
		echo "Usage: ghrename <new_branch_name>"
		return 1
	fi
	oldbranch=$(git rev-parse --abbrev-ref HEAD)

	git branch -m $1					# Rename branch locally
	git push origin :$oldbranch			# Delete the old branch
	git push --set-upstream origin $1	# Push the new branch, set local branch to track the new remote
}

# VSCode aliases
alias c="code"
function cz {
	log_and_run code $(z -e "$1")
}

alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
# alias netstat="netstat -tulpn | grep :"

function drop {
	log_and_run curl -X POST -F "upfile=@$1" https://joppekoers.nl/drop/upload -F "identifier=$2";
}

function droplocal {
	log_and_run curl -X POST -F "upfile=@$1" http://localhost:8080/drop/upload -F "identifier=$2";
}

function mkcd {
	log_and_run mkdir "$1" && cd "$1";
}

function profile {
	TMP=$(mktemp -d)
	valgrind -q --tool=callgrind --callgrind-out-file=$TMP/callgrind.out $@
	gprof2dot --format=callgrind --output=$TMP/out.dot $TMP/callgrind.out
	dot -Gdpi=400 -Tpng $TMP/out.dot -o profile.png
	dot -Tsvg $TMP/out.dot -o profile.svg
	rm -f $TMP/out.dot
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

function drs {
	log_and_run "docker stop $1; docker start $1; docker logs -f -n 10000 $1"
}

function dps {
	log_and_run 'docker container list --no-trunc --format "table {{.Names}}\\t{{.Status}}\\t{{.Command}}\\t{{.Ports}}"'
}

# batcat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
if [ "$(uname -s)" = "Linux" ]; then
	export BAT_PAGER="less -RF"
fi

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

# Bun
source_if_exists "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
add_path "$BUN_INSTALL/bin"

# Volta
export VOLTA_HOME="$HOME/.volta"
add_path "$VOLTA_HOME/bin"

# pnpm
if [ "$(uname -s)" = "Linux" ]; then
	export PNPM_HOME="$HOME/.pnpm-global"
else
	export PNPM_HOME="$HOME/Library/pnpm"
fi
add_path "$PNPM_HOME"

# De duplicating paths inside $PATH https://www.linuxjournal.com/content/removing-duplicate-path-entries
export PATH=$(echo $PATH | awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print $0}' | sed 's/:$//')
