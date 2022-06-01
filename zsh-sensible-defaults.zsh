# - - - - - - - - - - - - - - - - - - - -
# - - - - - - - -COLORS - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - -


export LS_COLORS="*.json=35:*.JSON=35:*.pdf=31:*.PDF=31:*.djvu=31:*.DJVU=31:*.epub=31:*.EPUB=31:*.zip=33:*.ZIP=33:*.xz=33:*.XZ=33:*.gz=38;5;215:*.zst=38;5;215:*.tz=38;5;215:*.sublime-package=33:*.jpg=34:*.JPG=34:*.jpeg=34:*.JPEG=34:*.png=34:*.PNG=34:*.webp=34:*.WEBP=34:*.svg=34:*.SVG=34:*.gif=34:*.GIF=34:*.bmp=34:*.BMP=34:*.tif=34:*.TIF=34:*.tiff=34:*.TIFF=34:*.psd=34:*.PSD=34:*.mkv=35:*.mp4=35:*.mov=35:*.mp3=35:*.avi=35:*.mpg=35:*.m4v=35:*.oga=35:*.MKV=35:*.MP4=35:*.MOV=35:*.MP3=35:*.AVI=35:*.MPG=35:*.M4V=35:*.OGA=35:*.doc=36:*.docx=36:*.odt=36:*.ods=36:*.xlsx=36:*.xls=36:*.DOC=36:*.DOCX=36:*.ODT=36:*.ODS=36:*.XLSX=36:*.XLS=36:*.html=38;5;208:*.HTML=38;5;208:*.log=38;5;18:*.pyc=38;5;18:*.LOG=38;5;18:*.zwc=38;5;18:*.md=33;01:*.MD=33;01:bd=35;1:ex=48;5;153:cd=35;1:di=36:ln=0;36;1:*.sublime-keymap=48;5;154;38;5;208:*.sublime-settings=48;5;154;38;5;208:*.sublime-project=48;5;154;38;5;208:*.sublime-color-scheme=48;5;154;38;5;208:*.sublime-commands=48;5;154;38;5;208:*.sublime-mousemap=48;5;154;38;5;208:*.sublime-syntax=48;5;154;38;5;208:*.sublime-build=48;5;154;38;5;208:*.py=32"

autoload -U colors && colors

zle_highlight=(region:bg=153,fg=7 special:bg=153
               suffix:bg=153 paste:bg=153 isearch:bg=153)

_raw_to_zsh_color() {
    if [[ $1 =~ "^38;5;.+$" ]]; then
        print -n "%F{${1##*;}}"
        return
    fi
    if [[ $1 =~ "^48;5;.+$" ]]; then
        print -n "%B{${PART##*;}}"
        return
    fi
    local -a parts=( ${(s[;])1} )
    local val=""
    for part in $parts; do
        if [[ ${#part} -eq 1 ]]; then
            val+="%B"
        else
            if [[ "${part:0:1}" == "3" ]]; then
                val+="%F{${part:1:2}}"
            elif [[ "${part:0:1}" == "4" ]]; then
                val+="%K{${part:1:2}}"
            fi
        fi
    done
    print -n $val
}

() {
    typeset -agU _ls_colors_array
    _ls_colors_array=("${(@s/:/)LS_COLORS}")

    local -a a
    typeset -gA _ls_colors_dict
    local elem elem_no_asterisk
    for elem in ${_ls_colors_array:l}; do

        if [[ "${elem:0:2}" != '*.' ]]; then
            if [[ "${elem:0:2}" == "di" ]]; then
                _di_color_raw="${elem[4,-1]}"
            elif [[ "${elem:0:2}" == "ex" ]]; then
                _ex_color_raw="${elem[4,-1]}"
            elif [[ "${elem:0:2}" == "bd" ]]; then
                _bd_color_raw="${elem[4,-1]}"
            elif [[ "${elem:0:2}" == "ln" ]]; then
                _ln_color_raw="${elem[4,-1]}"
            elif [[ "${elem:0:2}" == "cd" ]]; then
                _cd_color_raw="${elem[4,-1]}"
            fi
        else
            elem_no_asterisk=${elem:2}
            a=("${(@s/=/)elem_no_asterisk}")

            if [[ -n ${a[1]} ]]; then
                _ls_colors_dict[${a[1]}]=${a[2]}
            fi
        fi
    done
}

_colorizer_abs_path() {
    local this_dir="${${1}/$HOME/\~}"
    _colorizer $1
}

_colorizer() {
    (( ${#@} > 1 )) && print "\x1b[31;1m_colorizer: MORE THAN ONE INPUT ARG\x1b[39m" && return 42
    local file=${(QQQ)1}

    [[ -z $this_dir ]] && local this_dir="${${${1}/$PWD\//}/$HOME/\~}"
    local leading_slash=''
    if [[ "${this_dir:0:1}" == '/' ]] && [[ ${#this_dir} -gt 1 ]]; then
        leading_slash='/'
    fi

    local -a dir_parts=( ${(s[/])this_dir} )
    local tmp_dir=''
    local _file_and_color

    for part in ${dir_parts[0,-2]}; do
        tmp_dir+="\033[${_di_color_raw}m${part}\033[39m/"
    done

    if [[ -f "$file" ]]; then
        if [[ -x "$file" ]]; then
            _file_and_color="\x1b[${_ex_color_raw}m${dir_parts[-1]}\x1b[39m"
        else
            local _file_color=${_ls_colors_dict[${1:e:l}]}
            _file_and_color="\x1b[${_file_color:-39}m${dir_parts[-1]}"
        fi
    elif [[ -d "$file" ]]; then
        _file_and_color="\x1b[${_di_color_raw}m${dir_parts[-1]}\x1b[39m/"
    elif [[ -h "$file" ]]; then
        _file_and_color="\x1b[${_ln_color_raw}m${dir_parts[-1]}\x1b[39m/"
    elif [[ -c "$file" ]]; then
        _file_and_color="\x1b[${_cd_color_raw}m${dir_parts[-1]}\x1b[39m/"
    elif [[ -b "$file" ]]; then
        _file_and_color="\x1b[${_bd_color_raw}m${dir_parts[-1]}\x1b[39m/"
    elif [[ ! -e "$file" ]]; then
        _file_and_color="\x1b[31;1m${dir_parts[-1]}\x1b[0m\x1b[39m"
    else
        _file_and_color="\x1b[31;1mUNKNOWN FILE TYPE\x1b[39m"
        return 42
    fi

    printf "${leading_slash}${tmp_dir}${_file_and_color}\x1b[0m"
}

function _enum_exit_code() {
    (( ${#@} != 3 )) && print '$#@ != 3, quitting' && return 42
    local archive="${2}"
    local destination="${3}"
    case $1 in
        0) print -n "Extracted $(_colorizer ${archive}) -> $(_colorizer_abs_path ${destination:a})" ;;
        1) print -n "Destination folder exists, renaming: $(_colorizer ${archive}) -> $(_colorizer_abs_path ${destination:a})" ;;
        2) print -n "Destination file exists, renaming: $(_colorizer ${archive}) -> $(_colorizer_abs_path ${destination:a})" ;;
        3) print -n "Unknown error" ;;
        4) print -n "Wrong file type: $(_colorizer ${archive})" ;;
        42) print -n "Could not find $(_colorizer $archive)" ;;
        43) print -n "$(_colorizer ${destination:a}) already exists" ;;
        44) print -n "Permission denied to write to dir: $(_colorizer_abs_path ${destination:a})" ;;
        45) print -n "Destination is a file: $(_colorizer_abs_path ${destination:a})" ;;
        46) print -n "Wrong number of input args given" ;;
        47) print -n "No archive given" ;;
        48) print -n "No destination given" ;;
    esac
}

# - - - - - - - - - - - - - - - - - - - -
# - - - - - BYTE COMPILING- - - - - - - -
# - - - - - - - - - - - - - - - - - - - -

compile_or_recompile() {
    local plugin="$1"
    set --
    { [[ -f "${plugin}" ]] && [[ ! -f "${plugin}.zwc" ]] }\
    || [[ "${plugin}" -nt "${plugin}.zwc" ]] &&\
    zcompile "${plugin}"
}

compile_or_recompile "${ZDOTDIR:-$HOME}/.zcompdump" &!
compile_or_recompile "${ZDOTDIR:-$HOME}/.zshrc" &!

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
# zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'
# zstyle ':completion:*' matcher-list 'l:|=* r:|=* m:{a-zA-Z}={A-Za-z}' 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' matcher-list '' 'r:[[:ascii:]]||[[:ascii:]]=** r:|=* m:{a-z\-}={A-Z\_}'

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
if type systemctl > /dev/null 2>&1; then
    export SYSTEMD_LESS="FRSMK"
    alias logs='journalctl -u'
fi

export GREP_COLOR='1;38;5;20;48;5;16'
(( ${+SSH_TTY} )) && export TERM="xterm-256color"

# allows moving (renaming) files with regexes.
# E.g: zmv '(**/)(*).jsx' '$1$2.tsx'
autoload zmv
alias zmv='noglob zmv -w'

# - - - - - - - - - - - - - - - - - - - -
# - - - - - - - ALIASES - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - -

# allows pasting from the internet
alias '#'=doas

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


# aliases for mac
if [[ "$(uname)" == "Darwin" ]]; then
    subl() {
        /Applications/Sublime\ Text.app/Contents/MacOS/sublime_text $@ &!
    }
fi
