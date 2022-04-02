#!/usr/bin/env bash
# vim: set et ts=2 sw=2 filetype=bash :

[[ -n ${1} && ${1,,} =~ -h ]] && { printf "${0##*/} [# of instances per release (ipr)]\n\nDefault ipr = 2\n\n";exit 2; }
[[ -n ${1} && ${1} =~ ^[0-9]+$ ]] && { export MAXI=${1}; }
[[ ${MAXI} -gt 10 ]] && { printf "Defaulting to safe max instances per release of 10\n"; } || { printf "Setting instances per release to ${MAXI}\n"; }
[[ -z ${MAXI} ]] && { export MAXI=2;printf "Defaulting to ${MAXI} instances per release\n"; }
for X in $(lxc image list -cfl|awk '/^\|/&&!/FIN/{print $2":"$4}');do
  export A=${X##*:} I=${X%%:*}
  [[ ${A} =~ t ]] && export R=Trusty;
  [[ ${A} =~ x ]] && export R=Xenial;
  [[ ${A} =~ b ]] && export R=Bionic;
  [[ ${A} =~ f ]] && export R=Focal;
  [[ ${A} =~ i ]] && export R=Impish;
  [[ ${A} =~ j ]] && export R=Jammy;
declare -ag NAMES=($(cat /usr/local/share/petname2/${A:0:1}-names.txt))
declare -ag ADVERBS=($(cat /usr/local/share/petname2/${A:0:1}-adverbs.txt))
declare -ag ADJECTIVES=($(cat /usr/local/share/petname2/${A:0:1}-adjectives.txt))
  for Y in $(seq 1 1 $MAXI);do
    [[ ${Y} = 1 ]] && export W=st;
    [[ ${Y} = 2 ]] && export W=nd;
    [[ ${Y} = 3 ]] && export W=rd;
    [[ ${Y} -ge 4 && ${Y} -le 10 ]] && W=th;
    export NAME="${ADVERBS[$RANDOM % ${#ADVERBS[@]}]}-${ADJECTIVES[$RANDOM % ${#ADJECTIVES[@]}]}-${NAMES[$RANDOM % ${#NAMES[@]}]}-${R,,}"
    printf "Launching ${Y}${W} instance of ${R} as ${NAME}\n";
    ((lxc launch $I ${NAME} -p landscape-client &>>/tmp/add-clients.log) &)
    unset X Y NAME
  done
done
exit ${?}
