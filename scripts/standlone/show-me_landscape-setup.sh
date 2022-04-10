#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ ${CLOUD_DEBUG} ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

#########################################
#####  Base Show Me configuration  ######
#########################################


#### Set locale

export LANG="en_US.UTF-8"
export LANGUAGE="${LANG%%.*}"
[ -n "${LC_ALL}" ] && { unset LC_ALL; }

#### Ensure cloud-init does not change our hostname(s)
if [ /etc/cloud/cloud.cfg ];then sed 's/preserve_hostname: false/preserve_hostname: true/g' -i /etc/cloud/cloud.cfg;fi

#### Show Me Params
export CLOUD_ETH=$(ip -o r l default|grep -m1 -oP "(?<=dev )[^ ]+")
export CLOUD_BRIDGE="br0"
export CLOUD_ARCH="$(dpkg --print-architecture)"
export CLOUD_APP_GIT="https://github.com/ThinGuy/show-me.git"
export CLOUD_APP="landscape"
export CLOUD_DOMAIN="ubuntu-show.me"
export CLOUD_APP_DOMAIN="${CLOUD_APP}.${CLOUD_DOMAIN}"
export CLOUD_DNS=108.162.195.225,162.159.44.225,172.64.35.225
export CLOUD_FALLBACK_DNS=108.162.194.203,162.159.38.203,172.64.34.203
export CLOUD_ETH=$(ip -o r l default|grep -m1 -oP "(?<=dev )[^ ]+")
export CLOUD_BRIDGE="br0"
export CLOUD_ARCH="$(dpkg --print-architecture)"
export CLOUD_APP_GIT="https://github.com/ThinGuy/show-me.git"
export CLOUD_VENDOR="$(dmidecode -s bios-vendor|awk '{print tolower($1)}')"
export CLOUD_ETH=$(ip -o r l default|grep -m1 -oP "(?<=dev )[^ ]+")
export CLOUD_BRIDGE="br0"
export CLOUD_ARCH="$(dpkg --print-architecture)"
export CLOUD_APP_GIT="https://github.com/ThinGuy/show-me.git"
export CLOUD_VENDOR="$(dmidecode -s bios-vendor|awk '{print tolower($1)}')"
export CLOUD_ARCH="$(dpkg --print-architecture)"
#### Dump dmi information as CLOUD_VM_ parameters
eval "$(dmidecode -s 2>&1|awk '/^[ \t]+/{gsub(/^[ \t]+/,"");print}'|xargs -rn1 -P0 bash -c 'P="${0//-/_}";P=${P^^};export P=${P//-/_};printf "export CLOUD_VM_${P}=\x22$(dmidecode -s $0|grep -vi '"'"'not'"'"')\x22\n"'|sed 's/""$//g')"
#### Dump lsb-release info CLOUD_DISTRIB_ parameters
eval "$(cat /etc/lsb-release|sed 's/^/export CLOUD_/g;s/"//g;s,\([^.*]\)=,&",g;s/$/"/')"


##########################################
#####   AWS Show Me configuration   ######
########################################## 
export CLOUD_METADATA_URL="http://169.254.169.254/latest/meta-data"
export CLOUD_API_URL="http://169.254.169.254/latest/api";
export CLOUD_API_TOKEN="$(curl -sSX PUT "${CLOUD_API_URL}/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")"
export CLOUD_BLOCK_DEVICE_MAPPING_AMI="$(curl -sSlL ${CLOUD_METADATA_URL}/block-device-mapping/ami|sed -r '/<|\x22/d')"
export CLOUD_BLOCK_DEVICE_MAPPING_EBSN="$(curl -sSlL ${CLOUD_METADATA_URL}/block-device-mapping/ebsN|sed -r '/<|\x22/d')"
export CLOUD_BLOCK_DEVICE_MAPPING_EPHEMERALN="$(curl -sSlL ${CLOUD_METADATA_URL}/block-device-mapping/ephemeralN|sed -r '/<|\x22/d')"
export CLOUD_BLOCK_DEVICE_MAPPING_ROOT="$(curl -sSlL ${CLOUD_METADATA_URL}/block-device-mapping/root|sed -r '/<|\x22/d')"
export CLOUD_BLOCK_DEVICE_MAPPING_SWAP="$(curl -sSlL ${CLOUD_METADATA_URL}/block-device-mapping/swap|sed -r '/<|\x22/d')"
export CLOUD_ELASTIC_GPUS_ASSOCIATIONS_ELASTIC_GPU_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/elastic-gpus/associations/elastic-gpu-id|sed -r '/<|\x22/d')"
export CLOUD_ELASTIC_INFERENCE_ASSOCIATIONS_EIA_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/elastic-inference/associations/eia-id|sed -r '/<|\x22/d')"
export CLOUD_EVENTS_MAINTENANCE_HISTORY="$(curl -sSlL ${CLOUD_METADATA_URL}/events/maintenance/history|sed -r '/<|\x22/d')"
export CLOUD_EVENTS_MAINTENANCE_SCHEDULED="$(curl -sSlL ${CLOUD_METADATA_URL}/events/maintenance/scheduled|sed -r '/<|\x22/d')"
export CLOUD_EVENTS_RECOMMENDATIONS_REBALANCE="$(curl -sSlL ${CLOUD_METADATA_URL}/events/recommendations/rebalance|sed -r '/<|\x22/d')"
export CLOUD_HOSTNAME="$(curl -sSlL ${CLOUD_METADATA_URL}/hostname|sed -r '/<|\x22/d')"
export CLOUD_IAM_INFO="$(curl -sSlL ${CLOUD_METADATA_URL}/iam/info|sed -r '/<|\x22/d')"
export CLOUD_IAM_SECURITY_CREDENTIALS_ROLE_NAME="$(curl -sSlL ${CLOUD_METADATA_URL}/iam/security-credentials/role-name|sed -r '/<|\x22/d')"
export CLOUD_IDENTITY_CREDENTIALS_EC2_INFO="$(curl -sSlL ${CLOUD_METADATA_URL}/identity-credentials/ec2/info|sed -r '/<|\x22/d')"
export CLOUD_IDENTITY_CREDENTIALS_EC2_SECURITY_CREDENTIALS_EC2_INSTANCE="$(curl -sSlL ${CLOUD_METADATA_URL}/identity-credentials/ec2/security-credentials/ec2-instance|sed -r '/<|\x22/d')"
export CLOUD_INSTANCE_ACTION="$(curl -sSlL ${CLOUD_METADATA_URL}/instance-action|sed -r '/<|\x22/d')"
export CLOUD_INSTANCE_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/instance-id|sed -r '/<|\x22/d')"
export CLOUD_INSTANCE_LIFE_CYCLE="$(curl -sSlL ${CLOUD_METADATA_URL}/instance-life-cycle|sed -r '/<|\x22/d')"
export CLOUD_INSTANCE_TYPE="$(curl -sSlL ${CLOUD_METADATA_URL}/instance-type|sed -r '/<|\x22/d')"
export CLOUD_IPV6="$(curl -sSlL ${CLOUD_METADATA_URL}/ipv6|sed -r '/<|\x22/d')"
export CLOUD_KERNEL_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/kernel-id|sed -r '/<|\x22/d')"
export CLOUD_LOCAL_FQDN="$(curl -sSlL ${CLOUD_METADATA_URL}/local-hostname|sed -r '/<|\x22/d')"
export CLOUD_LOCAL_HOSTNAME="${CLOUD_LOCAL_FQDN%%.*}"
export CLOUD_SERVICES_LOCAL_DOMAIN="${CLOUD_LOCAL_FQDN##*.}"
export CLOUD_LOCAL_IPV4="$(curl -sSlL ${CLOUD_METADATA_URL}/local-ipv4|sed -r '/<|\x22/d')"
export CLOUD_MAC="$(curl -sSlL ${CLOUD_METADATA_URL}/mac|sed -r '/<|\x22/d')"
export CLOUD_METRICS_VHOSTMD="$(curl -sSlL ${CLOUD_METADATA_URL}/metrics/vhostmd|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_DEVICE_NUMBER="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/device-number|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_INTERFACE_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/interface-id|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_IPV4_ASSOCIATIONS_PUBLIC_IP="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/ipv4-associations/public-ip|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_IPV6S="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/ipv6s|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_LOCAL_HOSTNAME="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/local-hostname|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_LOCAL_IPV4S="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/local-ipv4s|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_MAC="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/mac|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_NETWORK_CARD_INDEX="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/network-card-index|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_OWNER_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/owner-id|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_PUBLIC_HOSTNAME="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/public-hostname|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_PUBLIC_IPV4S="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/public-ipv4s|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_SECURITY_GROUPS="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/security-groups|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_SECURITY_GROUP_IDS="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/security-group-ids|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_SUBNET_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/subnet-id|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_SUBNET_IPV4_CIDR_BLOCK="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/subnet-ipv4-cidr-block|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_SUBNET_IPV6_CIDR_BLOCKS="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/subnet-ipv6-cidr-blocks|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_VPC_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/vpc-id|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_VPC_IPV4_CIDR_BLOCK="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/vpc-ipv4-cidr-block|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_VPC_IPV4_CIDR_BLOCKS="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/vpc-ipv4-cidr-blocks|sed -r '/<|\x22/d')"
export CLOUD_NIM_MAC_VPC_IPV6_CIDR_BLOCKS="$(curl -sSlL ${CLOUD_METADATA_URL}/network/interfaces/macs/mac/vpc-ipv6-cidr-blocks|sed -r '/<|\x22/d')"
export CLOUD_PLACEMENT_AVAILABILITY_ZONE="$(curl -sSlL ${CLOUD_METADATA_URL}/placement/availability-zone|sed -r '/<|\x22/d')"
export CLOUD_PLACEMENT_AVAILABILITY_ZONE_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/placement/availability-zone-id|sed -r '/<|\x22/d')"
export CLOUD_PLACEMENT_GROUP_NAME="$(curl -sSlL ${CLOUD_METADATA_URL}/placement/group-name|sed -r '/<|\x22/d')"
export CLOUD_PLACEMENT_HOST_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/placement/host-id|sed -r '/<|\x22/d')"
export CLOUD_PLACEMENT_PARTITION_NUMBER="$(curl -sSlL ${CLOUD_METADATA_URL}/placement/partition-number|sed -r '/<|\x22/d')"
export CLOUD_PLACEMENT_REGION="$(curl -sSlL ${CLOUD_METADATA_URL}/placement/region|sed -r '/<|\x22/d')"
export CLOUD_PRODUCT_CODES="$(curl -sSlL ${CLOUD_METADATA_URL}/product-codes|sed -r '/<|\x22/d')"
export CLOUD_PUBLIC_IPV4="$(curl -sSlL ${CLOUD_METADATA_URL}/public-ipv4|sed -r '/<|\x22/d')"
export CLOUD_PUBLIC_FQDN="$(dig +short -x $(dig +short myip.opendns.com @resolver1.opendns.com) @resolver1.opendns.com|sed 's,\.$,,g')"
export CLOUD_PUBLIC_FQDN="$(dig +short -x $(dig +short myip.opendns.com @resolver1.opendns.com) @resolver1.opendns.com|sed 's,\.$,,g')"
[ -z "${CLOUD_PUBLIC_FQDN}" ] && { export CLOUD_PUBLIC_FQDN="${CLOUD_PUBLIC_HOSTNAME}.${CLOUD_PLACEMENT_REGION}.compute.${CLOUD_SERVICES_DOMAIN}"; }
[ -z "${CLOUD_PUBLIC_FQDN}" ] && export CLOUD_PUBLIC_FQDN="$(dig +short -x $(dig +short myip.opendns.com @resolver1.opendns.com) @resolver1.opendns.com|sed 's,\.$,,g')"
export CLOUD_PUBLIC_HOSTNAME="$(curl -sSlL ${CLOUD_METADATA_URL}/public-hostname|sed -r 's/\..*$//g;/<|\x22/d')"
[ -z "${CLOUD_PUBLIC_HOSTNAME}" ] && { export CLOUD_PUBLIC_HOSTNAME="$(dig +short -x $(dig +short myip.opendns.com @resolver1.opendns.com) @resolver1.opendns.com|sed 's,\.$,,g'|sed 's/\..*$//1')"; }
[ -z "${CLOUD_PUBLIC_HOSTNAME}" -a -n "${CLOUD_PUBLIC_FQDN}" ] && { export CLOUD_PUBLIC_HOSTNAME="${CLOUD_PUBLIC_FQDN%%.*}"; }
export CLOUD_PUBLIC_DOMAIN="${CLOUD_PLACEMENT_REGION}.compute.${CLOUD_SERVICES_DOMAIN}"
export CLOUD_LOCAL_DOMAIN="${CLOUD_PLACEMENT_REGION}.compute.${CLOUD_SERVICES_LOCAL_DOMAIN}"
export CLOUD_LOCAL_FQDN="${CLOUD_LOCAL_HOSTNAME}.${CLOUD_PLACEMENT_REGION}.compute.${CLOUD_SERVICES_LOCAL_DOMAIN}"
export CLOUD_PARTITION="$(curl -sSlL ${CLOUD_METADATA_URL}/services/partition)"
export CLOUD_PUBLIC_KEYS_0_OPENSSH_KEY="$(curl -sSlL ${CLOUD_METADATA_URL}/public-keys/0/openssh-key|sed -r '/<|\x22/d')"
export CLOUD_RAMDISK_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/ramdisk-id|sed -r '/<|\x22/d')"
export CLOUD_RESERVATION_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/reservation-id|sed -r '/<|\x22/d')"
export CLOUD_SECURITY_GROUPS="$(curl -sSlL ${CLOUD_METADATA_URL}/security-groups|sed -r '/<|\x22/d')"
export CLOUD_SERVICES_DOMAIN="$(curl -sSlL ${CLOUD_METADATA_URL}/services/domain|sed -r '/<|\x22/d')"
export CLOUD_SERVICES_SUBDOMAIN="$(dmidecode -s bios-vendor|awk '{print tolower($2)}')"
export CLOUD_SERVICES_PARTITION="$(curl -sSlL ${CLOUD_METADATA_URL}/services/partition|sed -r '/<|\x22/d')"
export CLOUD_SPOT_INSTANCE_ACTION="$(curl -sSlL ${CLOUD_METADATA_URL}/spot/instance-action|sed -r '/<|\x22/d')"
export CLOUD_SPOT_TERMINATION_TIME="$(curl -sSlL ${CLOUD_METADATA_URL}/spot/termination-time|sed -r '/<|\x22/d')"
export CLOUD_TAGS_INSTANCE="$(curl -sSlL ${CLOUD_METADATA_URL}/tags/instance|sed -r '/<|\x22/d')"
export CLOUD_SERVICES_LOCAL_DOMAIN="internal"
export CLOUD_PUBLIC_FQDN="${CLOUD_PUBLIC_HOSTNAME}.${CLOUD_PLACEMENT_REGION}.compute.${CLOUD_SERVICES_DOMAIN}"
export CLOUD_PUBLIC_DOMAIN="${CLOUD_PLACEMENT_REGION}.compute.${CLOUD_SERVICES_DOMAIN}"
export CLOUD_LOCAL_DOMAIN="${CLOUD_PLACEMENT_REGION}.compute.${CLOUD_SERVICES_LOCAL_DOMAIN}"
export CLOUD_PARTITION="$(curl -sSlL ${CLOUD_METADATA_URL}/services/partition)"
export CLOUD_REPO_FQDN="${CLOUD_PLACEMENT_REGION}.${CLOUD_SERVICES_SUBDOMAIN}.archive.ubuntu.com"
export CLOUD_DOMAIN_SEARCH="${CLOUD_APP_DOMAIN},${CLOUD_DOMAIN},${CLOUD_PUBLIC_DOMAIN}"
export CLOUD_APP_FQDN_SHORT="${CLOUD_PUBLIC_HOSTNAME}.${CLOUD_DOMAIN}"
export CLOUD_APP_FQDN_LONG="${CLOUD_PUBLIC_HOSTNAME}.${CLOUD_APP_DOMAIN}"

#### Create ~/.show-me.rc in a centralized location, then copy to 
#### users home dir and ensure it loads when they log on
install -o 0 -g 0 -m 0755 -d /usr/local/lib/show-me/
((set|grep -E '^CANDID_|^CLOUD_|^LANDSCAPE_|^MAAS_|^PG_|^RBAC_|^SSP_|^MK8S_|^MO7K_|^MCLOUD_')|sed -r 's/^/export /g;s/\x22//g;s/\x27/\x22/g'|sed -r '/=$/d'|sort -uV)|tee /usr/local/lib/show-me/.show-me.rc
if [ -f /usr/local/lib/show-me/.show-me.rc ];then cp /usr/local/lib/show-me/.show-me.rc /root/.;su $(id -un 1000) -c 'cp /usr/local/lib/show-me/.show-me.rc ~/';echo '[ -r ~/.show-me.rc ] && . ~/.show-me.rc'|tee -a /root/.bashrc|su $(id -un 1000) -c 'tee -a ~/.bashrc';fi



if [ /etc/cloud/cloud.cfg ];then sed 's/preserve_hostname: false/preserve_hostname: true/g' -i /etc/cloud/cloud.cfg;fi

printf "127.0.0.1\tlocalhost\n${CLOUD_PUBLIC_IPV4}\t$CLOUD_APP_FQDN_LONG $CLOUD_PUBLIC_FQDN $CLOUD_PUBLIC_HOSTNAME\n\n\n::1\tip6-localhost ip6-loopback\n${CLOUD_IPV6}\t$CLOUD_APP_FQDN_LONG $CLOUD_PUBLIC_FQDN $CLOUD_PUBLIC_HOSTNAME\n"|tee /etc/hosts

[ "$(lsb_release -sr|sed 's/\.//g')" -lt "2004" ] && { hostnamectl set-hostname ${CLOUD_APP_FQDN_LONG}; } || { hostnamectl hostname ${CLOUD_APP_FQDN_LONG}; }
echo "${CLOUD_APP_FQDN_LONG}"|tee /etc/hostname
export HOSTNAME="${CLOUD_APP_FQDN_LONG}"

cp /etc/systemd/resolved.conf /etc/systemd/resolved.backup
rm -rf /etc/resolv.conf
RESOLVED="DNS,FallbackDNS,Domains,LLMNR,MulticastDNS,DNSSEC,DNSOverTLS,Cache,DNSStubListener,ReadEtcHosts"
DNS=$(echo -en "${CLOUD_DNS//,/\ }")
FallbackDNS=$(echo -en "${CLOUD_FALLBACK_DNS//,/\ }")
Domains=$(echo -en "${CLOUD_DOMAINS//,/\ }")
LLMNR=yes
MulticastDNS=yes
DNSSEC=allow-downgrade
DNSOverTLS=opportunistic
Cache=no-negative
DNSStubListener=yes
ReadEtcHosts=yes

(for x in ${RESOLVED//,/\ };do if [ -n "$(eval echo -n \"\$${x}\")" ];then printf "${x}=$(eval echo -n \$$x|sed -r 's/,/\x20/g')\n";fi;done) | \
if [ "${CLOUD_DISTRIB_RELEASE//.}" -lt "2004" ];then sed -r '/ReadEtc|DNSOver/d';fi|sudo tee 1>/dev/null /etc/systemd/resolved.conf

ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-networkd systemd-resolved


[ -f  /etc/netplan/50-cloud-init.yaml ] && rm -f /etc/netplan/50-cloud-init.yaml

cat <<-V4NETPLAN|sed -r 's/[ \t]+$//g;/^$/d'|tee 1>/dev/null /etc/netplan/50-cloud-init_ipv4.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ${CLOUD_ETH}:
      dhcp4: false
      dhcp6: false
      optional: false
      accept-ra: false
      link-local: [ ]
      match:
        macaddress: '${CLOUD_MAC}'
      set-name: ${CLOUD_ETH}
  bridges:
    ${CLOUD_BRIDGE}:
      macaddress: '${CLOUD_MAC}'
      interfaces: ['${CLOUD_ETH}']
      link-local: [ ]
      dhcp4: true
      dhcp4-overrides:
        use-hostname: false
        hostname: ${CLOUD_APP_FQDN_SHORT}
        use-dns: false
        route-metric: 1
      dhcp6: false
      optional: false
      accept-ra: false
      link-local: [ ]
      nameservers:
        addresses: [${CLOUD_DNS}]
        search: [${CLOUD_PUBLIC_DOMAIN},${CLOUD_LOCAL_DOMAIN},~${SM_DOMAIN}]
      parameters:
        priority: 1
        stp: false
V4NETPLAN


cat <<-V6NETPLAN|sed -r 's/[ \t]+$//g;/^$/d'|tee 1>/dev/null /etc/netplan/50-cloud-init_ipv6.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ${CLOUD_ETH}:
      dhcp4: false
      dhcp6: false
      optional: false
      accept-ra: false
      link-local: [ ]
      match:
        macaddress: '${CLOUD_MAC}'
      set-name: ${CLOUD_ETH}
  bridges:
    ${CLOUD_BRIDGE}:
      macaddress: '${CLOUD_MAC}'
      interfaces: ['${CLOUD_ETH}']
      link-local: [ ]
      dhcp4: true
      dhcp4-overrides:
        route-metric: 1
      dhcp6: true
      dhcp6-overrides:
        route-metric: 1
      optional: false
      accept-ra: false
      link-local: [ ]
      parameters:
        priority: 1
        stp: false
V46NETPLAN

[ -n "${CLOUD_IPV6}" ] && { rm -f /etc/netplan/50-cloud-init_ipv4.yaml; } ||  { rm -f /etc/netplan/50-cloud-init_ipv6.yaml; }

# Make sure cloud-init does not overwrite our network config
echo 'network: {config: disabled}'|tee 1>/dev/null /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

### Prefer IPv4 connections
printf '%s\x20%s\x20\x20%s\n' precedence '::ffff:0:0/96' 100|tee -a /etc/gai.conf

#### Apply all networking changes
for NPA in generate generate apply apply;do netplan --debug ${NPA};done

#### Restart the resolver for good measure
systemcl restart systemd-resolved


#### Add Regional Ubuntu Repositories

cat <<REPOS|sed -r 's/[ \t]+$//g'|tee 1>/dev/null /etc/apt/sources.list
deb [arch=${CLOUD_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs) main restricted universe multiverse
deb [arch=${CLOUD_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse
deb [arch=${CLOUD_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse
deb [arch=${CLOUD_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs)-security main restricted universe multiverse
deb [arch=${CLOUD_ARCH}] http://archive.canonical.com/ubuntu $(lsb_release -cs) partner
REPOS

#### Update Package indexes

apt -o "Acquire::ForceIPv4=true" update




################################################
###### Application specific configuration ######
################################################

#### Add Landscape Server Package Archive
add-apt-repository ppa:landscape/19.10 -y

apt -o "Acquire::ForceIPv4=true" update;
apt dist-upgrade -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge;
apt remove lxd lxd-client -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge;
DEBIAN_FRONTEND=noninteractive apt install build-essential curl debconf-utils dnsutils git gnupg jq lynx make p7zip p7zip-full software-properties-common ssl-cert tree unzip vim wget zip -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge;


cat <<-'SUDOERS'|sed -r 's/[ \t]+$//g;/^$/d'|tee 1>/dev/null /etc/sudoers.d/100-keep-params
Defaults env_keep+="CANDID_* CLOUD_* LANDSCAPE_* MAAS_* PG_* RBAC_* SSP_* MK8S_* MO7K_* MCLOUD_* CANDID_* CLOUD_* DISPLAY EDITOR HOME LANDSCAPE_* LANG LC_* MAAS_* MACHINE_* PG_* PYTHONWARNINGS RBAC_* SSP_* XAUTHORITY XAUTHORIZATION *_PROXY *_proxy"
SUDOERS

if [ -f ~/.show-me.rc ];then . ~/.show-me.rc;fi;
mkdir -p /etc/show-me/www /etc/show-me/log;
if [ -d /opt/show-me ];then rm -rf /opt/show-me;fi;

git clone ${CLOUD_APP_GIT} /opt/show-me;


install -o 0 -g 0 -m 0755 /opt/show-me/scripts/petname-helper.sh /usr/local/bin/petname-helper.sh
install -o 0 -g 0 -m 0755 /opt/show-me/scripts/show-me_lynx-web-init.sh /usr/local/bin/show-me_lynx-web-init.sh
install -o 0 -g 0 -m 0755 /opt/show-me/scripts/add-landscape-clients.sh /usr/local/bin/add-landscape-clients.sh
install -o 1000 -g 1000 -m 0400 /opt/show-me/pki/show-me-id_rsa /home/$(id -un 1000)/.ssh/showme_rsa
install -o 1000 -g 1000 -m 0640 /opt/show-me/pki/show-me-id_rsa.pub /home/$(id -un 1000)/.ssh/showme_rsa.pub
install -o 0 -g 0 -m 0644 -D /opt/show-me/scripts/landscape.lynx /usr/local/lib/show-me/landscape.lynx
install -o 0 -g 0 -m 0755 -d /usr/local/lib/show-me/petname2/
install -o 0 -g 0 -m 0755 -d /etc/landscape/
install -o 0 -g 0 -m 0755 /opt/show-me/scripts/show-me_landscape_lxd-init.sh /usr/local/bin/show-me_landscape_lxd-init.sh
install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_host.pem /etc/ssl/certs/show-me_host.pem
install -o 0 -g 0 -m 0600 /opt/show-me/pki/show-me_host.key /etc/ssl/private/show-me_host.key
install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_ca.crt /etc/ssl/certs/show-me_ca.crt
install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_ca.crt /usr/local/share/ca-certificates/show-me_ca.crt
install -o 0 -g 0 -m 0600 /opt/show-me/pki/show-me_basic-chain.pem /etc/ssl/private/show-me_basic-chain.pem
install -o 0 -g 0 -m 0600 /opt/show-me/pki/show-me_full-chain.pem /etc/ssl/private/show-me_full-chain.pem   
install -o 0 -g 0 -m 0600 /opt/show-me/pki/show-me_basic-chain.pem /etc/ssl/private/landscape-server_basic-chain.pem
install -o 0 -g 0 -m 0600 /opt/show-me/pki/show-me_full-chain.pem /etc/ssl/private/landscape-server_full-chain.pem    
install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_host.pem /etc/ssl/certs/landscape_server.pem
install -o 0 -g 0 -m 0600 /opt/show-me/pki/show-me_host.key /etc/ssl/private/landscape_server.key
install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_ca.crt /etc/ssl/certs/landscape_server_ca.crt
install -o 0 -g 0 -m 0755 /opt/show-me/scripts/show-me_file-service_init.sh /usr/local/bin/show-me_file-service_init.sh
install -o 0 -g 0 -m 0755 /opt/show-me/scripts/show-me_finishing-script_all.sh /usr/local/bin/show-me_finishing-script_all.sh
install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_ca.crt /etc/show-me/www/show-me_ca.crt
install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_host.pem /etc/show-me/www/landscape_server.pem
update-ca-certificates --fresh --verbose

if [ -f /home/$(id -un 1000)/.ssh/showme_rsa.pub ];then su $(id -un 1000) -c 'cat /home/$(id -un 1000)/.ssh/showme_rsa.pub|tee -a 1>/dev/null /home/$(id -un 1000)/.ssh/authorized_keys';fi

export LANG="en_US.UTF-8"
export LANGUAGE="${LANG%%.*}"
[ -n "${LC_ALL}" ] && { unset LC_ALL; }
sudo locale-gen ${LANG:-en_US.UTF-8}
sudo locale-gen ${LANGUAGE:-en_US}
export LANG=${LANG:-en_US.UTF-8} LANGUAGE=${LANGUAGE:-en_US}
sudo update-locale LANG=${LANG:-en_US.UTF-8} LANGUAGE=${LANGUAGE:-en_US}
((printf "%s=${LANG}\n" LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION)|sed -r '2s/^/LANGUAGE='${LANG%%.*}'\n/g')|tee /etc/default/locale
echo -en 'locales\tlocales/locales_to_be_generated\tmultiselect\t'${LANGUAGE:-en_US}' ISO-8859-1, '${LANG:-en_US.UTF-8}' UTF-8'|debconf-set-selections
echo -en 'locales\tlocales/default_environment_locale\tselect\t'${LANG:-en_US.UTF-8}''|debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

apt -o "Acquire::ForceIPv4=true" update;
apt dist-upgrade -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge;
apt install landscape-client -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge --reinstall;

if [ -f /etc/ssl/certs/landscape_server.pem ];then ln -sf /etc/ssl/certs/landscape_server.pem /etc/landscape/landscape_server.pem;fi;
if [ -f /etc/ssl/certs/landscape_server_ca.crt ];then ln -sf /etc/ssl/certs/landscape_server_ca.crt /etc/landscape/landscape_server_ca.crt;fi;
if [ -f /etc/ssl/certs/landscape_server.pem ];then echo "ssl_public_key = /etc/ssl/certs/landscape_server.pem"|tee 1>/dev/null -a /etc/landscape/client.conf;fi;

apt install landscape-server-quickstart --reinstall -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge;

if [ -f /usr/local/lib/show-me/landscape.lynx -a -f /usr/local/bin/show-me_lynx-web-init.sh ];then /usr/local/bin/show-me_lynx-web-init.sh;fi
if [ -f /etc/landscape/client.conf ];then ln -sf /etc/landscape/client.conf /etc/show-me/www/landscape-client.conf;fi

landscape-config -k /etc/landscape/landscape_server.pem -t $(hostname -s) -u "https://${CLOUD_PUBLIC_FQDN}/message-system" --ping-url "http://${CLOUD_PUBLIC_FQDN}/ping" -a standalone --http-proxy= --https-proxy= --script-users=ALL --access-group=global --tags=show-me-demo,ubuntu --silent --log-level=debug
if $(test -n "$(command 2>/dev/null -v lxd.lxc)");then su - $(id -un 1000) -c 'sudo snap refresh lxd --channel latest/stable';else su - $(id -un 1000) -c 'sudo snap install lxd';fi
if [ -f /usr/local/bin/show-me_landscape_lxd-init.sh ];then /usr/local/bin/show-me_landscape_lxd-init.sh;fi
if [ -f /usr/local/bin/show-me_file-service_init.sh ];then /usr/local/bin/show-me_file-service_init.sh;fi
if [ -f /usr/local/bin/show-me/show-me_finishing-script_all.sh ];then /usr/local/bin/show-me/show-me_finishing-script_all.sh;fi


ua detach --assume-yes
rm -rf /var/log/ubuntu-advantage.log
truncate -s 0 /etc/machine-id
truncate -s 0 /var/lib/dbus/machine-id
rm -rf /opt/show-me
find /var/log -type f |xargs truncate -s 0

{ [[ ${CLOUD_DEBUG} ]] &>/dev/null; } && { { set +x; } &>/dev/null; }

history -c
unset HISTFILE

https://us-west-1.console.aws.amazon.com/ec2/v2/home?region=us-west-1#AMICatalog:
exit



