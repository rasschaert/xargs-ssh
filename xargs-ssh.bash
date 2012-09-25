#!/bin/bash

# Copyright (c) 2012, Kenny Rasschaert
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Description: Parallel processing of SSH commands with xargs
# Github gist URL: https://gist.github.com/3780799
# License: MIT

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
  # Fancy colors in terminal output for increased legibility
  bluetxt=$(tput setaf 4)
  normaltxt=$(tput sgr0)
  boldtxt=$(tput bold)
  # If a second argument is passed, save everything but the first argument as the command to be sent over SSH
  [[ ! -z "$2" ]] && command="$(echo $@ | sed 's/^[^ ]* //')"
  # Either use a file or stdin to get a list of servers
  if [[ "$serverfile" -eq "1" ]]; then
    # Connect to all servers in parallel and run $command
    xargs -a $1 -I"SERVER" -P0 -n1 sh -c "printf \"\n###### ${bluetxt}${boldtxt}SERVER${normaltxt} ######\n\$(ssh SERVER \"$command\" 2>&1)\n\""
  else
    serverlist=""
    while read data; do
      serverlist=$(echo "$serverlist;$data")
    done
    # Connect to all servers in parallel and run $command
    echo $serverlist | tr ';' '\n' | xargs -I"SERVER" -P0 -n1 sh -c "printf \"\n###### ${bluetxt}${boldtxt}SERVER${normaltxt} ######\n\$(ssh SERVER \"$command\" 2>&1)\n\""
  fi
}

# Parse the arguments and run the xargs-ssh function
parse-args $1
xargs-ssh $@
