#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -eq 0 ]] || { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

#### This script cleans up machine that is intended to be used for an AMI.
#### Run this last.

#################################
#####  AMI Cleanup Script  ######
#################################

ua detach --assume-yes
rm -rf /var/log/ubuntu-advantage.log
truncate -s 0 /etc/machine-id
truncate -s 0 /var/lib/dbus/machine-id
history -c
unset HISTFILE
truncate -s 0 ~/.bash_history
find /var/log -type f -iname "*.log" -exec truncate -s 0 {} \;
su $(id -un 1000) -c 'history -c'
su $(id -un 1000) -c 'unset HISTFILE'
su $(id -un 1000) -c 'truncate -s 0 ~/.bash_history'

