#!/usr/bin/env bash
# vim: set et ts=2 sw=2 filetype=bash :

export SHOW_ME_APP=${1:-landscape}

if [ -f /etc/lynx/lynx.cfg ];then sed -i -r "s/^#?(FORCE_SSL_COOKIE.*:|SET_COOKIE.*:|ACCEPT_ALL_COOKIE.*:)[^$]*/\1TRUE/;s/^#?(COOKIE_LOOSE_INVALID_DOMAINS:)[^$]*/\1$(hostname -I|sed -r 's/\x20/\n/g'|sed -r '/:|^$/d;1s/^/'$(hostname -d)'\n/g'|paste -sd,)/;s/^#?(FORCE_COOKIE_PROMPT.*:|FORCE_SSL_PROMPT.*:)[^$]*/\1yes/;s/^#?(COOKIE_.*FILE:.*$)/\1/" /etc/lynx/lynx.cfg;fi
[[ -n $(command 2>/dev/null lynx) ]] || { printf "Missing application \"lynx\".  Attempting to install\n";apt update && apt install -fqy lynx; }
[[ -f /etc/lynx/lynx.cfg ]] || { printf "Missing application parts of \"lynx\".  Attempting to install\n";apt update && apt install -fqy lynx; }
[[ -n $(command 2>/dev/null lynx) || -f /etc/lynx/lynx.cfg ]] || { printf "Missing application \"lynx\".  Attempted installation failed.  Exiting\n";exit 1; }
[[ -f /opt/show-me/all/helpers/${SHOW_ME_APP}.lynx ]] || { printf "No lynx script found for Show Me app \"${SHOW_ME_APP}\"";exit 0; }

#comfigure lynx to auto accept cookes, ignore tls errors, etc
if [ -f /etc/lynx/lynx.cfg ];then sed -i -r "s/^#?(FORCE_SSL_COOKIE.*:|SET_COOKIE.*:|ACCEPT_ALL_COOKIE.*:)[^$]*/\1TRUE/;s/^#?(COOKIE_LOOSE_INVALID_DOMAINS:)[^$]*/\1$(hostname -I|sed -r 's/\x20/\n/g'|sed -r '/:|^$/d;1s/^/'$(hostname -d)'\n/g'|paste -sd,)/;s/^#?(FORCE_COOKIE_PROMPT.*:|FORCE_SSL_PROMPT.*:)[^$]*/\1yes/;s/^#?(COOKIE_.*FILE:.*$)/\1/" /etc/lynx/lynx.cfg;fi

# Run script (sends keystrokes to lynx browser.
lynx -cmd_script=/opt/show-me/all/helpers/${SHOW_ME_APP}.lynx "https://${SHOW_ME_APP}.ubuntu-show.me"

exit ${?}

