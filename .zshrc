export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
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

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd/mm/yyyy"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
  export VISUAL='nano'
else
  export EDITOR='nano'
  export VISUAL='nano'
fi

# alias

unalias -a

if [ "$(uname -s)" = "Linux" ]; then
  alias ls="ls --color=auto"
else
  alias ls="ls -G"
fi
alias rcp="rsync -ah --info=progress2"
alias l="ls -Ahok"

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export PATH="$PATH:$HOME/.local/bin"

# export PATH="/usr/share/swift/5.3.2/usr/bin:$PATH"

export ANDROID_HOME=$HOME/.Android/Sdk
# export PATH=$PATH:$ANDROID_HOME/emulator
# export PATH=$PATH:$ANDROID_HOME/tools
# export PATH=$PATH:$ANDROID_HOME/tools/bin
# export PATH=$PATH:$ANDROID_HOME/platform-tools
# export REACT_EDITOR=vscode

if [ "$(uname -s)" = "Darwin" ]; then
  export PATH=$PATH:$HOME/.brew/bin
fi

# Only ignore duplicate terminal commands, save the ones prefixed with whitespace
export HISTCONTROL=ignoredups


# function preexec() {
#   timer=$(($(date +%s%0N)/1000000))
# }

# function precmd() {
#   if [ $timer ]; then
#     now=$(($(date +%s%0N)/1000000))
#     elapsed=$(($now-$timer))

#     export RPROMPT="%F{cyan}${elapsed}ms %{$reset_color%}"
#     unset timer
#   fi
# }

# allow * matcing in terminal
setopt no_bare_glob_qual

# disable rm * conformation
setopt rmstarsilent

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [ -f /etc/zsh.cnf ]; then
 . /etc/zsh.cnf
fi
