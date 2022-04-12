#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ -f ~/.show-me.rc ]] && source ~/.show-me.rc

cat <<LSPROFILE |sed -r 's/[ \t]+$//g;/^$/d'|lxc profile edit landscape-client
config:
  boot.autostart: "true"
  user.user-data: |
    #cloud-config
    final_message: 'Landscape Client completed Installing in \$UPTIME'
    manage_etc_hosts: true
    preserve_hostname: true
    locale: en_US.UTF-8
    apt:
      conf: |
        APT {
          Get {
            Assume-Yes "true";
            Fix-Broken "true";
            Auto-Remove "true";
            Purge "true";
          };
          Acquire {
            ForceIPv4 "true";
            Check-Date "false";
          };
        };
      primary:
        - arches: [$CLOUD_ARCH]
          uri: 'http://${CLOUD_REPO_FQDN}/ubuntu'
      security:
        - arches: [$CLOUD_ARCH]
          uri: 'http://${CLOUD_REPO_FQDN}/ubuntu'
      sources_list: |
        deb [arch=$CLOUD_ARCH] \$PRIMARY \$RELEASE main universe restricted multiverse
        deb [arch=$CLOUD_ARCH] \$PRIMARY \$RELEASE-updates main universe restricted multiverse
        deb [arch=$CLOUD_ARCH] \$SECURITY \$RELEASE-security main universe restricted multiverse
        deb [arch=$CLOUD_ARCH] \$PRIMARY \$RELEASE-backports main universe restricted multiverse
      sources:
        landscape-19.10-bionic.list:
          source: 'deb [arch=$CLOUD_ARCH] http://ppa.launchpad.net/landscape/19.10/ubuntu bionic main'
          keyid: 6E85A86E4652B4E6
    packages: [landscape-client]
    package_update: true
    package_upgrade: true
    ssh_pwauth: true
    ssh_authorized_keys:
     - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8lQk7k7WexyK9i6yYJ0M53R3LXkT5kYVwYSz+SHkOSMgrwIMZ90qdJhJ4gvm5ivorg06rGHR/o0Ly/JY3oAPtltPHdjn8u86jMVvsKQfnhZCApAfc38Uhnf1McqjUgYMA10JQGePvEs/1ZEQmJX/igHtWUYGNI6KEDu0iF6oGLTrEcxUIm0Kyib9+KLzO2wdaWvWqMDaxyLTqvZU3G8WniI+hlEbd7w7Kbrb2feOpCPugZipsY2Hzcie/7C599El0tJO0PcKaali0StbMIQMe26lFgV8kQTh/mx3dh3rt0tlD5it+yvZ+DnkrFRRGJcf1pWQgPWZUnnn1gDfKqsdP demo@ubuntu-show.me
    runcmd:
      - set -x
      - export DEBIAN_FRONTEND=noninteractive
      - "echo '${CLOUD_PUBLIC_IPV4} ${CLOUD_APP_FQDN_LONG} ${CLOUD_PUBLIC_HOSTNAME}'|tee -a /etc/hosts"
      - "printf '%s\x20%s\x20\x20%s\n' precedence '::ffff:0:0/96' 100|tee -a /etc/gai.conf"
      - if [ "\$(readlink -f /etc/resolv.conf)" != "/run/resolvconf/resolv.conf" ];then ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf;fi
      - export DEFAULT_IP=\$(ip -o -4 a show dev \$(ip -o route show default|grep -m1 -oP '(?<=dev )[^ ]+')|grep -m1 -oP '(?<=inet )[^/]+')
      - "landscape-config -a standalone -p landscape4u -t \$(hostname -s) -u https://${CLOUD_APP_FQDN_LONG}/message-system --ping-url http://${CLOUD_APP_FQDN_LONG}/ping --http-proxy= --https-proxy= --script-users=ALL --access-group=global --tags=landscape-client,demo,ubuntu --silent --log-level=debug"
description: Landscape Client Profile
devices:
  eth0:
  eth0:
    name: eth0
    nictype: bridged
    parent: lxdbr0
    type: nic
  root:
    path: /
    pool: default
    type: disk
    size: 4GB
name: landscape-client
LSPROFILE

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }
exit 0