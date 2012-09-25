#!/bin/bash
# Parallel processing of ssh commands to multiple machines

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
    # connect to all servers in parallel and run $command
    xargs -a $1 -I"SERVER" -P0 -n1 sh -c "ssh SERVER \"$command\" | sed \"s/^/SERVER: /\""
  else
    echo "Reading from stdin is not yet implemented" >&2
    exit 1
  fi
}

# go through the functions
parse-args $1
xargs-ssh $@