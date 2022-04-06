#!/bin/bash
export PROG_DIR="$( cd $(dirname ${0})/.. && pwd )"

if [ ! $(lxc &>/dev/null profile device get default eth0 network;echo $?) -o ! $(lxc &>/dev/null profile device get default root pool;echo $?) ];then printf 1>&2 "\n\nLXD is not configured\x21  Please run lxd init\n\n";exit 1;fi

export PROG_DIR="$( cd $(dirname ${0})/.. && pwd )"
export SHOW_ME_ARCH=$(dpkg --print-architecture)
export LXD_DISK_POOL=default
export LXD_NIC_PARENT_0=lxdbr0
export LXD_NIC_PARENT_1=br-bond0
export LXD_DISK_SIZE_MAAS=50
export LXD_DISK_SIZE_LAND=20
for A in maas landscape;do 
  for P in aws multipass;do
    PROF="${A}-on-${P}"
    lxc 2>/dev/null profile create ${PROF}
    [[ $P = aws ]] && { declare -ag NICS=(ens5); }
    [[ $P = multipass ]] && { declare -ag NICS=(enp0s3 enp0s8); }
    [[ $A = maas ]] && { export LXD_DISK_SIZE=${LXD_DISK_SIZE_MAAS}; }
    [[ $A = landscape ]] && { export LXD_DISK_SIZE=${LXD_DISK_SIZE_LAND}; }
cat <<-EOF|sed -r 's/[ \t]+$//g'|sed -r '/^$/d'|tee ${PROG_DIR}/lxd-profile_${A}-on-${P}_${SHOW_ME_ARCH}.yaml|lxc profile edit ${PROF}
config:
  boot.autostart: "false"
  migration.incremental.memory: "false"
  security.nesting: "true"
  user.network-config: |
    version: 2
    ethernets:
      ens5:
        dhcp4: true
        dhcp6: false
        accept-ra: false
        optional: no
  user.user-data: |
$(cat <<-'YAML'|sed -r 's/^/    /g;s/[ \t]+$//g' < ${PROG_DIR}/${A}/${P}/${P}_show-me_${A}_user-data_${SHOW_ME_ARCH}.yaml
YAML
)
description: 'Simulate running ${A} on ${P}'
devices:
$(if [[ ${#NICS[@]} -eq 2 ]];then
cat <<-NET2
  ${NICS[0]}:
    name: ${NICS[0]}
    nictype: bridged
    parent: ${LXD_NIC_PARENT_0}
    type: nic
  ${NICS[1]}:
    name: ${NICS[1]}
    nictype: bridged
    parent: ${LXD_NIC_PARENT_1}
    type: nic
NET2
elif [[ ${#NICS[@]} -eq 1 ]];then
cat <<-NET1
  ${NICS[0]}:
    name: ${NICS[0]}
    nictype: bridged
    parent: ${LXD_NIC_PARENT_0}
    type: nic
NET1
fi)
  root:
    path: /
    pool: ${LXD_DISK_POOL}
    size: ${LXD_DISK_SIZE}GB
    type: disk
name: ${A}-on-${P}
EOF

[[ ${?} -eq 0 ]] && printf "\e[2G - Successfully created LXD Profile ${PROF}\x21\n"
done
done
