#!/bin/bash
if [ $# -ne 1 ]
then
  echo "Usage $0 LOG_FILE"
  exit 1
fi
if [ -r $1 ]
then
  sent_commands=`grep -i "SENT" $1 | wc -l`
  lost_commands=`grep -i "REPEATING" $1 | wc -l`
  let dif=$sent_commands-$lost_commands
  echo "Commands sent: $sent_commands"
  echo "Commands lost: $lost_commands"
  echo "Unique commands: $dif"
  echo "Percentage of success: %$((dif*100/sent_commands))"
else
  echo "Can't read '$1'"
  exit 1
fi
