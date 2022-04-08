#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }
[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }



cat <<-'EOD'|sed -r 's/[ \t]+$//g'|tee 1>/dev/null /etc/systemd/system/show-me-file.service
[Unit]
Description=Simple Web server for use with Ubuntu demos
After=syslog.target
After=network.target
ConditionPathExists=/etc/show-me/www/

[Service]
Type=simple
WorkingDirectory=/etc/show-me/www/
ExecStart=/bin/bash -c 'cd /etc/show-me/www/;exec python3 -m http.server 9999 &>/etc/show-me/log/http.log'
RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOD

[[ -f /etc/systemd/system/show-me-file.service ]] && { true; } || { printf "\n\e[4G\e[0;1;38;2;255;0;0mERROR\e[0m: Issue creating Show-Me-File service file in /etc/systemd/system/show-me-file.service. Please check permissions.\e[0m\n";exit 1; }


systemctl daemon-reload;

# Note: More success starting service early if "start" is performed twice
# thus the repeated command in the for loop is intentional

for S in enable start start status;do
  systemctl ${S} show-me-file.service;
  sleep .5;
done
[[ $(systemctl -q is-active show-me-file.service;echo $?) -eq 0 ]] && { printf "\n\e[4G\e[0;1;38;2;0;255;0mSuccess\x21\e[0m The Show-Me-File Service is now available\e[0m\n";true;export RC=0; } || { printf "\n\e[4G\e[0;1;38;2;255;0;0mERROR\e[0m: Failed to start Show-Me-File Service\e[0m\n";false;export RC=1; }
exit ${RC}

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }
