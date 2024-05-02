#! /usr/bin/bash
# // 2024-05-02 Thu 08:46

#------------------------------------------------------------


fd='fdfind --hidden'
  # fd='/usr/bin/fdfind --hidden'
  # Trying to alias the fdfind to fd; don't think aliasing is possible here;

STYLE="--border --margin=1 --prompt=: --header=————————————————————————————————"
OPTION='--preview-window=right:40%:wrap'
  # OPTION="--preview='head -n50 {}'"  <---- Can't seem to put this in a variable; the {} errors;
  # It seems that if you quote STYLE, Bash interprets that as a single string rather \
  # than separate flags and options; so it doesn't seem to work; have to remove the quotes;

#------------------------------------------------------------

function _show_help() {
cat << EOF
vif : vim fzf

SYNOPSIS
  Open vim files with fzf

SYNTAX
  $ vif [directory_path] [-h | --help]

FLAG OPTIONS
  -h | --help       Display this help

EXAMPLES
  $ vif --help   Show help
  $ vif          Search in current directory
  $ vif ~/       Search in home directory
  $ vif /etc     Search in /etc directory

EOF
exit 0;
}

function _vif() {

    local file_result=''

    file_result=$($fd -tf . "$START_DIR" | fzf $STYLE "$OPTION" --preview='head -n50 {}')
      # The {} characters can't be put into a variable, it seems;
      # $STYLE is not quoted, but $OPTION is; weird error and quirks;
      # Note: In case we forget, what we're doing here is running fd search for everything
      # in the $START_DIR and piping it to fzf, which we style as above with preview;

    # check string is not null; user chose a file
    # If so, open with vim;
    if [[ -n "$file_result" ]]; then
        vim "$file_result"
    fi

}  
  
  
START_DIR="$*"

if [[ -z "$START_DIR" ]]; then
    START_DIR="."
elif [[ "$START_DIR" == "-h" || "$START_DIR" == "--help" ]]; then
    _show_help
elif [[ ! -d "$START_DIR" ]]; then
    echo "Bad directory."
    exit
fi
  # Check the START_DIR variable;
  # If empty, then assign .; Do this because get error otherwise
  # if pass empty string; See note below about the error;
  # Also check if the directory is valid;


# Run
_vif


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