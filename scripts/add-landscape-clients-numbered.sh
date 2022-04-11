#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ -n ${1} && ${1,,} =~ -h ]] && { printf "${0##*/} [# of instances per release (ipr)]\n\nDefault ipr = 1\n\n";exit 2; }
[[ -n ${1} && ${1} =~ ^[0-9]+$ ]] && { export MAXI=${1}; }
[[ ${MAXI} -gt 10 ]] && { printf "Defaulting to safe max instances per release of 10\n"; } || { printf "Setting instances per release to ${MAXI}\n"; }
[[ -z ${MAXI} ]] && { export MAXI=1;printf "Defaulting to ${MAXI} instance per release\n"; }
for X in $(lxc image list -cfl|awk '/^\|/&&!/FIN/{print $2":"$4}');do
  export A=${X##*:} I=${X%%:*}
  [[ ${A} =~ t ]] && export R=Trusty;
  [[ ${A} =~ x ]] && export R=Xenial;
  [[ ${A} =~ b ]] && export R=Bionic;
  [[ ${A} =~ f ]] && export R=Focal;
  [[ ${A} =~ i ]] && export R=Impish;
  [[ ${A} =~ j ]] && export R=Jammy;
  for Y in $(seq 1 1 $MAXI);do
    [[ ${Y} = 1 ]] && export W=st;
    [[ ${Y} = 2 ]] && export W=nd;
    [[ ${Y} = 3 ]] && export W=rd;
    [[ ${Y} -ge 4 && ${Y} -le 10 ]] && W=th;
    NEXT_NUM=$(($(lxc 2>/dev/null list ${R,,}-landscape-client- -cn -fcsv|tail -n1|sed 's/[a-z-]//g')+1))
    NEXT_NUM=$(printf '%03d\n' ${NEXT_NUM})
    export NAME="${R,,}-landscape-client-${NEXT_NUM}"
    printf "Launching ${Y}${W} instance of ${R} as ${NAME}\n";
    ((lxc launch $I ${NAME} -p landscape-client &>>/tmp/add-clients.log) &)
    unset X Y NAME
  done
done
RC=${?}
{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }
exit ${RC}
