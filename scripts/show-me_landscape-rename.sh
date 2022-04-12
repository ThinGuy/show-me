#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ ${CLOUD_DEBUG} ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

######################################
#####  Rename Landscape Server  ######
######################################

lsctl stop


#### Show Me Params
export CLOUD_LAST_HOSTNAME="$(hostname -s).landscape.ubuntu-show.me"
export CLOUD_BRIDGE_PAIR=$(find /sys/devices -type l ! -path "*virt*" -iname "upper*"|awk '{gsub(/.*net\//,"");gsub(/\/upper_/," ");print $1":"$2}'|sort -uV)
export CLOUD_ETH=${CLOUD_BRIDGE_PAIR%%:*}
export CLOUD_BRIDGE=${CLOUD_BRIDGE_PAIR##*:}
export CLOUD_ARCH="$(dpkg --print-architecture)"
export CLOUD_APP_GIT="https://github.com/ThinGuy/show-me.git"
export CLOUD_APP="landscape"
export CLOUD_DOMAIN="ubuntu-show.me"
export CLOUD_APP_DOMAIN="${CLOUD_APP}.${CLOUD_DOMAIN}"
export CLOUD_DNS_IPV4='1.1.1.1,1.0.0.1'
export CLOUD_FALLBACK_DNS_IPV4='9.9.9.9,149.112.112.112'
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



if [ -n "${CLOUD_IPV6}" ];then
  export CLOUD_DNS_IPV6='2606:4700:4700::1111,2606:4700:4700::1001'
  export CLOUD_FALLBACK_DNS_IPV6='2620:fe::fe,2620:fe::9'
fi

if [ -n "${CLOUD_PUBLIC_IPV4}" -a -z "${CLOUD_IPV6}" ];then
  export CLOUD_DNS="${CLOUD_DNS_IPV4}"
  export CLOUD_FALLBACK_DNS="${CLOUD_FALLBACK_DNS_IPV4}"
elif [ -n "${CLOUD_PUBLIC_IPV4}" -a -n "${CLOUD_IPV6}" ];then
  export CLOUD_DNS="${CLOUD_DNS_IPV4},${CLOUD_DNS_IPV6}"
  export CLOUD_FALLBACK_DNS="${CLOUD_FALLBACK_DNS_IPV4},${CLOUD_FALLBACK_DNS_IPV6}"
fi


### Update DNS Entry
export CLOUDFLARE_DNS_IP="${CLOUD_PUBLIC_IPV4}"
export CLOUDFLARE_DNS_NAME="${CLOUD_APP_FQDN_LONG}"
export CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN}"
export CLOUDFLARE_DNS_ZONE_NAME="ubuntu-show.me"
export CLOUDFLARE_DNS_ZONE_ID="$(curl -sSlL -X GET "https://api.cloudflare.com/client/v4/zones?name=${CLOUDFLARE_DNS_ZONE_NAME}&page=1&per_page=20&order=status&direction=desc&match=all" -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" -H "Content-Type: application/json"|jq -r '.result[].id')"

eval "$(curl -sSlL -X GET "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_DNS_ZONE_ID}/dns_records?name=${CLOUDFLARE_DNS_NAME}" -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" -H "Content-Type: application/json"|jq -r '.result[]|"export CLOUDFLARE_DDNS_RECORD_ID=\(.id) CLOUDFLARE_DDNS_ZONE_ID=\(.zone_id) CLOUDFLARE_DDNS_NAME=\(.name) CLOUDFLARE_DDNS_IP=\(.content)"')"

if [ -n "${CLOUDFLARE_DDNS_RECORD_ID}" ];then

CLOUDFLARE_DNS_UPDATE=$(curl -sSlL -X PUT "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_DDNS_ZONE_ID}/dns_records/${CLOUDFLARE_DDNS_RECORD_ID}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"type":"A","name":"'${CLOUDFLARE_DDNS_NAME}'","content":"'${CLOUDFLARE_DDNS_IP}'","ttl":120,"proxied":false}')

export CLOUDFLARE_DNS_SUCCESSFUL="$(echo "${CLOUDFLARE_DNS_UPDATE}"|jq -r '.success')"

else

CLOUDFLARE_DNS_CREATE=$(curl -sSlL -X POST "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_DNS_ZONE_ID}/dns_records" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'${CLOUDFLARE_DNS_NAME}'","content":"'${CLOUDFLARE_DNS_IP}'","ttl":120,"proxied":false}')

export CLOUDFLARE_DNS_SUCCESSFUL="$(echo "${CLOUDFLARE_DNS_CREATE}"|jq -r '.success')"

fi

#### update the central .show-me.rc then copy to
#### users home dir
install -o 0 -g 0 -m 0755 -d /usr/local/lib/show-me/
((set|grep -E '^CANDID_|^CLOUD_|^LANDSCAPE_|^MAAS_|^PG_|^RBAC_|^SSP_|^MK8S_|^MO7K_|^MCLOUD_')|sed -r 's/^/export /g;s/\x22//g;s/\x27/\x22/g'|sed -r '/=$/d'|sort -uV)|tee /usr/local/lib/show-me/.show-me.rc
if [ -f /usr/local/lib/show-me/.show-me.rc ];then cp /usr/local/lib/show-me/.show-me.rc /root/.;su $(id -un 1000) -c 'cp /usr/local/lib/show-me/.show-me.rc ~/';fi



printf "127.0.0.1\tlocalhost rabbit\n${CLOUD_PUBLIC_IPV4}\t${CLOUD_APP_FQDN_LONG} ${CLOUD_PUBLIC_HOSTNAME}\n\n\n"|tee 1>/dev/null /etc/hosts
if [ -n "${CLOUD_IPV6}" ];then printf "\n\n::1\tip6-localhost ip6-loopback rabbit\n\n${CLOUD_IPV6}\t${CLOUD_APP_FQDN_LONG} ${CLOUD_PUBLIC_HOSTNAME}\n"|tee 1>/dev/null -a /etc/hosts;fi
[ "$(lsb_release -sr|sed 's/\.//g')" -lt "2004" ] && { hostnamectl set-hostname ${CLOUD_APP_FQDN_LONG}; } || { hostnamectl hostname ${CLOUD_APP_FQDN_LONG}; }
echo "${CLOUD_APP_FQDN_LONG}"|tee /etc/hostname
export HOSTNAME="${CLOUD_APP_FQDN_LONG}"

cp /etc/systemd/resolved.conf /etc/systemd/resolved.$$.backup
rm -rf /etc/resolv.conf
cat <<-RESOLV |tee 1>/dev/null /etc/systemd/resolved.conf
[Resolve]
DNS=$(printf "${CLOUD_DNS//,/ }")
FallbackDNS=$(printf "${CLOUD_FALLBACK_DNS//,/ }")
Domains=landscape.ubuntu-show.me ubuntu-show.me ${CLOUD_PUBLIC_DOMAIN} ${CLOUD_LOCAL_DOMAIN}
DNSSEC=allow-downgrade
DNSOverTLS=opportunistic
MulticastDNS=yes
LLMNR=yes
Cache=no-negative
CacheFromLocalhost=no
DNSStubListener=yes
DNSStubListenerExtra='127.0.0.1:9953'
ReadEtcHosts=yes
ResolveUnicastSingleLabel=yes
RESOLV
if [ "${CLOUD_DISTRIB_RELEASE//.}" -lt "2004" ];then sed -r -i '/ReadEtc|DNSOver|Unicast|DNSStub/d' /etc/systemd/resolved.conf;fi
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-networkd systemd-resolved

if [ -n "${CLOUD_PUBLIC_IPV4}" -a -z "${CLOUD_IPV6}" ];then
cat <<-V4NETPLAN |sed -r 's/[ \t]+$//g;/^$/d'|tee 1>/dev/null /etc/netplan/50-cloud-init.yaml
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
        hostname: ${CLOUD_APP_FQDN_LONG}
        use-dns: false
        route-metric: 1
      dhcp6: false
      optional: false
      accept-ra: false
      link-local: [ ]
      parameters:
        priority: 1
        stp: false
V4NETPLAN

elif [ -n "${CLOUD_PUBLIC_IPV4}" -a -n "${CLOUD_IPV6}" ];then

cat <<-V46NETPLAN |sed -r 's/[ \t]+$//g;/^$/d'|tee 1>/dev/null /etc/netplan/50-cloud-init.yaml
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

fi

# Remove older files from previous releases
rm -f /etc/netplan/50-cloud-init_ipv*
# Make sure cloud-init does not overwrite our network config
echo 'network: {config: disabled}'|tee 1>/dev/null /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
### Prefer IPv4 connections
printf '%s\x20%s\x20\x20%s\n' precedence '::ffff:0:0/96' 100|tee 1>/dev/null /etc/gai.conf

#### Apply all networking changes
for NPA in generate generate apply apply;do netplan --debug ${NPA};done

#### Restart the resolver for good measure
systemctl restart systemd-resolved


cp /opt/show-me/scripts/landscape-apache2.conf /etc/apache2/sites-available/landscape.conf



install -o 0 -g 0 -m 0755 /opt/show-me/scripts/add-landscape-clients.sh /usr/local/bin/add-landscape-clients.sh
install -o 0 -g 0 -m 0755 /opt/show-me/scripts/add-landscape-clients-numbered.sh /usr/local/bin/add-landscape-clients-numbered.sh
install -o 1000 -g 1000 -m 0400 /opt/show-me/pki/show-me-id_rsa /home/$(id -un 1000)/.ssh/showme_rsa
install -o 1000 -g 1000 -m 0640 /opt/show-me/pki/show-me-id_rsa.pub /home/$(id -un 1000)/.ssh/showme_rsa.pub
install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_host.pem /etc/ssl/certs/show-me_host.pem
install -o 0 -g 0 -m 0600 /opt/show-me/pki/show-me_host.key /etc/ssl/private/show-me_host.key
install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_host.pem /etc/ssl/certs/landscape_server.pem
install -o 0 -g 0 -m 0600 /opt/show-me/pki/show-me_host.key /etc/ssl/private/landscape_server.key
install -o 0 -g 0 -m 0755 /opt/show-me/scripts/show-me_finishing-script_all.sh /usr/local/bin/show-me_finishing-script_all.sh

install -o 0 -g 0 -m 0644 /opt/show-me/scripts/landscape-apache2.conf /etc/apache2/sites-available/landscape.conf
sed -r -i "s/@hostname@/${CLOUD_APP_FQDN_LONG}/g" /etc/apache2/sites-available/landscape.conf

lsctl start

if [ -f /usr/local/bin/show-me/show-me_finishing-script_all.sh ];then /usr/local/bin/show-me/show-me_finishing-script_all.sh;fi


{ [[ ${CLOUD_DEBUG} ]] &>/dev/null; } && { { set +x; } &>/dev/null; }

exit 0
