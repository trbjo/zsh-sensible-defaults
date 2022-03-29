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
# - - - - - - - SETOPTS - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - -

setopt no_case_glob             # Make globbing case insensitive.
setopt extendedglob             # Use Extended Globbing.
setopt autocd                   # Automatically Change Directory If A Directory Is Entered.
LISTMAX=999                     # Disable 'do you wish to see all %d possibilities'

# Completion Options.
setopt complete_in_word         # Complete From Both Ends Of A Word.
setopt always_to_end            # Move Cursor To The End Of A Completed Word.
setopt path_dirs                # Perform Path Search Even On Command Names With Slashes.
setopt auto_menu                # Show Completion Menu On A Successive Tab Press.
setopt auto_list                # Automatically List Choices On Ambiguous Completion.
setopt auto_param_slash         # If Completed Parameter Is A Directory, Add A Trailing Slash.
setopt no_complete_aliases

setopt auto_resume              # Attempt To Resume Existing Job Before Creating A New Process.
setopt no_beep                  # Don't beep
setopt no_bg_nice               # Don't frob with nicelevels
setopt no_flow_control          # Disable ^S, ^Q, ^\ #
stty -ixon quit undef > /dev/null 2>&1           # For Vim etc; above is just for zsh.


# Delete key
bindkey '^[[3~' delete-char
# Shift+Tab
bindkey "^[[Z" reverse-menu-complete

# Use smart URL pasting and escaping.
autoload -Uz bracketed-paste-url-magic url-quote-magic
zle -N bracketed-paste bracketed-paste-url-magic
zle -N self-insert url-quote-magic
(( ${+ZSH_AUTOSUGGEST_CLEAR_WIDGETS} )) && ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=('bracketed-paste-url-magic' 'url-quote-magic')

#
# TERMINAL CAPABILITES
#

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


autoload -Uz up-line-or-beginning-search down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A'  up-line-or-beginning-search    # Arrow up
bindkey '^[OA'  up-line-or-beginning-search
bindkey '^[[B'  down-line-or-beginning-search  # Arrow down
bindkey '^[OB'  down-line-or-beginning-search

# allows moving (renaming) files with regexes.
# E.g: zmv '(**/)(*).jsx' '$1$2.tsx'
autoload zmv
alias zmv='noglob zmv -w'

