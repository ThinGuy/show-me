#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $SM_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

export SM_DNS="9.9.9.9,1.1.1.1,8.8.8.8"
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf

export SM_APP=${1:-landscape}

command -v lynx 2>/dev/null || { printf "Missing application \"lynx\".  Attempting to install\n";apt update && apt install -fqy --reinstall lynx; }

[[ -f /etc/lynx/lynx.cfg ]] || { printf "Missing application parts of \"lynx\".  Attempting to install\n";apt update && apt install -fqy --reinstall lynx; }

command -v lynx 2>/dev/null || { printf "Missing application \"lynx\".  Attempted installation failed.  Exiting\n";exit 1; }

#comfigure lynx to auto accept cookes, ignore tls errors, etc

if [ -f /etc/lynx/lynx.cfg ];then sed -i -r "s/^#?(FORCE_SSL_COOKIE.*:|SET_COOKIE.*:|ACCEPT_ALL_COOKIE.*:)[^$]*/\1TRUE/;s/^#?(COOKIE_LOOSE_INVALID_DOMAINS:)[^$]*/\1$(hostname -I|sed -r 's/\x20/\n/g'|sed -r '/:|^$/d;1s/^/'$(hostname -d)'\n/g'|paste -sd,)/;s/^#?(FORCE_COOKIE_PROMPT.*:|FORCE_SSL_PROMPT.*:)[^$]*/\1yes/;s/^#?(COOKIE_.*FILE:.*$)/\1/" /etc/lynx/lynx.cfg;fi

# Run script (sends keystrokes to lynx browser
[[ -f /usr/local/lib/show-me/${SM_APP}.lynx ]] && { lynx -nostatus -nopause -nocolor -cmd_script=/usr/local/lib/show-me/${SM_APP}.lynx https://$(hostname -f)/new-standalone-user; } || { printf "No lynx script found for Show Me app \"${SM_APP}\"";exit 0; }

RC=${?}

{ [[ $SM_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }

exit ${RC}

