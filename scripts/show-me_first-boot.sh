#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }



cat <<-'EOD'|sed -r 's/[ \t]+$//g'|tee 1>/dev/null /etc/systemd/system/show-me-oneshot.service
[Unit]
Description=Reconfigure Preinstalled Landscape Server on first boot
After=syslog.target
After=network.target
ConditionPathExists=/etc/landscape/service.conf
ConditionPathNotExists=/opt/show-me/.renamed

[Service]
Type=oneshot
RemainAfterExit=no
ExecStart=/bin/bash -c '/usr/local/bin/show-me_landscape-rename.sh'
StandardOutput=journal
StandardError=journal
ExecStartPost=/bin/bash -c '/usr/local/bin/show-me_oneshot-cleanup.sh'

[Install]
WantedBy=multi-user.target
EOD



[[ -f /etc/systemd/system/show-me-oneshot.service ]] && { true; } || { printf "\n\e[4G\e[0;1;38;2;255;0;0mERROR\e[0m: Issue creating Show-Me-Oneshot service file in /etc/systemd/system/show-me-oneshot.service. Please check permissions.\e[0m\n";exit 1; }


systemctl daemon-reload;

# Note: More success starting service early if "start" is performed twice
# thus the repeated command in the for loop is intentional

for S in enable start start status;do
  systemctl ${S} show-me-oneshot.service;
  sleep .5;
done
[[ $(systemctl -q is-active show-me-oneshot.service;echo $?) -eq 0 ]] && { printf "\n\e[4G\e[0;1;38;2;0;255;0mSuccess\x21\e[0m The Show-Me-Oneshot Service is now available\e[0m\n";true;export RC=0; } || { printf "\n\e[4G\e[0;1;38;2;255;0;0mERROR\e[0m: Failed to start Show-Me-Oneshot Service\e[0m\n";false;export RC=1; }
exit ${RC}

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }
