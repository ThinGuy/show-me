#!/usr/bin/env bash
# vim: set et ts=2 sw=2 filetype=bash :
[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

#Reserved for future use

exit 0
