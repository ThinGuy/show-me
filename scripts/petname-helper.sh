#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $SM_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

export SM_DNS="9.9.9.9,1.1.1.1,8.8.8.8"
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf

[[ $(dpkg -l petname|awk '/'${i}'/{print $1}') = ii ]] || { apt install petname -yqf; }
export UBUNTU_DISTS_URL="http://us.archive.ubuntu.com/ubuntu/dists"
declare -ag UBUNTU_SERIES_TMP=($(curl -sSlL ${UBUNTU_DISTS_URL} |awk -F">|<" -v R="${UBUNTU_DISTS_URL}" '/folder/{gsub(/\/$|-.*/,"",$13);print $13}'|sort -uV))
declare -ag UBUNTU_SERIES=($(printf '%s\n' ${UBUNTU_SERIES_TMP[@]}|sort -uV|sed '/devel/d'|sed -r '/^trusty.*|^xenial*/!H;//p;$!d;g;s/\n//'))
declare -ag UBUNTU_ALIASES=($(printf '%s\n' ${UBUNTU_SERIES[@]}|sed 's/.//2g'))
unset UBUNTU_SERIES_TMP
[[ -d /usr/local/lib/show-me/petname2 ]] || { install -o 0 -g 0 -m 0755 -d /usr/local/lib/show-me/petname2/; }
set -x
for X in names adjectives adverbs;do
  for Y in ${UBUNTU_ALIASES[@]};do
    grep -REI ^${Y} /usr/share/petname|awk -F':' '/'${X}'/{print $NF}'|sort -uV|tee 1>/dev/null /usr/local/lib/show-me/petname2/${Y}-${X}.txt
  done
done
exit 0
{ [[ $SM_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }
