# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Google Cloud SDK
# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then . "$HOME/google-cloud-sdk/path.bash.inc"; fi
# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then . "$HOME/google-cloud-sdk/completion.bash.inc"; fi

# AWS cli
complete -C '/usr/local/bin/aws_completer' aws

# AWSume
if command -v ~/.local/bin/awsume >/dev/null 2>&1; then
    # https://awsu.me/general/quickstart.html#alias-setup
    alias awsume=". awsume"
    # https://awsu.me/utilities/awsume-configure.html#autocomplete-script
    _awsume() {
        local cur prev opts
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD - 1]}"
        opts=$(awsume-autocomplete)
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        return 0
    }
    complete -F _awsume awsume
fi

# browser
export BROWSER="wslview"

# direnv
export EDITOR=vim
eval "$(direnv hook bash)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# tfenv
export PATH=$PATH:$HOME/.tfenv/bin

# terraform
if type terraform &>/dev/null; then
    complete -C terraform terraform
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# npm
eval "$(npm completion)"

# yarn
if [[ -e /usr/bin/yarn ]]; then
    export PATH=$PATH:$HOME/.yarn/bin
fi

# Snowflake SnowSQL
export PATH=$PATH:$HOME/bin

# go
export PATH=$PATH:/usr/local/go/bin

# kubectl
# https://kubernetes.io/ja/docs/tasks/tools/install-kubectl-linux/#kubectl%E3%81%AE%E8%87%AA%E5%8B%95%E8%A3%9C%E5%AE%8C%E3%82%92%E6%9C%89%E5%8A%B9%E3%81%AB%E3%81%99%E3%82%8B
if [[ -e kubectl ]]; then
    source <(kubectl completion bash)
fi

# eksctl
# https://eksctl.io/installation/#shell-completion
if [[ -e /usr/local/bin/eksctl ]]; then
    source <(eksctl completion bash)
fi

# minikube
# https://minikube.sigs.k8s.io/docs/commands/completion/
# if [[ -e /usr/local/bin/minikube ]]; then
#     alias kubectl="minikube kubectl --"
#     source <(minikube completion bash) # for bash users
# fi

# helm
# https://helm.sh/docs/helm/helm_completion_bash/
if [[ -e /usr/local/bin/helm ]]; then
    source <(helm completion bash)
fi

# sqlcmd, bcp
# https://learn.microsoft.com/ja-jp/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver16&tabs=ubuntu-install#ubuntu
export PATH="$PATH:/opt/mssql-tools18/bin"

# uv
# https://docs.astral.sh/uv/getting-started/installation/#shell-autocompletion
if [[ -e ~/.local/bin/uv ]]; then
    eval "$(~/.local/bin/uv generate-shell-completion bash)"
fi

# aqua
# https://aquaproj.github.io/docs/products/aqua-installer#shell-script
# if [[ -e ~/.local/share/aquaproj-aqua/bin/aqua ]]; then
#     export PATH=${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH
#     export AQUA_PROGRESS_BAR=true
#     export AQUA_GLOBAL_CONFIG=$HOME/dotfiles/aqua/aqua.yaml
# fi
