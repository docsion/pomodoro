#!/bin/bash
#
# Pomodoro
# Home: _

set -euo pipefail

#
# Template:
#   - https://www.uxora.com/unix/shell-script/18-shell-script-template
#   - https://github.com/RenatGilmanov/shell-script-template/blob/master/getopts/template-getopts.sh
#
#================================================================
# HEADER
#================================================================
#%
#% ${SCRIPT_NAME} - Short breaks, working effectively .
#% Usage: ${SCRIPT_NAME} [-hv] -t[minutes] args ...
#%
#% Options:
#%    -t [minute], --time=[minute]  Time frames (default=25,5,25,5,25,5,30)
#%                                  use to set working minutes follow up with break minutes.
#%                                  The default value is 25,5,25,5,25,5,30
#%                                  meaning working 25m, then break 5m, then working 25m...
#%    -h, --help                    Show help
#%    -v, --version                 Show the version
#%
#% Examples:
#%    ${SCRIPT_NAME} -t 25,5,25,5,25,5,30
#%
#================================================================
#- Author:
#-    Beast. D <beast@docsion.com>
#-
#================================================================
#- Copyright:
#-    (c) 2023 Docsion Team .
#-
#================================================================
# END_OF_HEADER
#================================================================

SCRIPT_HEADSIZE=$(head -200 ${0} |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
SCRIPT_NAME="$(basename ${0})"
VERSION=0.1.0

usagefull() { 
  head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#[%+-]" | sed -e "s/^#[%+-]//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ;
}

TIMES=25,5,25,5,25,5,25,30

while getopts "t:tvh" optname
do
    case "$optname" in
      "v")
	echo $VERSION
        exit 0;
        ;;
      "h")
	usagefull
        exit 0;
        ;;
      "t")
	TIMES=${OPTARG:-$TIMES}
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done

shift $(($OPTIND - 1))

countdown() {
    local seconds=$(( $1*60 ))
    local start="$(( $(date '+%s') + $seconds))"
    local count=${seconds}
    while [ $start -ge $(date +%s) ]; do
        sleep 1
	count=$((count-1))
	printf "%s %02d:%02d\033[0K\r" "[🍅]" $((count/60)) $((count%60))
    done
}

_notify() {
  local msg=$1
  script="display notification \"${msg}\" with title \"🍅\""
  osascript -e $script
}

_work() {
  local times=${1}
  echo "[${times}m] Deep working ..."
  countdown ${times}
}

_break() {
  local times=${1}
  echo "[${times}m] Short break ..."
  countdown ${times}
}

start() {
  local times=${1}

  echo 
  echo "[🍅] Pomodoro(work,break) \"-t ${times}\" launch"
  echo 

  local action=work

  IFS=$','
  for t in $times; do
    case "${action}" in
    work)

      # notify
      _notify "👨‍💻 Deep working ${t} minutes"

      # start
      _work ${t}
      echo

      # take short break

      action=break;
    ;;
    break)
      # notify
      _notify "🏄‍♀️ Take a short break for ${t} minutes please"

      # start
      _break ${t}
      echo

      # back to work
      action=work;
    ;;
    *)
      error "Unexpected action '${action}'"
    ;;
    esac
  done
}

start $TIMES
