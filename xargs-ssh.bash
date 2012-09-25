#!/bin/bash
# Parallel processing of ssh commands with xargs

parse-args() {
  # If no argument is passed, show the user how to use this script
  if [[ -z "$1" ]]; then
    echo "Usage: $0 {filelist | - } [command]" >&2
    exit 1
  # If the - option is passed, use stdin for input
  elif [[ "$1" == "-" ]]; then
    serverfile="0"
  else
    serverfile="1"
  fi
}

xargs-ssh() {
  # The default command is uptime
  command="uptime"
  # If a second argument is passed, save everything but the first argument as the command to be sent over ssh
  [[ ! -z "$2" ]] && command="$(echo $@ | sed 's/^[^ ]* //')"
  if [[ "$serverfile" -eq "1" ]]; then
    # Connect to all servers in parallel and run $command
    # Fancy colors in terminal output for increased legibility
    bluetxt=$(tput setaf 4)
    normaltxt=$(tput sgr0)
    boldtxt=$(tput bold)
    xargs -a $1 -I"SERVER" -P0 -n1 sh -c "printf \"\n###### ${bluetxt}${boldtxt}SERVER${normaltxt} ######\n\$(ssh SERVER \"$command\")\n\""
  else
    echo "Reading from stdin is not yet implemented" >&2
    exit 1
  fi
}

# Parse the arguments and run the xargs-ssh function
parse-args $1
xargs-ssh $@