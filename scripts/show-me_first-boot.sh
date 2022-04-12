#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }



cat <<-'EOD'|sed -r 's/[ \t]+$//g'|tee 1>/dev/null /etc/systemd/system/show-me-oneshot.service
[Unit]
Description=Reconfigure Preinstalled Landscape Server on first boot
After=network.target
ConditionPathExists=/usr/local/bin/show-me_landscape-rename.sh

[Service]
Type=oneshot
RemainAfterExit=no
ExecStartPre=/bin/bash -c 'cd /opt/show-me;git pull'
ExecStart=/bin/bash -c '/usr/local/bin/show-me_landscape-rename.sh'

[Install]
WantedBy=multi-user.target
EOD



[[ -f /etc/systemd/system/show-me-oneshot.service ]] && { true; } || { printf "\n\e[4G\e[0;1;38;2;255;0;0mERROR\e[0m: Issue creating Show-Me-Oneshot service file in /etc/systemd/system/show-me-oneshot.service. Please check permissions.\e[0m\n";exit 1; }


systemctl daemon-reload;
systemctl enable show-me-oneshot.service;

RC=${?}

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }

exit ${RC}
