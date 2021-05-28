#!/bin/bash

# shell
alias c='clear &&'
alias dirs='dirs -v' # use with cd ~#, pushd, & popd (https://unix.stackexchange.com/a/270437)

__b() { # bookmarks
  local selected="cd "$(cat ~/.bash_eternal_history | grep --text '^cd /' | egrep -v '\.\.|/tmp' | awk '{print $2}' | sort | uniq | fzf --exact)
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

bind -m vi-insert -x '"\eb": "__b"' 2>/dev/null

# clipboard
alias ci='xclip -i -selection clipboard'
alias co='xclip -o -selection clipboard'
alias cpath='pwd | ci'

# docs
alias emit-html='docker run --rm --volume "`pwd`:/data" --user `id -u`:`id -g` pandoc/core'
alias view-html='chromium-browser --new-window "data:text/html;base64,$(base64 -w 0 <&0)"' # todo use a temp file

# io
alias beep='speaker-test -t sine -f 600 -p 100 -l 1'

# make
alias make-ls='cat Makefile | sed -n -E "/^[^.#\ ]+:.*/{p}"' # usage: make-ls | column -t
alias make-ls-phony='cat Makefile | sed -n "/^.PHONY:/{n;p}"'

# rg
alias rg-h='rg --help --color always | less -r'


