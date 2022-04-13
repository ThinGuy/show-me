#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }


cat <<ONBOOT |sed -r 's/[ \t]+$//g'|tee 1>/dev/null /etc/systemd/system/show-me-on-boot.service
[Unit]
Description=ubuntu-show.me service
After=network-online.target
ConditionPathExists=/usr/local/bin/show-me_landscape-rename.sh

[Service]
Type=oneshot
ExecStart=/bin/bash -c '/usr/local/bin/show-me_landscape-rename.sh'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
ONBOOT

[[ -f /etc/systemd/system/show-me-on-boot.service ]] && { true; } || { printf "\n\e[4G\e[0;1;38;2;255;0;0mERROR\e[0m: Issue creating Show-Me-Oneshot service file in /etc/systemd/system/show-me-on-boot.service. Please check permissions.\e[0m\n";exit 1; }


systemctl daemon-reload;
systemctl enable show-me-on-boot.service;

RC=${?}

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }

exit ${RC}
