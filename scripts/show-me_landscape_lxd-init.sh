#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $SM_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }
[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

cat <<-PRESEED|sed -r 's/[ \t]+$//g;/^$/d'|lxd init --preseed -
config:
  core.https_address: '[::]:8443'
  core.trust_password: ubuntu
networks:
- config:
    dns.domain: ubuntu-show.me
    dns.mode: dynamic
    ipv4.address: 10.10.10.1/24
    ipv4.nat: true
    ipv4.dhcp: true
    ipv6.address: none
  description: "LXD Internal Network for Show-Me Demos"
  name: lxdbr0
  type: ""
  project: default
storage_pools:
- config: {}
  description: ""
  name: default
  driver: dir
profiles:
- config:
    boot.autostart: "false"
    user.user-data: |
      #cloud-config
      final_message: 'Landscape Client completed Installing in \$UPTIME'
      manage_etc_hosts: false
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
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        security:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        sources_list: |
          deb [arch=amd64] $PRIMARY $RELEASE main universe restricted multiverse
          deb [arch=amd64] $PRIMARY $RELEASE-updates main universe restricted multiverse
          deb [arch=amd64] $SECURITY $RELEASE-security main universe restricted multiverse
          deb [arch=amd64] $PRIMARY $RELEASE-backports main universe restricted multiverse
        sources:
  description: Default LXD profile
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
- config:
    boot.autostart: "false"
    user.user-data: |
      #cloud-config
      final_message: 'Landscape Client completed Installing in \$UPTIME'
      manage_etc_hosts: false
      timezone: America/Los_Angeles
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
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        security:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        sources_list: |
          deb [arch=amd64] $PRIMARY $RELEASE main universe restricted multiverse
          deb [arch=amd64] $PRIMARY $RELEASE-updates main universe restricted multiverse
          deb [arch=amd64] $SECURITY $RELEASE-security main universe restricted multiverse
          deb [arch=amd64] $PRIMARY $RELEASE-backports main universe restricted multiverse
        sources:
          landscape-19.10-bionic.list:
            source: 'deb [arch=amd64] http://ppa.launchpad.net/landscape/19.10/ubuntu bionic main'
            keyid: 6E85A86E4652B4E6
      packages: [build-essential, jq, landscape-client, vim]
      package_update: true
      package_upgrade: true
      packages: [jq, landscape-client, vim]
      ssh_pwauth: true
      ssh_authorized_keys:
       - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDu4nob6Cm35j0CrdudDXGSjGzu8u1hJiZieoEi7Yk6G6tGCU+mVPp4Ny7K7VEzAj/HLHMgsHFIKDqJRYao7WPiXaGeRfuGKg2FtGwNlBlHkgulqCSwzke271sQWZkyYbdpBwXlkCiamv0ukyC7pJXYENc5Mri/OMYFhfJ93jYUMi0JFAFE+x3V9EMUsj8FBJgmYlBRRE7dQkVuihRnj4E2bKBJQxF17QAUaGmQQe/zT1UzeQff2C4oHrCfQpieCaZ25hkxDADPsZoJiRFTmPuy6xq4qE7J4AM+ERmFnoSVfE2+yHXXbpGaCtJE/iLj4cl77hbS13iVND7cy6SBdTbv demo@ubuntu-show.me
      runcmd:
        - set -x
        - export DEBIAN_FRONTEND=noninteractive
        - echo $DEFAULT_IP $(hostname -f) $(hostname -s)|tee -a /etc/hosts
        - if [ "\$(readlink -f /etc/resolv.conf)" != "/run/resolvconf/resolv.conf" ];then ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf;fi
        - export DEFAULT_IP=\$(ip -o -4 a show dev \$(ip -o route show default|grep -m1 -oP '(?<=dev )[^ ]+')|grep -m1 -oP '(?<=inet )[^/]+')
        - if \$(test -f /etc/hosts);then sudo sed -i.orig "/127.0.1.1/d;/127.0.0.1/a \$DEFAULT_IP\ \ \$(hostname -f) \$(hostname -s)" /etc/hosts;fi
        - systemctl restart procps.service
        - "wget -P /etc/landscape/ http://$(hostname -f):9999/landscape_server_ca.crt"
        - "wget -P /etc/landscape/ http://$(hostname -f):9999/landscape_server.pem"
        - "wget -P /usr/local/share/ca-certificates http://$$(hostname -f):9999/landscape_server_ca.crt"
        - update-ca-certificates --fresh --verbose
        - "if \$(test -f /etc/landscape/landscape_server.pem);then landscape-config -k /etc/landscape/landscape_server.pem -t \$(hostname -s) -u https://$(hostname -f)/message-system --ping-url http://$(hostname -f)/ping -a standalone --http-proxy= --https-proxy= --script-users=ALL --access-group=global --tags=landscape-server,demo,ubuntu --silent --log-level=debug;fi"
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
projects: []
cluster: null
PRESEED

lxc remote add minimal https://cloud-images.ubuntu.com/minimal/daily --protocol simplestreams --accept-certificate
for I in $(lxc image list minimal: -cfl|awk '/more|CONTAIN/{print $4}'|sort -uV|sed -r '/^t.*|^x.*/!H;//p;$!d;g;s/\n//');do lxc image copy  minimal:${I} local: --alias ${I} --auto-update --public;done
[[ -f /usr/local/bin/add-landscape-clients.sh ]] && { /usr/local/bin/add-landscape-clients.sh; }


exit 0
{ [[ $SM_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }
