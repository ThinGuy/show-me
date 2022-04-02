#!/usr/bin/env bash
# vim: set et ts=2 sw=2 filetype=bash :
[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }


cat <<-'EOD'|sed -r 's/[ \t]+$//g'|tee 1>/dev/null /etc/systemd/system/show-me-files.service
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

[[ $? -eq 0 && -f /etc/systemd/system/show-me-file.service ]] { true; } || { printf "\n\e[4G\e[0;1;38;2;255;0;0mERROR\e[0m: Failed to start Show-Me-File Service\e[0m\n";exit 1; }


systemctl daemon-reload;

# Note: More success starting service early if "start" is performed twice
# thus the repeated command in the for loop is intentional

for S in enable start start status;do
  systemctl ${S} show-me-file.service;
  sleep .5;
done

exit 0
