export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

export UPDATE_ZSH_DAYS=30

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd/mm/yyyy"

# ZSH_TMUX_AUTOSTART=true

# add brew to PATH
if [ "$(uname -s)" = "Darwin" ]; then
  export PATH=/opt/homebrew/bin:$PATH
fi

if [[ $(hostname) == *".codam.nl"* ]] && [[ $(whoami) == "jkoers" ]]; then # if codam mac
  export PATH="$PATH:$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  export PATH=$PATH:$HOME/.brew/bin
fi

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(zsh-autosuggestions tmux)

source $ZSH/oh-my-zsh.sh

export PROMPT='%{$fg[green]%}%m%}%{$fg_bold[cyan]%} ➜ %c $(git_prompt_info)%{$reset_color%}'
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

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

alias ssh1="ssh joppe@192.168.2.1"
alias sshp1="ssh -p 10001 joppe@joppekoers.nl"
alias sshfs1="sshfs -o follow_symlinks joppe@192.168.2.1: $HOME/server1/"
alias sshfsp1="sshfs -o follow_symlinks -p 10001 joppe@joppekoers.nl: $HOME/server1/"

alias ope="xdg-open"
alias leak="valgrind --leak-check=full --show-leak-kinds=definite,indirect,possible --track-origins=yes"
alias clip="xclip -selection c"

# alias netstat="netstat -tulpn | grep :"

function drop { curl -X POST -F "upfile=@$1" https://joppekoers.nl/drop/upload -F "identifier=$2"; }
export drop

function droplocal { curl -X POST -F "upfile=@$1" http://localhost:8080/drop/upload -F "identifier=$2"; }
export droplocal

function mkcd { mkdir "$1" && cd "$1"; }
export mkcd

function profile {
  valgrind -q --tool=callgrind --callgrind-out-file=/tmp/callgrind.out $@
  gprof2dot --format=callgrind --output=/tmp/out.dot /tmp/callgrind.out
  dot -Gdpi=400 -Tpng /tmp/out.dot -o profile.png
  rm -f /tmp/out.dot
}

function copyGit {
  find "$1" -mindepth 1 -maxdepth 1 -not -name .git -exec cp -rf {} $2 \;
}

# batcat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
if [ "$(uname -s)" = "Linux" ]; then
  export BAT_PAGER="less -RF"
fi

## PATH stuff
export PATH="$PATH:$HOME/.local/bin"
# export PATH="/usr/share/swift/5.3.2/usr/bin:$PATH"

# export ANDROID_HOME=$HOME/.Android/Sdk
# export PATH=$PATH:$ANDROID_HOME/emulator
# export PATH=$PATH:$ANDROID_HOME/tools
# export PATH=$PATH:$ANDROID_HOME/tools/bin
# export PATH=$PATH:$ANDROID_HOME/platform-tools
# export REACT_EDITOR=vscode

# OTHER

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
