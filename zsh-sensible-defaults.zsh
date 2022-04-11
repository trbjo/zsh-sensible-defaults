# - - - - - - - - - - - - - - - - - - - -
# - - - - - - - COMPLETION- - - - - - - -
# - - - - - - - - - - - - - - - - - - - -

autoload -Uz compinit

# Load And Initialize The Completion System Ignoring Insecure Directories With A
# Cache Time Of 20 Hours, So It Should Almost Always Regenerate The First Time A
# Shell Is Opened Each Day.
# See: https://gist.github.com/ctechols/ca1035271ad134841284
local _comp_files=(${ZDOTDIR:-$HOME}/.zcompdump(Nm-20))
if (( $#_comp_files )); then
    compinit -i -C
else
    compinit -i
fi

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' format '%B%F{white}=== %d ===%f%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'm:{a-zA-Z}={A-Za-z} r:|=*' 'm:{a-zA-Z}={A-Za-z} l:|=*'
# zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'

# Fuzzy match mistyped completions.
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'expand'
zstyle ':completion:*' squeeze-slashes true

# Enable caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${ZDOTDIR:-${HOME}}/.zcompcache"

# Ignore useless commands and functions
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec)|prompt_*)'

# Completion sorting
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'


# Kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

zstyle -e ':completion:*:*:scp:*:my-accounts' users-hosts \
'[[ -f ${HOME}/.ssh/config && ${key} == hosts ]] && key=my_hosts reply=()'
# If the _my_hosts function is defined, it will be called to add the ssh hosts
# completion, otherwise _ssh_hosts will fall through and read the ~/.ssh/config
zstyle -e ':completion:*:*:ssh:*:my-accounts' users-hosts \
'[[ -f ${HOME}/.ssh/config && ${key} == hosts ]] && key=my_hosts reply=()'

# - - - - - - - - - - - - - - - - - - - -
# - - - - - - KEY BINDINGS- - - - - - - -
# - - - - - - - - - - - - - - - - - - - -

# Delete key
bindkey '^[[3~' delete-char
# Shift+Tab
bindkey "^[[Z" reverse-menu-complete

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A'  up-line-or-beginning-search    # Arrow up
bindkey '^[OA'  up-line-or-beginning-search
bindkey '^[[B'  down-line-or-beginning-search  # Arrow down
bindkey '^[OB'  down-line-or-beginning-search

# - - - - - - - - - - - - - - - - - - - -
# - - - - - - URL HANDLING- - - - - - - -
# - - - - - - - - - - - - - - - - - - - -

autoload -Uz bracketed-paste-url-magic url-quote-magic
zle -N bracketed-paste bracketed-paste-url-magic
zle -N self-insert url-quote-magic

# A bit tedious, but this hack is necessary if we want to make sure
# bracketed-paste-url-magic and url-quote-magic is added to ZSH_AUTOSUGGEST_CLEAR_WIDGETS,
# irrespective of the order with which we load these plugins

__add_url_magic_to_zsh_autosuggest_clear_widgets() {
    (( ${+ZSH_AUTOSUGGEST_CLEAR_WIDGETS} )) && {
        ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=("bracketed-paste-url-magic" "url-quote-magic")
        add-zsh-hook -d precmd __add_url_magic_to_zsh_autosuggest_clear_widgets
        add-zsh-hook -d preexec __remove_url_magic
        unfunction __add_url_magic_to_zsh_autosuggest_clear_widgets
        unfunction __remove_url_magic
    }
}

__remove_url_magic() {
    add-zsh-hook -d precmd __add_url_magic_to_zsh_autosuggest_clear_widgets
    add-zsh-hook -d preexec __remove_url_magic
    unfunction __add_url_magic_to_zsh_autosuggest_clear_widgets
    unfunction __remove_url_magic
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd __add_url_magic_to_zsh_autosuggest_clear_widgets
add-zsh-hook preexec __remove_url_magic

# - - - - - - - - - - - - - - - - - - - -
# - - - - -TERMINAL CAPABILITIES- - - - -
# - - - - - - - - - - - - - - - - - - - -

export LESS_TERMCAP_md=$'\E[1;34m'    # Begins bold, blue.
export LESS_TERMCAP_me=$'\E[0m'       # Ends bold, blue.
export LESS_TERMCAP_us=$'\E[1;36m'  # Begins bold, cyan
export LESS_TERMCAP_ue=$'\E[0m'       # Ends bold, cyan

if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    # Enable application mode when zle is active
    start-application-mode() { echoti smkx }
    stop-application-mode() { echoti rmkx }

    autoload -Uz add-zle-hook-widget && \
    add-zle-hook-widget -Uz line-init start-application-mode && \
    add-zle-hook-widget -Uz line-finish stop-application-mode
fi

#-F quit if one screen
# -i ignore case
# -R raw
# -w highlight unread part of page after scroll
# -z-10 scroll 10 lines less than page height
# --incsearch incremental search
export LESS="--raw-control-chars \
--quit-if-one-screen \
--ignore-case \
--hilite-unread \
-z-10 \
--tilde"

# old versions of less do not have incsearc
[[ -z ${SSH_TTY} ]] && LESS+=" --incsearch"

export PAGER=less
export SYSTEMD_LESS="FRSMK"
export GREP_COLOR='1;38;5;20;48;5;16'

# allows moving (renaming) files with regexes.
# E.g: zmv '(**/)(*).jsx' '$1$2.tsx'
autoload zmv
alias zmv='noglob zmv -w'

# - - - - - - - - - - - - - - - - - - - -
# - - - - - - - ALIASES - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - -

if type rg > /dev/null 2>&1; then
    export RIPGREP_OPTS='\
    --context-separator ... \
    --smart-case\
    --colors match:bg:6\
    --colors match:fg:226\
    --colors line:fg:249\
    --colors line:style:nobold\
    --colors path:fg:4\
    --no-messages\
    --max-columns=$(( COLUMNS - 28 )) \
    --max-columns-preview'
    # grep for ipv4 addresses
    ipv4addrs() { rg --pcre2 $RIPGREP_OPTS '\b(?<!\.)(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(?!\.)\b' }

    alias rgg="noglob rg $RIPGREP_OPTS --no-ignore-vcs --hidden --glob "!clipman.json" --glob "!.zhistory""
    alias rg="noglob rg $RIPGREP_OPTS --glob "!clipman.json" --glob "!.zhistory""
    alias -g G=" |& rg $RIPGREP_OPTS"
else
    alias -g G=' |& grep --color=auto'
fi

alias df='df -h'
alias grep='grep --color=auto'

# Pipe stdout directly to less with LL
alias -g LL=' |& less'

if type pacman > /dev/null 2>&1; then
    alias Syu='doas pacman -Syu'
    alias U='doas pacman -U'
    alias Sy='doas pacman -Sy'
    alias S='doas pacman -S'
    alias Ss='yay -Ss'
    alias Rsn='doas pacman -Rsn'
    alias Rns='doas pacman -Rsn'
    alias Rdd='doas pacman -Rdd'
    alias Qs='pacman -Qs'
    # list packages owned by
    alias Qo='pacman -Qo'
    alias Qqs='pacman -Qqs'
    alias Qq='pacman -Qq'

    alias Qtdq='doas pacman -Rsn $(pacman -Qtdq)'
    zstyle ':completion::complete:pacman:*' file-patterns '
      *.pkg.tar.zst:source-files:"Pacman archive"
      *(D-/):local-directories:"local directory"
    '
    zstyle ':completion:*:(pacman):*' ignore-line other

fi

alias l='ls -1A'         # Lists in one column, hidden files.
alias ll='ls -lh'        # Lists human readable sizes.
alias lr='ll -R'         # Lists human readable sizes, recursively.
alias la='ll -A'         # Lists human readable sizes, hidden files.
alias lm='la | "$PAGER"' # Lists human readable sizes, hidden files through pager.
alias lk='ll -Sr'        # Lists sorted by size, largest last.
alias lt='ll -tr'        # Lists sorted by date, most recent last.
alias lc='lt -c'         # Lists sorted by date, most recent last, shows change time.
alias lu='lt -u'         # Lists sorted by date, most recent last, shows access time.
alias sl='ls'            # Correction for common spelling error.

if type exa > /dev/null 2>&1; then
    alias e='exa --group-directories-first'
    alias es='exa --sort=oldest --long --git'
    alias ee='exa --group-directories-first --long --git'
    alias ea='exa --group-directories-first --long --git --all'
else
    alias e='ls --color=auto --group-directories-first'
    alias es='ls --color=auto -lt --human-readable'
    alias ee='ls --color=auto --no-group --group-directories-first -l --human-readable'
    alias ea='ls --color=auto --group-directories-first --all --human-readable'
fi

# strips the dollar sign when pasting from the internet
alias \$=''

# Git aliases
alias glo="git log --pretty=format:'%Cred%h %Cgreen%cr %C(blue)%an%Creset%Creset ●%d%Creset %s' --abbrev-commit"
alias gs='git status --porcelain --short'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gb='git branch'
alias gd='git diff'
alias ga='git add'
alias gap='git add -p'
alias gl='git log'
alias gcam='git commit -am'
alias gcm='git commit -m'
alias gpull='git pull --rebase'
alias gpush='git push'
alias gdn='git diff --name-only'
alias push='git push'
alias pull='git pull --rebase'

# Easy redirect
alias -g silent="> /dev/null 2>&1"
alias -g noerr="2> /dev/null"
alias -g onerr="1> /dev/null"
alias -g stdboth="2>&1"
