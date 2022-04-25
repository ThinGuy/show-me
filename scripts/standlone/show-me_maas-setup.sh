#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ ${CLOUD_DEBUG} ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

# In case this is the base AMI, make a copy of last .show-me.rc
if [ -f ~/.show-me.rc ];then mv ~/.{show-me,last.show-me}.rc;fi;
if [ -f /home/$(id -un 1000)/.show-me.rc ];then su $(id -un 1000) -c 'mv ~/.{show-me,last.show-me}.rc';fi
#### unset CLOUD_* and DB variables loaded via .show-me.rc via .bashrc
[[ -f ~/.show-me.rc ]] && { unset (grep -oE 'CLOUD_[^=]+|MAAS_[^=]+|SSP_[^=]+|RBAC_[^=]+|CANDID_[^=]+|LANDSCAPE_[^=]+|PG_[^=]+' ~/.show-me.rc|paste -sd' '); }


###########################################
###### pkg update and repo additions ######
###########################################



DEBIAN_FRONTEND=noninteractive apt -o "Acquire::ForceIPv4=true" update;
DEBIAN_FRONTEND=noninteractive apt dist-upgrade -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge;
DEBIAN_FRONTEND=noninteractive apt install build-essential curl debconf-utils dnsutils git gnupg jq language-pack-en language-pack-en-base lynx make postgresql postgresql-common postgresql-client postgresql-client-common p7zip p7zip-full python2-minimal python2 dh-python 2to3 python-is-python3 python3 software-properties-common ssl-cert tree unzip vim wget zip -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge

#### If Bionic, remove deb-based LXD as there is no upgrade path and we don't want to run the conversion
[ "$(lsb_release -sr|sed 's/\.//g')" -le "1804" ] && { DEBIAN_FRONTEND=noninteractive apt remove lxd lxd-client -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge; }

#### Install/Refresh LXD to latest/stable
[ "$(lsb_release -sr|sed 's/\.//g')" -le "1804" ] && { snap install lxd --channel latest/stable; } || { snap refresh lxd --channel latest/stable; }


#########################################
#####  Base Show Me configuration  ######
#########################################

#### Set locale - This is important for postgresql.  Should be set prior to install

export LANG="en_US.UTF-8"
export LANGUAGE="${LANG%%.*}"
[ -n "${LC_ALL}" ] && { unset LC_ALL; }
sudo locale-gen ${LANG}
sudo locale-gen ${LANGUAGE}
sudo update-locale LANG=${LANG} LANGUAGE=${LANGUAGE}
((printf "%s=${LANG}\n" LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION)|sed -r '2s/^/LANGUAGE='${LANG%%.*}'\n/g')|tee /etc/default/locale
echo -en 'locales\tlocales/locales_to_be_generated\tmultiselect\t'${LANGUAGE}' ISO-8859-1, '${LANG}' UTF-8'|debconf-set-selections
echo -en 'locales\tlocales/default_environment_locale\tselect\t'${LANG}''|debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

#### Ensure cloud-init does not change our hostname(s)
if [ /etc/cloud/cloud.cfg ];then sed 's/preserve_hostname: false/preserve_hostname: true/g' -i /etc/cloud/cloud.cfg;fi



#### Show Me Params
export CLOUD_BRIDGE="br0"
export CLOUD_ETH=$(ip -o r l default|grep -m1 -oP "(?<=dev )[^ ]+")
[ "${CLOUD_ETH}" = "${CLOUD_BRIDGE}" ] && { export CLOUD_ETH=$(find /sys/devices -type l ! -path "*virt*" -iname "upper*"|awk '{gsub(/.*net\//,"");gsub(/\/upper_/," ");print $1}'|sort -uV); }
export CLOUD_ARCH="$(dpkg --print-architecture)"
export CLOUD_APP_GIT="https://github.com/ThinGuy/show-me.git"
export CLOUD_APP="maas"
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

#eval $(curl -sSLL https://bit.ly/3uyZjU0)

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
if [ -f /usr/local/lib/show-me/.show-me.rc ];then cp /usr/local/lib/show-me/.show-me.rc /root/.;su $(id -un 1000) -c 'cp /usr/local/lib/show-me/.show-me.rc ~/';echo '[ -r ~/.show-me.rc ] && . ~/.show-me.rc'|tee -a /root/.bashrc|su $(id -un 1000) -c 'tee -a ~/.bashrc';fi

#### Cleanup/Prepare Show-Me files
if [ -f ~/.show-me.rc ];then unset $(set|grep -oE '^CLOUD_[^=]+'|paste -sd' ');. ~/.show-me.rc;fi;
if [ -d /opt/show-me ];then { cd /opt/show-me && git pull; };else git clone ${CLOUD_APP_GIT} /opt/show-me;fi

install -o 0 -g 0 -m 0755 -d /usr/local/lib/show-me/

find /opt/show-me/scripts -type f -name "*.sh" -exec install -o0 -g0 -m0755 {} /usr/local/bin/ \;
find /opt/show-me/scripts -type f -name "*.lynx" -exec install -o0 -g0 -m0644 {} /usr/local/lib/show-me/ \;
find /opt/show-me/scripts -type f -name "*.conf" -exec install -o0 -g0 -m0644 {} /usr/local/lib/show-me/ \;
find /opt/show-me/scripts -type f -name "*.yaml" -exec install -o0 -g0 -m0644 {} /usr/local/lib/show-me/ \;
find /opt/show-me/pki -type f -name "*_rsa"  -exec install -o0 -g0 -m0600 {} /home/$(id -un 1000)/.ssh/ \;
find /opt/show-me/pki -type f -name "*.pub"  -exec install -o0 -g0 -m0644 {} /home/$(id -un 1000)/.ssh/ \;
find /opt/show-me/pki -type f -name "*.pem"  -exec install -o0 -g0 -m0644 {} /etc/ssl/certs/ \;
find /opt/show-me/pki -type f -name "*.key"  -exec install -o0 -g0 -m0600 {} /etc/ssl/private/ \;
find /opt/show-me/pki -type f -name "*.crt"  -exec install -o0 -g0 -m0644 {} /etc/ssl/certs/ \;


#### Create/Update Cloudflare DNS Record
/usr/local/bin/show-me_update-dns.sh

#### Set Regional Ubuntu Repositories + Enable backports pocket

cat <<REPOS |sed -r 's/[ \t]+$//g'|tee 1>/dev/null /etc/apt/sources.list
deb [arch=${CLOUD_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs) main restricted universe multiverse
deb [arch=${CLOUD_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse
deb [arch=${CLOUD_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse
deb [arch=${CLOUD_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs)-security main restricted universe multiverse
deb [arch=${CLOUD_ARCH}] http://archive.canonical.com/ubuntu $(lsb_release -cs) partner
REPOS

#### Add MAAS Package Archive
#add-apt-repository ppa:maas/3.2 -y

DEBIAN_FRONTEND=noninteractive apt -o "Acquire::ForceIPv4=true" update;
DEBIAN_FRONTEND=noninteractive apt dist-upgrade -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge;


postgres://maas:zi2cxQKoRZxQ@
#### Update Package indexes to pick up backports change
#DEBIAN_FRONTEND=noninteractive apt -o "Acquire::ForceIPv4=true" update;
#DEBIAN_FRONTEND=noninteractive apt dist-upgrade -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge;

# Set Hostname and Name resolution
sed -i -r '/127.0.1.1/d;s/^127.0.0.1.*$/127.0.0.1 localhost\n127.0.1.1 '${CLOUD_APP}' '${CLOUD_APP_FQDN_LONG}' '${CLOUD_PUBLIC_HOSTNAME}' '${CLOUD_LOCAL_HOSTNAME}'\n/' /etc/hosts

# Change prompt
install -o0 -g0 -m0644 /dev/null /etc/profile.d/bash-prompt.sh
echo "export NICKNAME=${CLOUD_APP}" > /etc/profile.d/bash-prompt.sh
[ -f /etc/profile.d/bash-prompt.sh ] && . /etc/profile.d/bash-prompt.sh
sed -i -r 's/@\\h:/@'"'"'${NICKNAME}'"'"':/' /etc/bash.bashrc
export PS1='${debian_chroot:+($debian_chroot)}\u@'${NICKNAME}':\w\$ '
[ "$(lsb_release -sr|sed 's/\.//g')" -lt "2004" ] && { hostnamectl set-hostname maas; } || { hostnamectl hostname maas; }
echo "maas"|tee /etc/hostname
export HOSTNAME="maas"

cat <<-NETPLAN|sed -r 's/[ \t]+$//g;/^$/d'|tee 1>/dev/null /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens5:
      optional: false
      dhcp4: false
      dhcp6: false
      accept-ra: false
      link-local: [ ]
      match:
        macaddress: '$(ip -o l show dev ens5|grep -oP "(?<=ether )[^ ]+")'
      set-name: ens5
  bridges:
    br0:
      macaddress: '$(ip -o l show dev ens5|grep -oP "(?<=ether )[^ ]+")'
      optional: false
      interfaces: ['ens5']
      dhcp4: true
      dhcp4-overrides:
        use-dns: false
        use-hostname: false
        use-domains: false
        route-metric: 1
      dhcp6: false
      accept-ra: false
      link-local: [ ]
      parameters:
        priority: 1
        stp: false
NETPLAN

#### Due to issues with erlang and rabbitmq after AMI gets new name/addresses
#### We will be disabling IPv6, so ensure only IPV4 DNS servers are used
#### This is only required for the Landscape Demonstration
export CLOUD_DNS="${CLOUD_DNS_IPV4}"
export CLOUD_FALLBACK_DNS="${CLOUD_FALLBACK_DNS_IPV4}"

#### Fix bug where /etc/resolv.conf is symlinked to /run/systemd/resolve/stub-resolv.conf
#### And setup a proper systemd-resolved file so global DNS settings are available

rm -rf /etc/resolv.conf
cat <<-RESOLV |tee 1>/dev/null /etc/systemd/resolved.conf
[Resolve]
DNS=$(printf "${CLOUD_DNS//,/ }") $(resolvectl --status eth0|awk '/Servers:/{print $3}')
FallbackDNS=$(printf "${CLOUD_FALLBACK_DNS//,/ }") $(resolvectl --status eth0|awk '/Servers:/{print $3}')
Domains=${CLOUD_APP_DOMAIN} ${CLOUD_DOMAIN} ${CLOUD_LOCAL_DOMAIN}
DNSSEC=allow-downgrade
DNSOverTLS=opportunistic
MulticastDNS=yes
LLMNR=yes
Cache=no-negative
CacheFromLocalhost=no
DNSStubListener=no
DNSStubListenerExtra=
ReadEtcHosts=yes
ResolveUnicastSingleLabel=yes
RESOLV

#### Remove systemd-resolved parameters that are only in focal or greater
if [ "${CLOUD_DISTRIB_RELEASE//.}" -lt "2004" ];then sed -r -i '/ReadEtc|DNSOver|Unicast|StubListenerExtra|CacheFrom/d' /etc/systemd/resolved.conf;fi
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

#### Restart networkd and resolved so our changes take effect
sudo systemctl restart systemd-networkd systemd-resolved procps

#### Flush DNS cache and show global parameters
resolvectl flush-caches
resolvectl status --no-pager|awk '/Global/,/internal/'



#### Make sure cloud-init does not overwrite our network config
#echo 'network: {config: disabled}'|tee 1>/dev/null /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
#### Prefer IPv4 connections
printf '%s\x20%s\x20\x20%s\n' precedence '::ffff:0:0/96' 100|tee 1>/dev/null /etc/gai.conf

#### Disable ipv6 since we don't know if the user's VPC has it enabled.
ip -o link|awk '!/veth|tap/{gsub(/:|@.*$/,"",$2);print "net.ipv6.conf."$2".disable_ipv6=1"}'|xargs -rn1 -P0 sysctl -w
ip -o link|awk '!/veth|tap/{gsub(/:|@.*$/,"",$2);print "net.ipv6.conf."$2".disable_ipv6=1"}'|tee 1>/dev/null /etc/sysctl.d/99-disable-ipv6.conf
ip -o link|awk '!/veth|tap/{gsub(/:|@.*$/,"",$2);print $2}'|xargs -rn1 -P0 ip -6 a flush

#### Restart the networkd and systemd for good measure
systemctl restart systemd-networkd systemd-resolved procps

#### Ensure all Show-Me related params work with sudo
cat <<-'SUDOERS'|sed -r 's/[ \t]+$//g;/^$/d'|tee 1>/dev/null /etc/sudoers.d/100-keep-params
Defaults env_keep+="CANDID_* CLOUD_* LANDSCAPE_* MAAS_* PG_* RBAC_* SSP_* MK8S_* MO7K_* MCLOUD_* CANDID_* CLOUD_* DISPLAY EDITOR HOME LANDSCAPE_* LANG LC_* MAAS_* MACHINE_* PG_* PYTHONWARNINGS RBAC_* SSP_* XAUTHORITY XAUTHORIZATION *_PROXY *_proxy"
SUDOERS


################################################
###### Application specific configuration ######
################################################




#### Handle app-specific show-me files
install -o 0 -g 0 -m 0644 /etc/ssl/certs/show-me_host.pem /etc/ssl/certs/${CLOUD_APP}_server.pem
install -o 0 -g 0 -m 0600 /etc/ssl/private/show-me_host.key /etc/ssl/private/${CLOUD_APP}_server.key


#### Install MAAS (snap)
snap install maas --channel 3.2/beta

maas init --force --mode=region+rack --maas-url="${MAAS_URL}" --database-host=${MAAS_DBHOST} --database-name=${MAAS_DBNAME} --database-user=${MAAS_DBUSER} --database-pass=${MAAS_DBPASS} --database-port=${MAAS_DBPORT}
maas createadmin --username ${MAAS_PROFILE} --password ${MAAS_PASSWORD} --email ${MAAS_EMAIL} --ssh-import "${MAAS_IMPORTID}"
maas login ${MAAS_PROFILE} ${MAAS_URL} $(maas apikey --username=${MAAS_PROFILE})
su - $(id -un 1000) -c 'sudo maas login '${MAAS_PROFILE}' '${MAAS_URL}' $(sudo maas apikey --username='${MAAS_PROFILE}')'




#### Run lynx script
if [ -f /usr/local/bin/show-me_lynx-web-init.sh ];then /usr/local/bin/show-me_lynx-web-init.sh;fi


#### Initialize LXD.  LXD will be used to create additional maas clients
if [ -f /usr/local/bin/show-me_${CLOUD_APP}_lxd-init.sh ];then /usr/local/bin/show-me_${CLOUD_APP}_lxd-init.sh;fi
#### Update LXD Profile
if [ -f /usr/local/bin/show-me_rename-${CLOUD_APP}-lxd-profile.sh ];then /usr/local/bin/show-me_rename-${CLOUD_APP}-lxd-profile.sh;fi
#### Launch a variety of ubuntu releases, which will self-register with Landscape
if [ -f /usr/local/bin/add-${CLOUD_APP}-clients-numbered.sh ];then /usr/local/bin/add-${CLOUD_APP}-clients-numbered.sh 1;fi

#### Create ssh config for access to maas-client machines
cat <<SSHCONF |su $(id -un 1000) -c 'tee 1>/dev/null -a ~/.ssh/config'
Host 10.10.10.*
  AddressFamily inet
  AddKeysToAgent yes
  CheckHostIP no
  ForwardAgent yes
  ForwardX11Trusted yes
  ForwardX11 yes
  IdentityFile ~/.ssh/showme_rsa
  LogLevel FATAL
  SendEnv LANG LC_*
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  User ubuntu
  Port 22
  XAuthLocation /usr/bin/xauth
SSHCONF

if [ -f /usr/local/bin/show-me/show-me_finishing-script_all.sh ];then /usr/local/bin/show-me/show-me_finishing-script_all.sh;fi


{ [[ ${CLOUD_DEBUG} ]] &>/dev/null; } && { { set +x; } &>/dev/null; }


exit 0



