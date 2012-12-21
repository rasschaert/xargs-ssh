#!/bin/bash

# Description: Parallel processing of SSH commands with xargs
# Github URL: https://github.com/rasschaert/xargs-ssh
# License: MIT

scriptmode=0
command="uptime"
input=""
serverlist=""

# Parse command line options
while getopts "hsf:c:" flag; do
  case "$flag" in
    h)  echo "Usage: $0 [-f <file>] [-c <command>] [-h] [-s]"
        echo "  -f specifies the input file. Use -f filename to read from a file. If no file is specified, stdin is used."
        echo "  -c lets you specify a command to run on each server. By default this command is \"uptime\"."
        echo "  -s enables script mode, which keeps the output for each server on one line."
        echo "  -h prints this help message."
        exit 0
        ;;
    s)  scriptmode=1
        ;;
    f)  serverlist=$OPTARG
        ;;
    c)  command="$OPTARG"
        ;;
    *)  exit 1
        ;;
  esac
done

# If no input file is specified, use stdin
if [[ -z "$serverlist" ]]; then
  tempfile=$(mktemp)
  while read data; do
    echo $data >> $tempfile
  done
  serverlist=$tempfile
fi

# Count the number of "CPU's" or hyperthreads on this machine
threads="$(awk '/^processor/ {cpu++} END {print cpu}' /proc/cpuinfo)"

# Fancy colors in terminal output for increased legibility
bluetxt=$(tput setaf 4)
normaltxt=$(tput sgr0)
boldtxt=$(tput bold)

# This is where the command is encapsulated in a printf statement.
# Doing this makes sure that the output of each server will remain together.

# If scriptmode is not specified, format the output in a pretty and legible way
if [[ "$scriptmode" == 0 ]]; then
  cmd="{ printf \"###### ${bluetxt}${boldtxt}SERVER${normaltxt} ######\n\$(ssh SERVER \"$command\" 2>&1)\n\n\"; }"
# If scriptmode is specified, format the output so that the output of each server is on one easiliy parsed line
else
  cmd="{ printf \"SERVER: \$(ssh SERVER \"$command\" 2>&1)\" | sed 's/$/\\\n/' | tr -d '\n' | sed 's/\\\n$/\n/'; }"
fi

# Use xargs for parallelism, use as many threads as the CPU supports
# Inside the xargs, start subshells to run ssh with the specified or default command
xargs -a $serverlist -I"SERVER" -P${threads} -n1 sh -c "$cmd"

# If a temporary file was created to put the serverlist in, remove it
if [[ ! -z "$tempfile" ]]; then
  find $tempfile -type f | xargs rm
fi
