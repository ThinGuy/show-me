#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }


cat <<-'ONBOOT' |sed -r 's/[ \t]+$//g'|tee 1>/dev/null /etc/systemd/system/show-me-at-boot.service
[Unit]
Description=ubuntu-show.me rename service
ConditionPathExists=/usr/local/bin/show-me_landscape-rename.sh
After=network.target

[Service]
Type=Oneshot
Restart=on-failure
RestartSec=10
TimeoutStartSec=60
WorkingDirectory=/opt/show-me
ExecStartPre=/bin/mkdir -p /opt/show-me
ExecStartPre=/bin/chmod 755 /opt/show-me
ExecStartPre=/bin/bash -c 'cd /opt/show-me;git pull'
ExecStartPre=/bin/bash -c 'cp -a /opt/show-me/scripts/*.sh /usr/local/bin/'
ExecStartPre=/bin/chmod 755 /usr/local/bin/show-me_landscape-rename.sh
ExecStartPre=/bin/mkdir -p /var/log/show-me-landscape
ExecStartPre=/bin/chown syslog:adm /var/log/show-me-landscape
ExecStartPre=/bin/chmod 755 /var/log/show-me-landscape
ExecStart=/bin/bash -c '/usr/local/bin/show-me_landscape-rename.sh'
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=show-me-landscape
SuccessExitStatus=0

[Install]
WantedBy=multi-user.target
ONBOOT


[[ -f /etc/systemd/system/show-me-at-boot.service ]] && { true; } || { printf "\n\e[4G\e[0;1;38;2;255;0;0mERROR\e[0m: Issue creating Show-Me-Oneshot service file in /etc/systemd/system/show-me-at-boot.service. Please check permissions.\e[0m\n";exit 1; }


systemctl daemon-reload;
systemctl enable show-me-at-boot.service;

RC=${?}

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }

exit ${RC}
