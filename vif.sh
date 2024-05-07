#! /usr/bin/bash
# // 2024-05-02 Thu 08:46

#------------------------------------------------------------


fd='fdfind --hidden --exclude .git'
  # fd='/usr/bin/fdfind --hidden'
  # Trying to alias the fdfind to fd; don't think aliasing is possible here;

STYLE="--border --margin=1 --prompt=: --header=————————————————————————————————"
OPTION='--preview-window=right:40%:wrap'
  # OPTION="--preview='head -n50 {}'"  <---- Can't seem to put this in a variable; the {} errors;
  # It seems that if you quote STYLE, Bash interprets that as a single string rather \
  # than separate flags and options; so it doesn't seem to work; have to remove the quotes;


ARGS=''
START_DIR=''
OKAY=true

#------------------------------------------------------------

function _show_help() {
cat << EOF
vif : vim fzf

SYNOPSIS
  Open vim files with fzf

SYNTAX
  $ vif [start_directory] [-h | --help]

FLAG OPTIONS
  -h | --help       Display this help

EXAMPLES
  $ vif --help   Show help
  $ vif          Search from user's home directory
  $ vif .        Search from current directory
  $ vif /etc     Search from /etc directory

EOF
# exit 0;
OKAY=false

}

function _vif() {

    local FILE_RESULT=''
    local ISBAT=''
    local ISBATCAT=''

    ISBAT=$(which bat)
    ISBATCAT=$(which batcat)

    if [[ -n $ISBAT ]]; then
      FILE_RESULT=$($fd -tf . "$START_DIR" | fzf $STYLE "$OPTION" --preview='bat --color=always --line-range=:100 {}')
    elif [[ -n $ISBATCAT ]]; then
      FILE_RESULT=$($fd -tf . "$START_DIR" | fzf $STYLE "$OPTION" --preview='batcat --color=always --line-range=:100 {}')
    else
      FILE_RESULT=$($fd -tf . "$START_DIR" | fzf $STYLE "$OPTION" --preview='head -n100 {}')
    fi
      # The {} characters can't be put into a variable, it seems;
      # $STYLE is not quoted, but $OPTION is; weird error and quirks;
      # Note: In case we forget, what we're doing here is running fd search for everything
      # in the $START_DIR and piping it to fzf, which we style as above with preview;

    # check string is not null; user chose a file
    # If so, open with vim;
    if [[ -n "$FILE_RESULT" ]]; then
        vim "$FILE_RESULT"
    fi

}  

function _check_params() {

  if [[ -z "$ARGS" ]]; then
      # START_DIR="$HOME"
      START_DIR="."
      # For ease, let's make the default the user's home folder
      # So to search current directory, should pass .
  elif [[ "$ARGS" == "-h" || "$ARGS" == "--help" ]]; then
      _show_help
  elif [[ ! -d "$ARGS" ]]; then
      echo "Bad directory."
      OKAY=false
      # _show_help
  else
      START_DIR="$ARGS"
  fi
    # Check the START_DIR variable;
    # If empty, then assign .
    # Do this because get error otherwise
    # if pass empty string; See note below about the error;
    # Also check if the directory is valid;

}

#--------------------------------------------------------

ARGS="$*"

# Check parameters and flags
_check_params

# If OKAY, then run;
if $OKAY; then _vif; fi;

# I can use exit to exit on error, but just decided to stay consistent with sourced scripts syntax as well; if error, then note that in the OKAY variable; and only run if it's oKAY;



#--------------------------------------------------------

# Note:
  # Get this message when trying to do an fd search with a path:
  # For instance, if try this:
  # $ fd -tf /home/h5/tmp

    # If you want to search for all files inside the '/home/h5/Downloads' directory, use a match-all pattern:
    #   fd . '/home/h5/Downloads'
    # Instead, if you want to search for the pattern in the full path, use:
    #   fd --full-path '/home/h5/Downloads'

  # See notes in find_fd_command_notes.txt;