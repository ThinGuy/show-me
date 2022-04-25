#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

lxd init --preseed < /usr/local/lib/show-me/show-me_maas_lxd-init.yaml


lxc image copy ubuntu-daily:focal local: --alias maas-controller-focal --alias focal --auto-update --public
lxc image copy ubuntu-daily:jammy local: --alias maas-controller-jammy --alias jammy --auto-update --public
lxc remote add minimal https://cloud-images.ubuntu.com/minimal/daily --protocol simplestreams --accept-certificate
for I in $(lxc image list minimal: -cfl|awk '/more|CONTAIN/{print $4}'|sort -uV|sed -r '/^t.*|^x.*/!H;//p;$!d;g;s/\n//');do 
  ((lxc image copy  minimal:${I} local: --alias ${I} --auto-update --public) &);
done

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }
exit 0
