#!/bin/bash

# Copyright (c) 2012, Kenny Rasschaert
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Description: Parallel processing of SSH commands with xargs
# Github gist URL: https://gist.github.com/3780799
# License: MIT

scriptmode=0
command="uptime"
input=""

# Parse command line options
while getopts "hsi:c:" flag
do
  # Print usage information if the -h flag is invoked
  if [[ "$flag" == "h" ]]; then
    echo "Usage: $0 -i <input> [-c <command>] [-h] [-s]"
    echo "  -i specifies the input source. Use -i filename to read from a file or -i - to use stdin. This is a mandatory option."
    echo "  -c lets you specify a command to run on each server. By default this command is \"uptime\"."
    echo "  -s enables script mode, which keeps the output for each server on one line."
    echo "  -h prints this help message."
    exit 0
  # Enable script mode if the -s flag is invoked
  elif [[ "$flag" == "s" ]]; then
    scriptmode=1
  # A command is being specified if the -c flag is invoked
  elif [[ "$flag" == "c" ]]; then
    command="$OPTARG"
  # An input source is specified if the -i flag is invoked
  elif [[ "$flag" == "i" ]]; then
    input=$OPTARG
    # If the input source is "-", use stdin
    if [[ "$input" == "-" ]]; then
      # Create a temporary file to save the serverlist in
      tempfile=$(mktemp)
      while read data; do
        echo $data >> $tempfile
      done
      serverlist=$tempfile
    # Else use the filename specified as input source
    else
      serverlist=$input
    fi
  fi
done

# The -i option is mandatory
if [[ -z "$serverlist" ]]; then
  echo "No input specified! Use -i filename or -i - to read from stdin."
  exit 1
fi

# Count the number of "CPU's" or hyperthreads on this machine
threads="$(awk '/^processor/ {cpu++} END {print cpu}' /proc/cpuinfo)"

# Fancy colors in terminal output for increased legibility
bluetxt=$(tput setaf 4)
normaltxt=$(tput sgr0)
boldtxt=$(tput bold)

# If scriptmode is not specified, format the output in a pretty and legible way
if [[ "$scriptmode" == 0 ]]; then
  cmd="{ printf \"###### ${bluetxt}${boldtxt}SERVER${normaltxt} ######\n\$(ssh SERVER \"$command\" 2>&1)\n\n\"; }"
# If scriptmode is specified, format the output so that the output of each server is on one easiliy parsed line
else
  cmd="{ printf \"SERVER: \$(ssh SERVER \"$command\" 2>&1)\" | perl -i -p -e 's/\n/\\\n/'; echo; }"
fi

# Use xargs for parallelism, use as many threads as the CPU supports
# Inside the xargs, start subshells to run ssh with the specified or default command
xargs -a $serverlist -I"SERVER" -P${threads} -n1 sh -c "$cmd"

# If a temporary file was created to put the serverlist in, remove it
if [[ ! -z "$tempfile" ]]; then
  find $tempfile -type f | xargs rm
fi
