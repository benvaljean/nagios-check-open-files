#!/bin/bash
# Nagios Plugin to monitor open files count for a process
# https://github.com/benvaljean/nagios-check-open-files.git
#
# Benjamin Goodacre 2013
#

version=1.1.25

BASENAME=$(basename "$0")

# Exit Status
okExit=0
warningExit=1
criticalExit=2
unknownExit=3

# Syntax for this script
function printhelp {
echo "$BASENAME $version"
echo "Nagios Plugin to monitor open files count for a process"
echo "Usage: $BASENAME -p ProgramName -W ProgramWarnlevel -C ProgramCriticlevel"
echo "Where:
        -p ProgramName                  : Program name or string listed in ps -ef
        -W ProgramWarningLevel          : Programs Warning Level (default 400)
        -C ProgramCriticalLevel         : Programs Critical Level (default 512)"
exit $unknownExit
}

# Validate command line parameters

while getopts "hp:W:C:w:c:" optionName; do
   case "$optionName" in
        p) ProgName="$OPTARG";;
        W) ProgWlevel="$OPTARG";;
        C) ProgClevel="$OPTARG";;
        *) printhelp;;
   esac
done

# Program name is required
[ -z "$ProgName" ] && printhelp

# Set default values
[ -z "$ProgWlevel" ] && ProgWlevel=400
[ -z "$ProgClevel" ] && ProgClevel=512

MESSAGE=""

# Get the PID of program(s)
PidOfProg="$(ps -ef|grep "$ProgName"|grep -Ewv "grep|$0"|awk '{print $2}')"
[ -z "$PidOfProg" ] && echo "UNKNOWN: Not able to determine PID of $ProgName" && exit $unknownExit

NoOfOpenFiles=$(ls -l /proc/"$PidOfProg"/fd|wc -l)
if [ "$NoOfOpenFiles" -ge "$ProgClevel" ] ;then
  MESSAGE="pid $PidOfProg has $NoOfOpenFiles open files. "
  CRITICAL=yes
elif [ "$NoOfOpenFiles" -ge $ProgWlevel ] ;then
  MESSAGE="$MESSAGE pid $PidOfProg has $NoOfOpenFiles open files. "
  WARNING=yes
else
  MESSAGE="Open FDs = $NoOfOpenFiles PID=$PidOfProg "
  OK=yes
fi

# Display Message and exit with correct exit status
perfdata="'Open FDs'=$NoOfOpenFiles;$ProgWlevel;$ProgClevel;0;$ProgClevel"
# Display Message and exit with correct exit status
[ "$CRITICAL" = yes ] && echo "FDs CRITICAL: $ProgName $MESSAGE |$perfdata"  && exit $criticalExit
[ "$WARNING" = yes  ] && echo "FDs WARNING: $ProgName $MESSAGE |$perfdata"  && exit $warningExit
[ "$OK" = yes  ] && echo "FDs OK: $ProgName $MESSAGE|$perfdata"  && exit $okExit
