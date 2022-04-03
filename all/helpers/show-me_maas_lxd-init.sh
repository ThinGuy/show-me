#!/usr/bin/env bash
# vim: set et ts=2 sw=2 filetype=bash :
[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

cat <<-PRESEED|sed -r 's/[ \t]+$//g'|lxd init --preseed -
config:
  core.https_address: '[::]:8443'
  core.trust_password: ubuntu
networks:
- config:
    dns.domain: ubuntu-show.me
    dns.mode: dynamic
    ipv4.address: 10.10.11.254/24
    ipv4.nat: "true"
    ipv6.address: none
  description: MAAS Network Bridge 1
  name: maas-br1
  type: bridge
  project: default
- config:
    ipv4.address: 10.10.12.254/24
    ipv4.nat: "true"
    ipv6.address: none
  description: MAAS Network Bridge 2
  name: maas-br2
  type: bridge
  project: default
- config:
    ipv4.address: 10.10.13.254/24
    ipv4.nat: "true"
    ipv6.address: none
  description: MAAS Network Bridge 3
  name: maas-br3
  type: bridge
  project: default
- config:
    ipv4.address: 10.10.14.254/24
    ipv4.nat: "true"
    ipv6.address: none
  description: MAAS Network Bridge 4
  name: maas-br4
  type: bridge
  project: default
storage_pools:
- config: {}
  description: ""
  name: default
  driver: dir
profiles:
- config: {}
  description: Default LXD profile
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: br0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
- config:
    boot.autostart: "0"
    migration.incremental.memory: "true"
    security.nesting: "true"
    user.network-config: |
      version: 2
      renderer: networkd
      ethernets:
        eth0:
          dhcp4: "false"
          match:
            name: 'eth0'
          set-name: eth0
        eth1:
          dhcp4: "false"
          match:
            name: 'eth1'
          set-name: eth1
      bridges:
        br0:
          interfaces: ['eth0']
          link-local: [ ]
          dhcp4: "true"
          dhcp4-overrides:
            use-routes: "true"
            use-dns: "false"
            use-domains: "false"
            route-metric: 100
          nameservers:
            addresses:
            - 9.9.9.9
            - 1.1.1.1
            search:
            - ubuntu-show.me
          parameters:
            stp: "false"
            priority: 0
        br1:
          interfaces: ['eth1']
          link-local: [ ]
          dhcp4: "true"
          dhcp4-overrides:
            use-routes: "true"
            use-dns: "false"
            use-domains: "false"
            route-metric: 200
          nameservers:
            addresses:
            - 9.9.9.9
            - 1.1.1.1
            search:
            - ubuntu-show.me
          parameters:
            stp: "false"
            priority: 100
    user.user-data: |
      #cloud-config
      final_message: 'MAAS Target Installed in \$UPTIME'
      locale: 'en_US.UTF-8'
      ssh_pwauth: "true"
      apt:
        primary:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        security:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        sources_list: |
          deb [arch=amd64] \$PRIMARY \$RELEASE main universe restricted multiverse
          deb [arch=amd64] \$PRIMARY \$RELEASE-updates main universe restricted multiverse
          deb [arch=amd64] \$PRIMARY \$RELEASE-backports main universe restricted multiverse
          deb [arch=amd64] \$SECURITY \$RELEASE-security main universe restricted multiverse
        sources:
          maas-3.2-focal.list:
            source: 'deb [arch=amd64] https://ppa.launchpadcontent.net/maas/3.2/ubuntu focal main'
            keyid: 04e7fdc5684d4a1c
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
      package_update: "true"
      package_upgrade: "true"
      packages: [git, jq, maas-common, maas-cli, ntpdate, unzip, vim]
      runcmd:
        # Escape commands and params that we do not want expanded during here doc
        - set -x
        - export DEBIAN_FRONTEND=noninteractive
        - echo $DEFAULT_IP $(hostname -f) $(hostname -s)|tee -a /etc/hosts
        - if [ "\$(readlink -f /etc/resolv.conf)" != "/run/resolvconf/resolv.conf" ];then ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf;fi
        - if \$(test -f /etc/environment);then if ! \$(grep -qE '/snap/bin' /etc/environment);then sed -i '1s|\x22$|\x3a/snap/bin&|g' /etc/environment;fi;fi
        - if \$(test -f /etc/environment);then . /etc/environment;fi
        - su - \$(id -un 1000) -c 'printf "y\n"|ssh-keygen -f ~/.ssh/id_rsa -P ""'
        - su - \$(id -un 1000) -c 'cat ~/.ssh/*.pub|tee 1>/dev/null -a ~/.ssh/authorized_keys'
        - export DEFAULT_IP=\$(ip -o -4 a show dev \$(ip -o route show default|grep -vE '10\.10\.1[0-9]\.'|grep -m1 -oP '(?<=dev )[^ ]+')|grep -m1 -oP '(?<=inet )[^/]+')
        - if \$(test -f /etc/hosts);then sudo sed -i.orig "/127.0.1.1/d;/127.0.0.1/a \$DEFAULT_IP\ \ \$(hostname -f) \$(hostname -s)" /etc/hosts;fi
        - if \$(test -d /proc/sys/net/ipv6/conf);then (find 2>/dev/null /sys/class/net -type l ! -lname "virtual*" -printf 'net.ipv6.conf.%P.disable_ipv6=1\n'|sort -uV)|tee 1>/dev/null /etc/sysctl.d/99-disable-ipv6.conf;fi
        - if \$(test -f /etc/sysctl.d/99-disable-ipv6.conf -a -d /proc/sys/net/ipv6/conf);then sysctl -p /etc/sysctl.d/99-disable-ipv6.conf;fi
        - systemctl restart procps.service
        - update-alternatives --set editor /usr/bin/vim.basic
        - "wget -qO -P /opt/show-me/ http://$DEFAULT_IP:9999/show-me_host.pem"
        - for GROUP in docker kvm libvirt libvirt-qemu lxd maas;do if [ \"$(getent group $GROUP;echo \$?)" = "0" ];then usermod -a -G \$GROUP \$(id -un 1000);fi;done
  description: maas-target profile
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: br0
      type: nic
    root:
      path: /
      pool: default
      type: disk
      size: 6GB
  name: maas-target
- config:
    boot.autostart: "0"
    migration.incremental.memory: "true"
    security.privileged: "true"
    security.nesting: "true"
    user.network-config: |
      version: 2
      renderer: networkd
      ethernets:
        eth0:
          dhcp4: "false"
          match:
            name: 'eth0'
          set-name: eth0
        eth1:
          dhcp4: "false"
          match:
            name: 'eth1'
          set-name: eth1
      bridges:
        br0:
          interfaces: ['eth0']
          link-local: [ ]
          dhcp4: "true"
          dhcp4-overrides:
            use-routes: "true"
            use-dns: "false"
            use-domains: "false"
            route-metric: 200
          nameservers:
            addresses:
            - $DEFAULT_IP
            - 1.1.1.1
            search:
            - ubuntu-show.me
          parameters:
            stp: "false"
            priority: 200
        br1:
          interfaces: ['eth1']
          link-local: [ ]
          dhcp4: "true"
          dhcp4-overrides:
            use-routes: "true"
            use-dns: "false"
            use-domains: "false"
            route-metric: 100
          nameservers:
            addresses:
            - 9.9.9.9
            - 1.1.1.1
            search:
            - ubuntu-show.me
          parameters:
            stp: "false"
            priority: 0
    user.user-data: |
      #cloud-config
      hostname: maas-rack-002
      fqdn: maas-rack-002.ubuntu-show.me
      manage_etc_hosts: "false"
      prefer_fqdn_over_hostname: "true"
      locale: 'en_US.UTF-8'
      ssh_pwauth: "true"
      apt:
        primary:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        security:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        sources_list: |
          deb [arch=amd64] \$PRIMARY \$RELEASE main universe restricted multiverse
          deb [arch=amd64] \$PRIMARY \$RELEASE-updates main universe restricted multiverse
          deb [arch=amd64] \$PRIMARY \$RELEASE-backports main universe restricted multiverse
          deb [arch=amd64] \$SECURITY \$RELEASE-security main universe restricted multiverse
        sources:
          maas-3.2-focal.list:
            source: 'deb [arch=amd64] https://ppa.launchpadcontent.net/maas/3.2/ubuntu focal main'
            keyid: 04e7fdc5684d4a1c
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
      package_update: "true"
      package_upgrade: "true"
      packages: [git, jq, maas-common, maas-cli, ntpdate, unzip, vim]
      runcmd:
        # Escape commands and params that we do not want expanded during here doc
        - set -x
        - ntpdate -u ntp.ubuntu.com
        - export MAAS_SECRET=$(cat /var/snap/maas/current/var/lib/maas/secret)
        - echo ${MAAS_SECRET}|tee 1>/dev/null /opt/show-me/maas-secret
        - export DEBIAN_FRONTEND=noninteractive
        - echo $DEFAULT_IP $(hostname -f) $(hostname -s)|tee -a /etc/hosts
        - if [ "\$(readlink -f /etc/resolv.conf)" != "/run/resolvconf/resolv.conf" ];then ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf;fi
        - if \$(test -f /etc/environment);then if ! \$(grep -qE '/snap/bin' /etc/environment);then sed -i '1s|\x22$|\x3a/snap/bin&|g' /etc/environment;fi;fi
        - if \$(test -f /etc/environment);then . /etc/environment;fi
        - su - \$(id -un 1000) -c 'printf "y\n"|ssh-keygen -f ~/.ssh/id_rsa -P ""'
        - su - \$(id -un 1000) -c 'cat ~/.ssh/*.pub|tee 1>/dev/null -a ~/.ssh/authorized_keys'
        - export DEFAULT_IP=\$(ip -o -4 a show dev \$(ip -o route show default|grep -vE '10\.10\.1[0-9]\.'|grep -m1 -oP '(?<=dev )[^ ]+')|grep -m1 -oP '(?<=inet )[^/]+')
        - if \$(test -f /etc/hosts);then sudo sed -i.orig "/127.0.1.1/d;/127.0.0.1/a \$DEFAULT_IP\ \ \$(hostname -f) \$(hostname -s)" /etc/hosts;fi
        - if \$(test -d /proc/sys/net/ipv6/conf);then (find 2>/dev/null /sys/class/net -type l ! -lname "virtual*" -printf 'net.ipv6.conf.%P.disable_ipv6=1\n'|sort -uV)|tee 1>/dev/null /etc/sysctl.d/99-disable-ipv6.conf;fi
        - if \$(test -f /etc/sysctl.d/99-disable-ipv6.conf -a -d /proc/sys/net/ipv6/conf);then sysctl -p /etc/sysctl.d/99-disable-ipv6.conf;fi
        - systemctl restart procps.service
        - update-alternatives --set editor /usr/bin/vim.basic
        - "wget -qO -P /opt/show-me/ http://$DEFAULT_IP:9999/show-me_host.pem"
        - for GROUP in docker kvm libvirt libvirt-qemu lxd maas;do if [ \"$(getent group $GROUP;echo \$?)" = "0" ];then usermod -a -G \$GROUP \$(id -un 1000);fi;done
        - apt install maas-rack-controller -yqf --auto-remove --purge -o "Acquire::ForceIPv4=true"
        - maas-rack register --url "http://maas.ubuntu-show.me:5240/MAAS" --secret \$MAAS_SECRET
  description: maas-rack-1 profile
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: br0
      type: nic
    eth1:
      name: eth1
      nictype: bridged
      parent: maas-br1
      type: nic
    root:
      path: /
      pool: default
      type: disk
      size: 10GB
  name: maas-rack-1
- config:
    boot.autostart: "0"
    migration.incremental.memory: "true"
    security.privileged: "true"
    security.nesting: "true"
    user.network-config: |
      version: 2
      renderer: networkd
      ethernets:
        eth0:
          dhcp4: "false"
          match:
            name: 'eth0'
          set-name: eth0
        eth1:
          dhcp4: "false"
          match:
            name: 'eth1'
          set-name: eth1
      bridges:
        br0:
          interfaces: ['eth0']
          link-local: [ ]
          dhcp4: "true"
          dhcp4-overrides:
            use-routes: "true"
            use-dns: "false"
            use-domains: "false"
            route-metric: 200
          nameservers:
            addresses:
            - $DEFAULT_IP
            - 1.1.1.1
            search:
            - ubuntu-show.me
          parameters:
            stp: "false"
            priority: 200
        br1:
          interfaces: ['eth1']
          link-local: [ ]
          dhcp4: "true"
          dhcp4-overrides:
            use-routes: "true"
            use-dns: "false"
            use-domains: "false"
            route-metric: 100
          nameservers:
            addresses:
            - 9.9.9.9
            - 1.1.1.1
            search:
            - ubuntu-show.me
          parameters:
            stp: "false"
            priority: 0
    user.user-data: |
      #cloud-config
      hostname: maas-rack-002
      fqdn: maas-rack-002.ubuntu-show.me
      manage_etc_hosts: "false"
      prefer_fqdn_over_hostname: "true"
      ssh_pwauth: "true"
      apt:
        primary:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        security:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        sources_list: |
          deb [arch=amd64] \$PRIMARY \$RELEASE main universe restricted multiverse
          deb [arch=amd64] \$PRIMARY \$RELEASE-updates main universe restricted multiverse
          deb [arch=amd64] \$PRIMARY \$RELEASE-backports main universe restricted multiverse
          deb [arch=amd64] \$SECURITY \$RELEASE-security main universe restricted multiverse
        sources:
          maas-3.2-focal.list:
            source: 'deb [arch=amd64] https://ppa.launchpadcontent.net/maas/3.2/ubuntu focal main'
            keyid: 04e7fdc5684d4a1c
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
      package_update: "true"
      package_upgrade: "true"
      packages: [git, jq, maas-common, maas-cli, ntpdate, unzip, vim]
      runcmd:
        # Escape commands and params that we do not want expanded during here doc
        - set -x
        - export MAAS_SECRET=$(cat /var/snap/maas/current/var/lib/maas/secret)
        - echo ${MAAS_SECRET}|tee 1>/dev/null /opt/show-me/maas-secret
        - export DEBIAN_FRONTEND=noninteractive
        - echo $DEFAULT_IP $(hostname -f) $(hostname -s)|tee -a /etc/hosts
        - if [ "\$(readlink -f /etc/resolv.conf)" != "/run/resolvconf/resolv.conf" ];then ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf;fi
        - if \$(test -f /etc/environment);then if ! \$(grep -qE '/snap/bin' /etc/environment);then sed -i '1s|\x22$|\x3a/snap/bin&|g' /etc/environment;fi;fi
        - if \$(test -f /etc/environment);then . /etc/environment;fi
        - su - \$(id -un 1000) -c 'printf "y\n"|ssh-keygen -f ~/.ssh/id_rsa -P ""'
        - su - \$(id -un 1000) -c 'cat ~/.ssh/*.pub|tee 1>/dev/null -a ~/.ssh/authorized_keys'
        - export DEFAULT_IP=\$(ip -o -4 a show dev \$(ip -o route show default|grep -vE '10\.10\.1[0-9]\.'|grep -m1 -oP '(?<=dev )[^ ]+')|grep -m1 -oP '(?<=inet )[^/]+')
        - if \$(test -f /etc/hosts);then sudo sed -i.orig "/127.0.1.1/d;/127.0.0.1/a \$DEFAULT_IP\ \ \$(hostname -f) \$(hostname -s)" /etc/hosts;fi
        - if \$(test -d /proc/sys/net/ipv6/conf);then (find 2>/dev/null /sys/class/net -type l ! -lname "virtual*" -printf 'net.ipv6.conf.%P.disable_ipv6=1\n'|sort -uV)|tee 1>/dev/null /etc/sysctl.d/99-disable-ipv6.conf;fi
        - if \$(test -f /etc/sysctl.d/99-disable-ipv6.conf -a -d /proc/sys/net/ipv6/conf);then sysctl -p /etc/sysctl.d/99-disable-ipv6.conf;fi
        - systemctl restart procps.service
        - update-alternatives --set editor /usr/bin/vim.basic
        - "wget -qO -P /opt/show-me/ http://$DEFAULT_IP:9999/show-me_host.pem"
        - for GROUP in docker kvm libvirt libvirt-qemu lxd maas;do if [ \"$(getent group $GROUP;echo \$?)" = "0" ];then usermod -a -G \$GROUP \$(id -un 1000);fi;done
        - apt install maas-rack-controller -yqf --auto-remove --purge -o "Acquire::ForceIPv4=true"
        - maas-rack register --url "http://maas.ubuntu-show.me:5240/MAAS" --secret \$MAAS_SECRET
  description: maas-rack-2 profile
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: br0
      type: nic
    eth1:
      name: eth1
      nictype: bridged
      parent: maas-br2
      type: nic
    root:
      path: /
      pool: default
      type: disk
      size: 10GB
  name: maas-rack-2
- config:
    boot.autostart: "0"
    migration.incremental.memory: "true"
    security.privileged: "true"
    security.nesting: "true"
    user.network-config: |
      version: 2
      renderer: networkd
      ethernets:
        eth0:
          dhcp4: "false"
          match:
            name: 'eth0'
          set-name: eth0
        eth1:
          dhcp4: "false"
          match:
            name: 'eth1'
          set-name: eth1
      bridges:
        br0:
          interfaces: ['eth0']
          link-local: [ ]
          dhcp4: "true"
          dhcp4-overrides:
            use-routes: "true"
            use-dns: "false"
            use-domains: "false"
            route-metric: 200
          nameservers:
            addresses:
            - $DEFAULT_IP
            - 1.1.1.1
            search:
            - ubuntu-show.me
          parameters:
            stp: "false"
            priority: 200
        br1:
          interfaces: ['eth1']
          link-local: [ ]
          dhcp4: "true"
          dhcp4-overrides:
            use-routes: "true"
            use-dns: "false"
            use-domains: "false"
            route-metric: 100
          nameservers:
            addresses:
            - $DEFAULT_IP
            - 1.1.1.1
            search:
            - ubuntu-show.me
          parameters:
            stp: "false"
            priority: 0
    user.user-data: |
      #cloud-config
      hostname: maas-rack-003
      fqdn: maas-rack-003.ubuntu-show.me
      manage_etc_hosts: "false"
      prefer_fqdn_over_hostname: "true"
      locale: 'en_US.UTF-8'
      ssh_pwauth: "true"
      apt:
        primary:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        security:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        sources_list: |
          deb [arch=amd64] \$PRIMARY \$RELEASE main universe restricted multiverse
          deb [arch=amd64] \$PRIMARY \$RELEASE-updates main universe restricted multiverse
          deb [arch=amd64] \$PRIMARY \$RELEASE-backports main universe restricted multiverse
          deb [arch=amd64] \$SECURITY \$RELEASE-security main universe restricted multiverse
        sources:
          maas-3.2-focal.list:
            source: 'deb [arch=amd64] https://ppa.launchpadcontent.net/maas/3.2/ubuntu focal main'
            keyid: 04e7fdc5684d4a1c
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
      package_update: "true"
      package_upgrade: "true"
      packages: [git, jq, maas-common, maas-cli, ntpdate, unzip, vim]
      runcmd:
        # Escape commands and params that we do not want expanded during here doc
        - set -x
        - export MAAS_SECRET=$(cat /var/snap/maas/current/var/lib/maas/secret)
        - echo ${MAAS_SECRET}|tee 1>/dev/null /opt/show-me/maas-secret
        - export DEBIAN_FRONTEND=noninteractive
        - echo $DEFAULT_IP $(hostname -f) $(hostname -s)|tee -a /etc/hosts
        - if [ "\$(readlink -f /etc/resolv.conf)" != "/run/resolvconf/resolv.conf" ];then ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf;fi
        - if \$(test -f /etc/environment);then if ! \$(grep -qE '/snap/bin' /etc/environment);then sed -i '1s|\x22$|\x3a/snap/bin&|g' /etc/environment;fi;fi
        - if \$(test -f /etc/environment);then . /etc/environment;fi
        - su - \$(id -un 1000) -c 'printf "y\n"|ssh-keygen -f ~/.ssh/id_rsa -P ""'
        - su - \$(id -un 1000) -c 'cat ~/.ssh/*.pub|tee 1>/dev/null -a ~/.ssh/authorized_keys'
        - export DEFAULT_IP=\$(ip -o -4 a show dev \$(ip -o route show default|grep -vE '10\.10\.1[0-9]\.'|grep -m1 -oP '(?<=dev )[^ ]+')|grep -m1 -oP '(?<=inet )[^/]+')
        - if \$(test -f /etc/hosts);then sudo sed -i.orig "/127.0.1.1/d;/127.0.0.1/a \$DEFAULT_IP\ \ \$(hostname -f) \$(hostname -s)" /etc/hosts;fi
        - if \$(test -d /proc/sys/net/ipv6/conf);then (find 2>/dev/null /sys/class/net -type l ! -lname "virtual*" -printf 'net.ipv6.conf.%P.disable_ipv6=1\n'|sort -uV)|tee 1>/dev/null /etc/sysctl.d/99-disable-ipv6.conf;fi
        - if \$(test -f /etc/sysctl.d/99-disable-ipv6.conf -a -d /proc/sys/net/ipv6/conf);then sysctl -p /etc/sysctl.d/99-disable-ipv6.conf;fi
        - systemctl restart procps.service
        - update-alternatives --set editor /usr/bin/vim.basic
        - "wget -qO -P /opt/show-me/ http://$DEFAULT_IP:9999/show-me_host.pem"
        - for GROUP in docker kvm libvirt libvirt-qemu lxd maas;do if [ \"$(getent group $GROUP;echo \$?)" = "0" ];then usermod -a -G \$GROUP \$(id -un 1000);fi;done
        - apt install maas-rack-controller -yqf --auto-remove --purge -o "Acquire::ForceIPv4=true"
        - maas-rack register --url "http://maas.ubuntu-show.me:5240/MAAS" --secret \$MAAS_SECRET
  description: maas-rack-3 profile
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: br0
      type: nic
    eth1:
      name: eth1
      nictype: bridged
      parent: maas-br3
      type: nic
    root:
      path: /
      pool: default
      type: disk
      size: 10GB
  name: maas-rack-3
- config:
    boot.autostart: "0"
    migration.incremental.memory: "true"
    security.privileged: "true"
    security.nesting: "true"
    user.network-config: |
      version: 2
      renderer: networkd
      ethernets:
        eth0:
          dhcp4: "false"
          match:
            name: 'eth0'
          set-name: eth0
        eth1:
          dhcp4: "false"
          match:
            name: 'eth1'
          set-name: eth1
      bridges:
        br0:
          interfaces: ['eth0']
          link-local: [ ]
          dhcp4: "true"
          dhcp4-overrides:
            use-routes: "true"
            use-dns: "false"
            use-domains: "false"
            route-metric: 200
          nameservers:
            addresses:
            - $DEFAULT_IP
            - 1.1.1.1
            search:
            - ubuntu-show.me
          parameters:
            stp: "false"
            priority: 200
        br1:
          interfaces: ['eth1']
          link-local: [ ]
          dhcp4: "true"
          dhcp4-overrides:
            use-routes: "true"
            use-dns: "false"
            use-domains: "false"
            route-metric: 100
          nameservers:
            addresses:
            - $DEFAULT_IP
            - 1.1.1.1
            search:
            - ubuntu-show.me
          parameters:
            stp: "false"
            priority: 0
    user.user-data: |
      #cloud-config
      hostname: maas-rack-004
      fqdn: maas-rack-004.ubuntu-show.me
      manage_etc_hosts: "false"
      prefer_fqdn_over_hostname: "true"
      locale: 'en_US.UTF-8'
      ssh_pwauth: "true"
      apt:
        primary:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        security:
          - arches: [amd64]
            uri: 'http://us-west-1.ec2.archive.ubuntu.com/ubuntu'
            search: ['http://us-west-1.ec2.archive.ubuntu.com/ubuntu', 'http://us-west-2.ec2.archive.ubuntu.com/ubuntu']
        sources_list: |
          deb [arch=amd64] \$PRIMARY \$RELEASE main universe restricted multiverse
          deb [arch=amd64] \$PRIMARY \$RELEASE-updates main universe restricted multiverse
          deb [arch=amd64] \$PRIMARY \$RELEASE-backports main universe restricted multiverse
          deb [arch=amd64] \$SECURITY \$RELEASE-security main universe restricted multiverse
        sources:
          maas-3.2-focal.list:
            source: 'deb [arch=amd64] https://ppa.launchpadcontent.net/maas/3.2/ubuntu focal main'
            keyid: 04e7fdc5684d4a1c
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
      package_update: "true"
      package_upgrade: "true"
      packages: [git, jq, maas-common, maas-cli, ntpdate, unzip, vim]
      runcmd:
        # Escape commands and params that we do not want expanded during here doc
        - set -x
        - export MAAS_SECRET=$(cat /var/snap/maas/current/var/lib/maas/secret)
        - echo ${MAAS_SECRET}|tee 1>/dev/null /opt/show-me/maas-secret
        - export DEBIAN_FRONTEND=noninteractive
        - echo $DEFAULT_IP $(hostname -f) $(hostname -s)|tee -a /etc/hosts
        - if [ "\$(readlink -f /etc/resolv.conf)" != "/run/resolvconf/resolv.conf" ];then ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf;fi
        - if \$(test -f /etc/environment);then if ! \$(grep -qE '/snap/bin' /etc/environment);then sed -i '1s|\x22$|\x3a/snap/bin&|g' /etc/environment;fi;fi
        - if \$(test -f /etc/environment);then . /etc/environment;fi
        - su - \$(id -un 1000) -c 'printf "y\n"|ssh-keygen -f ~/.ssh/id_rsa -P ""'
        - su - \$(id -un 1000) -c 'cat ~/.ssh/*.pub|tee 1>/dev/null -a ~/.ssh/authorized_keys'
        - export DEFAULT_IP=\$(ip -o -4 a show dev \$(ip -o route show default|grep -vE '10\.10\.1[0-9]\.'|grep -m1 -oP '(?<=dev )[^ ]+')|grep -m1 -oP '(?<=inet )[^/]+')
        - if \$(test -f /etc/hosts);then sudo sed -i.orig "/127.0.1.1/d;/127.0.0.1/a \$DEFAULT_IP\ \ \$(hostname -f) \$(hostname -s)" /etc/hosts;fi
        - if \$(test -d /proc/sys/net/ipv6/conf);then (find 2>/dev/null /sys/class/net -type l ! -lname "virtual*" -printf 'net.ipv6.conf.%P.disable_ipv6=1\n'|sort -uV)|tee 1>/dev/null /etc/sysctl.d/99-disable-ipv6.conf;fi
        - if \$(test -f /etc/sysctl.d/99-disable-ipv6.conf -a -d /proc/sys/net/ipv6/conf);then sysctl -p /etc/sysctl.d/99-disable-ipv6.conf;fi
        - systemctl restart procps.service
        - update-alternatives --set editor /usr/bin/vim.basic
        - "wget -qO -P /opt/show-me/ http://$DEFAULT_IP:9999/show-me_host.pem"
        - for GROUP in docker kvm libvirt libvirt-qemu lxd maas;do if [ \"$(getent group $GROUP;echo \$?)" = "0" ];then usermod -a -G \$GROUP \$(id -un 1000);fi;done
        - apt install maas-rack-controller -yqf --auto-remove --purge -o "Acquire::ForceIPv4=true"
        - maas-rack register --url "http://maas.ubuntu-show.me:5240/MAAS" --secret \$MAAS_SECRET
  description: maas-rack-4 profile
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: br0
      type: nic
    eth1:
      name: eth1
      nictype: bridged
      parent: maas-br4
      type: nic
    root:
      path: /
      pool: default
      type: disk
      size: 10GB
  name: maas-rack-4
projects: []
cluster: null
PRESEED

lxc image copy ubuntu-daily:focal local: --copy-aliases --alias maas-controller-focal --auto-update --public
lxc image copy ubuntu-daily:jammy local: --copy-aliases --alias maas-controller-jammy --auto-update --public
lxc remote add minimal https://cloud-images.ubuntu.com/minimal/daily --protocol simplestreams --accept-certificate
for I in $(lxc image list minimal: -cfl|awk '/more|CONTAIN/{print $4}'|sort -uV|sed -r '/^t.*|^x.*/!H;//p;$!d;g;s/\n//');do ((lxc image copy  minimal:${I} local: --alias ${I} --auto-update --public) &);done

exit 0