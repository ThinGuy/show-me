#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ ${CLOUD_DEBUG} ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

######################################
#####  Rename Landscape Server  ######
######################################

export LDS_CONF=$(find /etc/apache2/sites-available -type f -regextype "posix-extended" -iregex '.*(i-|ec2-).*conf$')
export LAST_FQDN="$(grep -m1 -oP '(?<=ServerName )[^$]+' ${LDS_CONF})"
sed -i -r "s/${LAST_FQDN}/${CLOUD_APP_FQDN_LONG}/g" ${LDS_CONF}


{ [[ ${CLOUD_DEBUG} ]] &>/dev/null; } && { { set +x; } &>/dev/null; }

exit 0
