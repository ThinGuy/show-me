#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ ${CLOUD_DEBUG} ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }


######################################
#####  Rename Landscape Server  ######
######################################

#### Ensure landscape is stopped
command -v lsctl && { lsctl stop; }


#### Create copy of last show-me.rc incase we need to trouble shoot differences on machine
#### types
if [ -f ~/.show-me.rc ];then mv ~/.{show-me,last.show-me}.rc;fi;
if [ -f /home/$(id -un 1000)/.show-me.rc ];then su $(id -un 1000) -c 'mv ~/.{show-me,last.show-me}.rc';fi
#### unset CLOUD_* variables loaded via .bashrc
unset $(set|grep -oE '^CLOUD_[^=]+'|paste -sd' ')


#### Show Me Params
export CLOUD_BRIDGE="br0"
export CLOUD_ETH=$(ip -o r l default|grep -m1 -oP "(?<=dev )[^ ]+")
[ "${CLOUD_ETH}" = "${CLOUD_BRIDGE}" ] && { export CLOUD_ETH=$(find /sys/devices -type l ! -path "*virt*" -iname "upper*"|awk '{gsub(/.*net\//,"");gsub(/\/upper_/," ");print $1}'|sort -uV); }
export CLOUD_ARCH="$(dpkg --print-architecture)"
export CLOUD_APP_GIT="https://github.com/ThinGuy/show-me.git"
export CLOUD_APP="landscape"
export CLOUD_DOMAIN="ubuntu-show.me"
export CLOUD_APP_DOMAIN="${CLOUD_APP}.${CLOUD_DOMAIN}"
export CLOUD_DNS_IPV4='1.1.1.1,1.0.0.1'
export CLOUD_FALLBACK_DNS_IPV4='9.9.9.9,149.112.112.112'
export CLOUD_VENDOR="$(dmidecode -s bios-vendor|awk '{print tolower($1)}')"
[ "${CLOUD_VENDOR}" = "xen" ] && { export CLOUD_VENDOR=aws; }
#### Dump dmi information as CLOUD_VM_ parameters
eval "$(dmidecode -s 2>&1|awk '/^[ \t]+/{gsub(/^[ \t]+/,"");print}'|xargs -rn1 -P0 bash -c 'P="${0//-/_}";P=${P^^};export P=${P//-/_};printf "export CLOUD_VM_${P}=\x22$(dmidecode -s $0|grep -vi '"'"'not'"'"')\x22\n"'|sed -r 's/""$//g;s/Xen|xen/aws/g')"
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
[ -z "${CLOUD_SERVICES_SUBDOMAIN}" -o "${CLOUD_SERVICES_SUBDOMAIN,,}" = "xen" -o "${CLOUD_SERVICES_SUBDOMAIN,,}" = "" ] && { export CLOUD_SERVICES_SUBDOMAIN="ec2"; }
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
eval $(curl -sSLL https://bit.ly/3uyZjU0)
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

#### Create ~/.show-me.rc in a centralized location, then copy to
#### users home dir and ensure it loads when they log on
install -o 0 -g 0 -m 0755 -d /usr/local/lib/show-me/
((set|grep -E '^CANDID_|^CLOUD_|^LANDSCAPE_|^MAAS_|^PG_|^RBAC_|^SSP_|^MK8S_|^MO7K_|^MCLOUD_')|sed -r 's/^/export /g;s/\x22//g;s/\x27/\x22/g'|sed -r '/=$/d;s/Xen|xen/aws/g'|sort -uV)|tee /usr/local/lib/show-me/.show-me.rc
if [ -f /usr/local/lib/show-me/.show-me.rc ];then cp /usr/local/lib/show-me/.show-me.rc /root/.;su $(id -un 1000) -c 'sed "/.show-me.rc/d" -i ~/.bashrc;cp /usr/local/lib/show-me/.show-me.rc ~/';sed -r -i '/.show-me.rc/d' ~/.bashrc;echo '[ -r ~/.show-me.rc ] && . ~/.show-me.rc'|tee -a /root/.bashrc|su $(id -un 1000) -c 'tee -a ~/.bashrc';fi

#### Unset current variables and reload edited version
if [ -f ~/.show-me.rc ];then unset $(set|grep -oE '^CLOUD_[^=]+'|paste -sd' ');. ~/.show-me.rc;fi;

#### Set hostname under loopback
sed -i -r '/127.0.1.1/d;s/^127.0.0.1.*$/127.0.0.1 localhost rabbit\n127.0.1.1 '${CLOUD_APP}' '${CLOUD_APP_FQDN_LONG}' '${CLOUD_PUBLIC_HOSTNAME}' '${CLOUD_LOCAL_HOSTNAME}'\n/' /etc/hosts

#### Copy and install github scripts
if [ -d /opt/show-me ];then { cd /opt/show-me && git pull; } else git clone ${CLOUD_APP_GIT} /opt/show-me;fi

install -o 0 -g 0 -m 0755 -d /usr/local/lib/show-me/
find /opt/show-me/scripts -type f -name "*.sh" -exec install -o0 -g0 -m0755 {} /usr/local/bin/ \;
find /opt/show-me/scripts -type f -name "*.lynx" -exec install -o0 -g0 -m0644 {} /usr/local/lib/show-me/ \;
find /opt/show-me/scripts -type f -name "*.conf" -exec install -o0 -g0 -m0644 {} /usr/local/lib/show-me/ \;
find /opt/show-me/pki -type f -name "*_rsa"  -exec install -o0 -g0 -m0600 {} /home/$(id -un 1000)/.ssh/ \;
find /opt/show-me/pki -type f -name "*.pub"  -exec install -o0 -g0 -m0644 {} /home/$(id -un 1000)/.ssh/ \;
find /opt/show-me/pki -type f -name "*.pem"  -exec install -o0 -g0 -m0644 {} /etc/ssl/certs/ \;
find /opt/show-me/pki -type f -name "*.key"  -exec install -o0 -g0 -m0600 {} /etc/ssl/private/ \;
find /opt/show-me/pki -type f -name "*.crt"  -exec install -o0 -g0 -m0644 {} /etc/ssl/certs/ \;
install -o 0 -g 0 -m 0644 /etc/ssl/certs/show-me_host.pem /etc/ssl/certs/${CLOUD_APP}_server.pem
install -o 0 -g 0 -m 0600 /etc/ssl/private/show-me_host.key /etc/ssl/private/${CLOUD_APP}_server.key

#### Create/Update Cloudflare DNS Record
/usr/local/bin/show-me_update-dns.sh

# Quit rename script at this point is landscape is not installed
[ "$(apt-cache policy landscape-server-quickstart|awk -F'\\(|\\)' '/Installed:/{print tolower($2)}')" = "none" ] && exit 0

#### Update LXD Profile
/usr/local/bin/show-me_rename-${CLOUD_APP}-lxd-profile.sh

#### Change Apache2 conf for landscape, setting server name to ${CLOUD_PUBLIC_HOSTNAME}.${CLOUD_APP}.ubuntu-show.me
export APACHE2_CONF=$(find /etc/apache2/sites-available -type f ! -iname "000*" ! -iname "default-ssl*")
a2dissite ${APACHE2_CONF##*/}
rm ${APACHE2_CONF}
systemctl reload apache2
install -o 0 -g 0 -m 0644 /usr/local/lib/show-me/landscape-apache2.conf /etc/apache2/sites-available/${CLOUD_APP_FQDN_LONG}.conf
export APACHE2_CONF=$(find /etc/apache2/sites-available -type f ! -iname "000*" ! -iname "default-ssl*")
sed -r -i 's/@hostname@/'${CLOUD_APP_FQDN_LONG}'/g' ${APACHE2_CONF}
a2ensite ${APACHE2_CONF##*/}
systemctl reload apache2

#### Start Landscape Server
command -v lsctl && { lsctl start; }

if [ -f /usr/local/bin/show-me/show-me_finishing-script_all.sh ];then /usr/local/bin/show-me/show-me_finishing-script_all.sh;fi

{ [[ ${CLOUD_DEBUG} ]] &>/dev/null; } && { { set +x; } &>/dev/null; }

exit 0
