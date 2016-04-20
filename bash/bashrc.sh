  #######################################################
  ##  filename: bashrc.sh                              ##
  ##  path:     ~/src/config/dotfiles/bash/            ##
  ##  symlink:  ~/.bashrc                              ##
  ##  purpose:  bash shell configuration               ##
  ##  date:     11/21/2015                             ##
  ##  repo:     https://github.com/WebAppNut/dotfiles  ##
  #######################################################

# vim: set fdm=marker:                      # treat triple braces as folds

vars() { # {{{
  # export CLICOLOR=1                           # always colorize ls output
  # export EDITOR=vim                           # use vim as default text editor
  export EDITOR=atom                           # use vim as default text editor
  export GIT_EDITOR=$EDITOR                   # use vim in as default git editor
  export GREP_OPTIONS='--color=auto'          # always colorize grep matches
  export HISTFILE=$HOME/.bash_hist            # command history filepath
  export HISTFILESIZE=5000                    # max commands stored in history
  export HISTSIZE=5000                        # max commands to save in a session
  export HISTTIMEFORMAT='%D %T '              # prefix timestamp on history list
  export HISTCONTROL=ignoreboth:erasedups     # ignore leading space & kill dups
  export HISTIGNORE="?:??:htop:vim"           # ignore commands; 1 & 2 character
  # export LSCOLORS=ExCxxxdxBxxxxdaxaxGxGh      # custom directory listing colors
  # export TERM=xterm-256color                  # enable 256 color support
  export VISUAL=$EDITOR                       # use vim in visudo & crontab
  export rs=$(tput sgr0)                      # text: reset attributes
  export blue=$(tput bold)$(tput setaf 33)    # text: bold & blue
  export red=$(tput bold)$(tput setaf 160)    # text: bold & red
  export yellow=$(tput bold)$(tput setaf 136) # text: bold & yellow
  export white=$(tput bold)$(tput setaf 7)    # text: bold & white
  # export gray=$(tput bold)$(tput setaf 250)   # text: bold & gray
  export gray=$(tput setaf 250)               # text: bold & gray
  export green=$(tput bold)$(tput setaf 64)   # text: bold & green
  # p_ply=$home/work/provision/playbook         # path: ansible assets
  # p_inv=$p_ply/inventory                      # path: ansible inventory
  # p_pbk=$p_ply/playbook.yml                   # path: ansible main playbook
  # p_vl=$p_ply/vars/vault_local.yml            # path: ansible vault_local.yml
  # p_vs=$p_ply/vars/vault_server.yml           # path: ansible vault_server.yml
  # c_ap="ansible-playbook -i $p_inv $p_pbk"    # command: playbook & options
  # c_ap2=--ask-vault-pass                      # command: playbook vault option
  cask_app=--appdir=/Applications             # path: symlinked cask apps
  export HOMEBREW_CASK_OPTS="$cask_app"       # brew cask install options
  p_brw=/usr/local/bin:/usr/local/sbin        # path: homebrew apps
  # p_cpr=$HOME/.composer/vendor/bin            # path: composer apps
  p_scr=$HOME/.bin                            # path: custom shell scripts
  # export PATH="$p_brw:$p_cpr:$p_scr:$PATH"    # append to $PATH statement
  export PATH="$p_brw:$p_scr:$PATH"           # append to $PATH statement
} # }}}
# greet() { # {{{
#   # purpose: display pre-rendered figlet output
#   clear
#   # do if column size is wide enough & line size if tall enough
#   if [ $(tput lines) -gt 16 ] && [ $(tput cols) -gt 70 ]; then
#
#   fi;
#   export -f greet                           # logo available to all scripts
# } # }}}
scratch() { # {{{
  # purpose: store & retrieve temporary notes
  # path to scratch file
  scratch_file=$HOME/src/scratch
  # create scratch file if not already exists
  [ -f $scratch_file ] || touch $scratch_file
  scratch_count() {
    # purpose: count scratch entries
    sc=$(wc -l < $scratch_file | tr -d ' ')
  }
  # do if show parameter passed
  if [ "$1" == "l" ]; then
    scratch_count
    echo -e "$yellow\n \bScratch Items: $sc $rs"
    echo -e "$yellow\n \b$(cat $scratch_file) $rs"
  # do if kill parameter passed
  elif [ "$1" == "rm" ]; then
    # clear scratch content; overide no clobber setting
    >| $scratch_file
    # do if edit parameter passed
  elif [ "$1" == "edit" ]; then
    # edit scratch file
    vim $scratch_file
  # do if push parameter passed
  # do if peak parameter passed
  # do if pop parameter passed
  elif [ "$1" == "d" ]; then
    if [ ! -z $2 ]; then
      # copy scratch entry with matching keyword to clipboard; strip bullet
      echo -n $(awk "/$2/ {gsub(\"- \", \"\"); print}" $scratch_file) | pbcopy
      # remove scratch entry with matching keyword
      sed -i '' "/$2/d" $scratch_file
    else
      # copy last entry to clipboard; strip bullet
      echo -n $(awk 'END{gsub("- ", ""); print}' $scratch_file) | pbcopy
      # remove last scratch entry
      sed -i '' '$d' $scratch_file
    fi
  # do if no parameter passed; refresh count; called by PROMPT_COMMAND
  elif [ -z $1 ]; then
    scratch_count
  elif [ ! -z $1 ]; then
    # clear temporary string
    unset tmp_string
    # loop through arguments
    for i in "$@"; do
      # append arguments to string
      tmp_string+="$i "
    done
    # append final string to scratch
    echo "- $tmp_string" >> $scratch_file
  fi
} # }}}
prompt() { # {{{
  # purpose: all prompt related variables & commands
  # run these commands before each PS1 prompt refresh
  PROMPT_COMMAND=' \
    # dynamic xterm title: ~/; \
    # echo -ne "\033]0;${PWD/${HOME}/~}\007"; # set in git-prompt-colors.sh; \
    # trim pwd path to last two directories; \
    [ $(tput cols) -lt 50 ] && PROMPT_DIRTRIM=2 || PROMPT_DIRTRIM=0; \
    # append session command history to global; rm session; read in global; \
    history -a; history -c; history -r; \
    # refresh scratch count; \
    scratch; \
    # add new line before prompt; \
    echo;'

  GIT_PROMPT_ONLY_IN_REPO=1                 # appends git repo info to PS1
  GIT_PROMPT_THEME=Custom                   # custom theme .git-prompt-colors.sh
  # GIT_PROMPT_FETCH_REMOTE_STATUS=0        # no fetch remote status
  # GIT_PROMPT_SHOW_UPSTREAM=1              # show upstream tracking branch

  # build out custom PS1 prompt
  PS1='\[\033]0;\w\007\]'                   # xterm title: pwd $HOME = short ~/
  # PS1+='\[$blue\]\w'                        # pwd $HOME = short ~/
  PS1+='\[$gray\]\w'                        # pwd $HOME = short ~/
  PS1+='\[$yellow\]'                        # set dynamic count text color
  PS1+='$([ $sc -gt 0 ] && echo \ ⁼$sc)'    # show scratch note count if > 0
  PS1+='$([ \j -gt 0 ] && echo \ *\j)'      # show background job count if > 0
  PS1+=' \[$red\]❯\[$yellow\]❯\[$green\]❯'  # multicolored unicode symbols
  PS1+='\[$rs\] '                           # reset color; space after prompt
} # }}}
alias_list() { # {{{
  # display loaded aliases
  # substitute alias column for "$" symbol; filter with optional [arg]
  alias | awk "/$1/ {\$1=\"$\"; print \$0}"
} # }}}
backup() { # {{{
  # purpose: make backup copy of directory or file w/ appended date
	if [ ! -z "$1" ]; then
    echo -e "$green\n \bcreating backup file... \n$rs"
    cp -a $1{,$(date +_%Y.%m.%d_%H.%M)}
    echo -e "$blue \bsuccess: \n$(ls -d -1 $1*) $rs"
  else
		echo -e "$red\n \busage: bak [path/to/file]"
    echo -e "example: $ bak ~/bud/build $rs"
  fi
} # }}}
history_remove() { # {{{
  # delete a range of contiguous lines from command history
  # arguments reversed because line numbers are dynamic
	if [ ! -z "$1" ]; then
    for line in $(seq $2 $1); do
      history -d $line
    done
  else
		echo -e "$red\n \busage: hd [line_start] [line_end]"
    echo -e "example: $ hd 405 409$rs"
  fi
} # }}}
history_search() { # {{{
  # search command history for matching term; multiple terms via [arg]
  # do if parameter was passed
	if [ ! -z "$1" ]; then
    if [ "$1" == "+" ]; then
      # multi-term OR search; case-insensitive
      # run in subshell; puts "|" between arguments for proper grep syntax
      cmd='(IFS="|$IFS"; history | grep -iwE "${*:2}")'
      cmd_c='(IFS="|$IFS"; history | grep -icwE "${*:2}")'
      echo -e "$yellow \b$ "$cmd": $rs"
      eval ${cmd}
      echo -e "$yellow \b**** found $(eval "${cmd_c}") lines matching one word or another ****"
    elif [ "$1" == "=" ]; then
      # multi-term AND search; case-insensitive
      # store supplied parameter count
      cnt=$#
      # decrease count
      ((cnt--))
      # store temporary command
      cmd="history |"
      # loop though arguments; start at $2
      for i in "${@:2}"; do
        # do if not last parameter
        if [ "$cnt" != "1" ]; then
          # build up grep commands; pipe stdout to stdin of next
          cmd+=" grep -iw '$i' |"
          # decrease count
          ((cnt--))
        # do if last parameter
        else
          # no more piping
          cmd+=" grep -iw '$i'"
        fi
      done
      echo -e "$yellow \b$ "$cmd": $rs"
      eval "${cmd}"
      cmd+=" -c"
      echo -e "$yellow \b**** found $(eval "${cmd}") lines matching all words ****"
    else
      # do if only one parameter passed
      if [ -z "$2" ]; then
        # grep single parameter for matching pattern; case-insensitive
        cmd="history | grep -i '$1'"
        echo -e "$yellow \b$ "$cmd": $rs"
        eval "${cmd}"
        cmd+=" -c"
        echo -e "$yellow \b**** found $(eval "${cmd}") lines with matching pattern ****"
      # do if additional paramters were passed
      else
        echo -e "$red\n \b **** unquoted spaces **** $rs"
        # display usage & examples
        echo "$(hs)"
      fi
    fi
  else
    echo -e "$yellow\n \busage: hs [pattern]"
    echo -e "$yellow \busage: hs [+/=] [word] ['more words with spaces']\n"
    echo -e "example: $ hs sed              # single pattern search"
    echo -e "example: $ hs 'sed -e'         # quote wrap pattern if spaces"
    echo -e "example: $ hs + sed echo       # multiterm:OR; space separated"
    echo -e "example: $ hs + 'sed -e' echo  # lines matching any"
    echo -e "example: $ hs = 'sed -e' echo  # multiterm:AND; lines matching all"
    echo -e "example: $ hs + win            # limit to word match, not pattern"
  fi
} # }}}
ls_octal() { # {{{
  # long list showing octal permissions & symbolic
  # ran against $PWD if no optional [arg]
  ls -AlhF "$@" | awk '{k = 0; for (g=2; g>=0; g--) for (p=2; p>=0; p--) {c = substr($1, 10 - (g * 3 + p), 1); if (c ~ /[sS]/) k += g * 02000; else if (c ~ /[tT]/) k += 01000; if (c ~ /[rwxts]/) k += 8^g * 2^p} if (k) printf("%04o ", k);print;}'
} # }}}
make_empty_file() { # {{{
  # purpose: create empty file containing all zeros
	if [ ! -z "$1" ]; then
    tmp=$1_$2b.tmp
    echo -e "$green\n \bcreating empty $1 $2b file... \n$rs"
    mkfile $1$2 $1_$2b.tmp
    echo -e "$blue \bcreated: $PWD/$tmp\n \bsize: $(du -h $tmp | awk '{ print $1 }') $rs"
  else
		echo -e "$red\n \busage: m0 [size] [b|k|m|g]"
    echo -e "example: $ m0 1 m"
  fi
} # }}}
notes_search() { # {{{
	# search term inside content of note file
	# usage: $ ns [note_name] [search_term] [trailing_line_num]
	# example: ns vim session 4

  # do if search term is blank
	if [ -z "$2" ]; then
		echo -e "$yellow\n \busage: [note_name] [search_term] [trailing_line_num] $rs"
    echo -e "$yellow\n \bexample: $ ns vim session 4 $rs"
  # do if number of trailing lines is blank; avoids invalid arg error
	elif [ -z "$3" ]; then
		grep -i "$2" -A0 ~/src/cheats/$1.txt
	else
		grep -i "$2" -A$3 ~/src/cheats/$1.txt
	fi
} # }}}
notes_print() { # {{{
	# copy contents of notes file and paste into temporary pages file processing
	if [ ! -z "$1" ]; then
    pbcopy < ~/work/notes/$1.txt | pbpaste | open -f -a pages
    echo -e "$yellow\n \b#### Printing Steps: #### \n"
    echo -e "1. Format | Font: Menlo, 9pt"
    echo -e "2. Document | Size: 5x7, landscape"
    echo -e "3. Document | Header/Footer: none"
    echo -e "4. Document | Margins: t/r/l=0.25 b=0.0"
    echo -e "5. Print odd pages"
    echo -e "6. Flip paper over & rotate 180º"
    echo -e "7. Print even pages"
    echo -e "8. Bind at top edge$rs"
  else
		echo -e "$red\n \busage: np [note_name]"
    echo -e "example: $ np vim $rs"
  fi
} # }}}
usb_clean() { # {{{
  # purpose: remove hidden files on usb drive for cleaner display on blu-ray/tv
  if [ ! -z $1 ]; then
    usb=/Volumes/$1
    rm -rf $usb/.{,_.}{_*,fseventsd,Spotlight-V*,Trashes}
    diskutil unmount $1
		echo -e "$blue\n \busb drive clean complete... safe to remove $rs"
  else
		echo -e "$yellow\n \busage: usb_clean [drive_name]"
    echo -e "available mounted usb drives: $(diskutil list | awk '/DOS_FAT/ {print $3}') $rs"
  fi
} # }}}
init() { # {{{
  # [ -z "$PS1" ] && return                   # quit if shell is non-interactive
  vars                                      # load variables
  prompt                                    # build custom prompt
  for f in ~/.bash_extra/*; do . "$f"; done # source additional directives
  umask 002                                 # set default perms @dir/files
  set -o noclobber                          # no redirect overwrite; override >|
  shopt -s histappend                       # append history; no clobber
  # greet                                     # display logo & messages
} # }}}

init "$@"