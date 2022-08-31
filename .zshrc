export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

export UPDATE_ZSH_DAYS=30

DISABLE_UNTRACKED_FILES_DIRTY="true"

# set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd/mm/yyyy"

# ZSH_TMUX_AUTOSTART=true
plugins=(zsh-autosuggestions docker docker-compose tmux)

if [ "$(uname -s)" = "Darwin" ]; then
  export PATH=/opt/homebrew/bin:$PATH
fi

# if codam mac
if [[ $(hostname) == *".codam.nl"* ]] && [[ $(whoami) == "jkoers" ]]; then
  export PATH="$PATH:$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  export PATH=$PATH:$HOME/.brew/bin

  mkdir -p /sgoinfre/jkoers
  chown jkoers /sgoinfre/jkoers

  # save docker images on goinfre
  mkdir -p $HOME/goinfre/Library/Containers/com.docker.docker
  rm -rf $HOME/Library/Containers/com.docker.docker
  ln -s $HOME/goinfre/Library/Containers/com.docker.docker $HOME/Library/Containers/com.docker.docker
fi

source $ZSH/oh-my-zsh.sh

# PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )" # default
PROMPT='%{$fg[green]%}%n@%m%}%{$fg[white]%}:%{$fg_bold[cyan]%}'
PROMPT+='%{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)
%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$reset_color%}' # MAYBE use $ insead of ➜

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
  export VISUAL='nano'
else
  export EDITOR='nano'
  export VISUAL='nano'
fi

unalias -a

if [ "$(uname -s)" = "Linux" ]; then
  alias ls="ls --color=auto"
else
  alias ls="ls -G"
fi
alias rcp="rsync -ah --info=progress2"
alias l="ls -Ahlk"

alias sshfs1="sshfs -o follow_symlinks joppe@192.168.2.1: $HOME/server1/"
alias sshfsp1="sshfs -o follow_symlinks -p 10001 joppe@joppekoers.nl: $HOME/server1/"

alias ope="xdg-open"
alias leak="valgrind --leak-check=full --show-leak-kinds=definite,indirect,possible --track-origins=yes"
alias clip="xclip -selection c"
alias notes="code $HOME/GitHub/notes"

# alias netstat="netstat -tulpn | grep :"

function drop { curl -X POST -F "upfile=@$1" https://joppekoers.nl/drop/upload -F "identifier=$2"; }
export drop

function droplocal { curl -X POST -F "upfile=@$1" http://localhost:8080/drop/upload -F "identifier=$2"; }
export droplocal

function mkcd { mkdir "$1" && cd "$1"; }
export mkcd

function profile {
	TMP=$(mktemp -d)
	valgrind -q --tool=callgrind --callgrind-out-file=$TMP/callgrind.out $@
	gprof2dot --format=callgrind --output=$TMP/out.dot $TMP/callgrind.out
	dot -Gdpi=400 -Tpng $TMP/out.dot -o profile.png
	dot -Tsvg $TMP/out.dot -o profile.svg
	rm -f $TMP/out.dot
}

function copyGit {
  find "$1" -mindepth 1 -maxdepth 1 -not -name .git -exec cp -rf {} $2 \;
}

# batcat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
if [ "$(uname -s)" = "Linux" ]; then
  export BAT_PAGER="less -RF"
fi

export PATH="$PATH:$HOME/.local/bin"

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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [ -f /etc/zsh.cnf ]; then
 . /etc/zsh.cnf
fi

# bun completions
[ -s "/Users/joppe/.bun/_bun" ] && source "/Users/joppe/.bun/_bun"

# Bun
export BUN_INSTALL="/Users/joppe/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
