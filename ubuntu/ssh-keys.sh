#!/bin/bash
#prototype
ssh_congig_file_path='/home/$USER/.ssh/'
if [ -n "$1" ]
# Test whether command-line argument is present (non-empty).
then
 lines=$1
else
 lines=$LINES # Default, if not specified on command-line.
fi 