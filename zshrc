# -*- sh -*-

# Load the SDK-specific settings in the interactive shells.
if [ -f ~/.sdk.env ]; then
    . ~/.sdk.env
fi

# If fish is available and we're not explicitly avoiding it...
if (( $+commands[fish] )) && [ -z "$NOFISH" ]; then
    # ...use it instead of zsh. A login variant if appropriate.
    if [[ -o login ]]; then
        exec fish -l
    else
        exec fish
    fi

    # We're execing from zsh to let a POSIX-like shell (zsh) perform
    # all the necessary environmental business.  That being said, we
    # don't need the rest of zshrc, only zshenv was interesting, so
    # let's exec as soon as possible
else
    unset NOFISH
fi

# Non-interactive session, do not load the rest.
[ -z "$PS1" ] && return

unsetopt beep
bindkey -e

zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
autoload -U colors && colors
compinit
# End of lines added by compinstall

if [ -z "$LESSOPEN" ]; then
    if (( $+commands[lesspipe.sh] )); then
        eval `lesspipe.sh`
    elif (( $+commands[lesspipe] )); then
        eval `lesspipe`
    fi
fi

autoload zmv zed
autoload -U insert-files && zle -N insert-files && bindkey '^X^F' insert-files

autoload run-help
HELPDIR=$HOME/.zsh-help
alias run-help=' run-help'

HISTFILE=~/.zhistory
DEF_HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000
FPATH=$HOME/.fpath:$FPATH

WORDCHARS='*?_-.[]~!#$%(){}<>'

TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\n\ncpu\t%P\ntotal\t%*E'
REPORTTIME=10

OPTIONS=(
    hist_ignore_all_dups
    hist_ignore_space
    hist_reduce_blanks
    append_history
    share_history
    inc_append_history
    hist_no_functions
    extended_history
    hist_no_store
    interactivecomments
    auto_cd
    rc_quotes

    extended_glob
    magicequalsubst
    longlistjobs

    prompt_subst

    local_options
)
setopt $OPTIONS
unset OPTIONS


PLUGINS_DIR=~/.zplugins
PLUGINS=(
    zcolors
    zle-config
    zaliases
    zcompletion
    zscripts
    zpriv
    zXephyr
    filehandlers
    urxvt_cwd-spawn
    term-title
    perl-edit
    fasd
    scratchdir
    my-fixes
    zcapture
    ignore
    localhistory
    ztodo
    fzf
    zgen
    texas
    )
if [ -f ~/.zloader ]; then
    . ~/.zloader
fi

# Do not enable a complex prompt on a basic terminal.
if ! [ $TERM = "vt100" -o $TERM = "dumb" -o $TERM = "linux" ]; then
    . ~/.zprompt
fi

if [ $TERM = "eterm-color" -o -n "$MC_TMPDIR" ]; then
    unset HISTFILE
    fc -R $DEF_HISTFILE

    eval "$(dircolors -b)"
    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

    RPS1=""
fi

if [ -n "$CLEARONSTART" ]; then
    clear
    unset CLEARONSTART
fi
