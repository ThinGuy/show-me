#!/usr/bin/env bash
# vim: set et ts=2 sw=2 filetype=bash :
[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

sudo lxd init --preseed < /opt/show-me/scripts/show-me_mass_lxd-init.yaml

lxc image copy ubuntu-daily:focal local: --alias maas-controller-focal --alias focal --auto-update --public
lxc image copy ubuntu-daily:jammy local: --alias maas-controller-jammy --aliase jammt=y --auto-update --public
lxc remote add minimal https://cloud-images.ubuntu.com/minimal/daily --protocol simplestreams --accept-certificate
for I in $(lxc image list minimal: -cfl|awk '/more|CONTAIN/{print $4}'|sort -uV|sed -r '/^t.*|^x.*/!H;//p;$!d;g;s/\n//');do 
  ((lxc image copy  minimal:${I} local: --alias ${I} --auto-update --public) &);
done

exit 0
