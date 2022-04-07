#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $SM_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

export SM_DNS="9.9.9.9,1.1.1.1,8.8.8.8";
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf;

[ -z "${LANG}" ] && { export LANG="en_US.UTF-8";export LANGUAGE="en_US"; }
export DEBIAN_FRONTEND=noninteractive
export SM_DNS="9.9.9.9,1.1.1.1,8.8.8.8"
export SM_ETH=$(ip -o r l default|grep -m1 -oP "(?<=dev )[^ ]+")
export SM_DOMAIN="ubuntu-show.me"
export SM_APP="landscape"
export SM_BR="br0"
export SM_ARCH="amd64"
export SM_GIT="https://github.com/ThinGuy/show-me.git"
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf
eval "$(dmidecode -s 2>&1|awk '/^[ \t]+/{gsub(/^[ \t]+/,"");print}'|xargs -rn1 -P0 bash -c 'P="${0//-/_}";P=${P^^};export P=${P//-/_};printf "export MACHINE_${P}=\x22$(dmidecode -s $0|grep -vi '"'"'not'"'"')\x22\n"'|sed 's/""$//g')"
export CLOUD_VENDOR="$(dmidecode -s bios-vendor|awk '{print tolower($1)}')"
[ "${CLOUD_VENDOR}" = "amazon" ] && { export SM_SUBSTRT="aws" CLOUD_METADATA_URL="http://169.254.169.254/latest/meta-data" CLOUD_API_URL="http://169.254.169.254/latest/api" ; }
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf
export CLOUD_API_TOKEN="$(curl -sSX PUT "${CLOUD_API_URL}/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")"
export CLOUD_AMI_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/ami-id)"
export CLOUD_LOCAL_IPV4="$(curl -sSlL ${CLOUD_METADATA_URL}/local-ipv4)"
export CLOUD_PUBLIC_IPV4="$(curl -sSlL ${CLOUD_METADATA_URL}/public-ipv4)"
export CLOUD_PUBLIC_IPV4="$(curl -sSlL ${CLOUD_METADATA_URL}/public-ipv4)"
export CLOUD_PUBLIC_IPV4_CHECK="$(dig +short myip.opendns.com @resolver1.opendns.com)"
[ -z "${CLOUD_PUBLIC_IPV4}" -a -n "${CLOUD_PUBLIC_IPV4_CHECK}" ] && { export CLOUD_PUBLIC_IPV4="${CLOUD_PUBLIC_IPV4_CHECK}"; } 
export CLOUD_REGION="$(curl -sSlL ${CLOUD_METADATA_URL}/placement/region)"
export CLOUD_AZ="$(curl -sSlL ${CLOUD_METADATA_URL}/placement/availability-zone)"
export CLOUD_AZ_ID="$(curl -sSlL ${CLOUD_METADATA_URL}/placement/availability-zone-id)"
export CLOUD_LOCAL_HOSTNAME="$(curl -sSlL ${CLOUD_METADATA_URL}/local-hostname)"
export CLOUD_PUBLIC_HOSTNAME="$(curl -sSlL ${CLOUD_METADATA_URL}/public-hostname)"
export CLOUD_PUBLIC_FQDN_CHECK="$(dig +short -x $(dig +short myip.opendns.com @resolver1.opendns.com) @resolver1.opendns.com|sed 's,\.$,,g')"
[ -z "${CLOUD_PUBLIC_HOSTNAME}" -a -n "${CLOUD_PUBLIC_FQDN_CHECK}" ] && { export CLOUD_PUBLIC_HOSTNAME="${CLOUD_PUBLIC_FQDN_CHECK%%.*}"; } 
export CLOUD_PRIMARY_MAC_ADDR="$(curl -sSlL ${CLOUD_METADATA_URL}/mac)"
export CLOUD_PUBLIC_TLD="$(curl -sSlL ${CLOUD_METADATA_URL}/services/domain)"
export CLOUD_PUBLIC_SLD="$(dmidecode -s bios-vendor|awk '{print tolower($2)}')"
export CLOUD_LOCAL_TLD="internal"
export CLOUD_PUBLIC_FQDN="${CLOUD_PUBLIC_HOSTNAME}.${CLOUD_REGION}.compute.${CLOUD_PUBLIC_TLD}"
export CLOUD_PUBLIC_DOMAIN="${CLOUD_REGION}.compute.${CLOUD_PUBLIC_TLD}"
export CLOUD_LOCAL_DOMAIN="${CLOUD_REGION}.compute.${CLOUD_LOCAL_TLD}"
export CLOUD_PARTITION="$(curl -sSlL ${CLOUD_METADATA_URL}/services/partition)"
export CLOUD_LOCAL_FQDN="${CLOUD_LOCAL_HOSTNAME}.${CLOUD_REGION}.compute.${CLOUD_LOCAL_TLD}"
export CLOUD_REPO_FQDN="${CLOUD_REGION}.${CLOUD_PUBLIC_SLD}.archive.ubuntu.com"
export CLOUD_INSTANCE_ID="$(curl -sSlL http://169.254.169.254/latest/meta-data/instance-id)"
if [ /etc/cloud/cloud.cfg ];then sed 's/preserve_hostname: false/preserve_hostname: true/g' -i /etc/cloud/cloud.cfg;fi
[ "$(lsb_release -sr|sed 's/\.//g')" -lt "2004" ] && { hostnamectl set-hostname ${CLOUD_PUBLIC_FQDN}; } || { hostnamectl hostname ${CLOUD_PUBLIC_FQDN}; }
echo ${CLOUD_PUBLIC_FQDN}|tee 1>/devnull /etc/hostname
echo ${CLOUD_PUBLIC_FQDN}|tee /etc/hostname
printf "127.0.0.1\t${CLOUD_PUBLIC_HOSTNAME}.localdomain ${CLOUD_PUBLIC_HOSTNAME} localhost4 localhost4.localdomain4 localhost.localdomain localhost\n${CLOUD_PUBLIC_IPV4}\t${CLOUD_PUBLIC_FQDN} ${CLOUD_PUBLIC_HOSTNAME}\n#${CLOUD_LOCAL_IPV4}\t${CLOUD_LOCAL_FQDN} ${CLOUD_LOCAL_HOSTNAME}\n" /etc/hosts
sysctl -w net.ipv4.ip_forward=1
install -o 0 -g 0 -m 0755 -d /usr/local/lib/show-me/
((set|grep -E '^CANDID_|^CLOUD_|^LANDSCAPE_|^MAAS_|^MACHINE_|^PG_|^RBAC_|^SHOW_ME|^SHOW_ME_|^SM_|^SSP_')|sed -r 's/^/export /g;s/\\Fx22//g;s/\\\x27//g;s/=/=\x22/1;s/$/\x22/g'|sort -uV)|tee /usr/local/lib/show-me/.show-me.rc
if [ -f /usr/local/lib/show-me/.show-me.rc ];then cp /usr/local/lib/show-me/.show-me.rc /root/.;su $(id -un 1000) -c 'cp /usr/local/lib/show-me/.show-me.rc ~/';echo '[ -r ~/.show-me.rc ] && . ~/.show-me.rc'|tee -a /root/.bashrc|su $(id -un 1000) -c 'tee -a ~/.bashrc';fi
cat <<-RESOLVED|sed '/^$/d'|tee 1>/dev/null /etc/systemd/resolved.conf.d/sm-resolved.conf
[Resolve]
DNS=$(echo -n ${SM_DNS}|sed 's/,/ /g;s/\x27//g)
FallbackDNS=149.112.112.112 149.112.112.112 8.8.8.8
Domains=${CLOUD_PUBLIC_DOMAIN} ${CLOUD_LOCAL_DOMAIN} ~${SM_DOMAIN}
LLMNR=yes
MulticastDNS=no
DNSSEC=allow-downgrade
$([ "$(lsb_release -sr|sed 's/\.//g')" -ge "2004" ] && echo -n DNSOverTLS=opportunistic)
Cache=no-negative
DNSStubListener=yes
$([ "$(lsb_release -sr|sed 's/\.//g')" -ge "2004" ] && echo -n ReadEtcHosts=yes)
RESOLVED
printf '%s\x20%s\x20\x20%s\n' precedence '::ffff:0:0/96' 100|tee -a /etc/gai.conf
echo 'network: {config: disabled}' >/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf
cat <<-NETPLAN|sed -r 's/[ \t]+$//g;/^$/d'|tee 1>/dev/null /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ${SM_ETH}:
      dhcp4: false
      dhcp6: false
      optional: false
      accept-ra: false
      link-local: [ ]
      match:
        macaddress: '${CLOUD_PRIMARY_MAC_ADDR}'
      set-name: ${SM_ETH}
  bridges:
    ${SM_BR}:
      macaddress: '${CLOUD_PRIMARY_MAC_ADDR}'
      interfaces: ['${SM_ETH}']
      link-local: [ ]
      dhcp4: true
      dhcp4-overrides:
        use-hostname: false
        hostname: ${CLOUD_PUBLIC_FQDN}
        use-dns: false
        route-metric: 1
      dhcp6: false
      optional: false
      accept-ra: false
      link-local: [ ]
      nameservers:
        addresses: [${SM_DNS}]
        search: [${CLOUD_PUBLIC_DOMAIN},${CLOUD_LOCAL_DOMAIN},~${SM_DOMAIN}]
      parameters:
        priority: 1
        stp: false
NETPLAN
netplan --debug generate
netplan --debug generate
netplan --debug apply 
netplan --debug apply
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf
cat <<REPOS|sed -r 's/[ \t]+$//g'|tee 1>/dev/null /etc/apt/sources.list
deb [arch=${SM_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs) main restricted universe multiverse
deb [arch=${SM_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse
deb [arch=${SM_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse
deb [arch=${SM_ARCH}] http://${CLOUD_REPO_FQDN}/ubuntu/ $(lsb_release -cs)-security main restricted universe multiverse
deb [arch=${SM_ARCH}] http://archive.canonical.com/ubuntu $(lsb_release -cs) partner
REPOS
DEBIAN_FRONTEND=noninteractive apt -o "Acquire::ForceIPv4=true" update
DEBIAN_FRONTEND=noninteractive apt dist-upgrade -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge
DEBIAN_FRONTEND=noninteractive apt remove lxd lxd-client -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge
DEBIAN_FRONTEND=noninteractive apt install build-essential curl debconf-utils dialog dnsutils git gnupg haproxy jq language-pack-en-base lynx make p7zip p7zip-full software-properties-common ssl-cert tree unzip vim wget zip -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf
[ -n "${LC_ALL}" ] && { unset LC_ALL; }
sudo locale-gen ${LANG:-en_US.UTF-8}
sudo locale-gen ${LANGUAGE:-en_US}
export LANG=${LANG:-en_US.UTF-8} LANGUAGE=${LANGUAGE:-en_US}
sudo update-locale LANG=${LANG:-en_US.UTF-8} LANGUAGE=${LANGUAGE:-en_US}
((printf "%s=\x22${LANG}\x22\n" LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION)|sed -r '2s/^/LANGUAGE=\x22'${LANG%%.*}'\x22\n/g')|tee /etc/default/locale
echo -en 'locales\tlocales/locales_to_be_generated\tmultiselect\t'${LANGUAGE:-en_US}' ISO-8859-1, '${LANG:-en_US.UTF-8}' UTF-8'|debconf-set-selections
echo -en 'locales\tlocales/default_environment_locale\tselect\t'${LANG:-en_US.UTF-8}''|debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
if [ -f /var/run/.show-me.rc ];then . /var/run/.show-me.rc;fi
mkdir -p /etc/show-me/www /etc/show-me/log
if [ -d /opt/show-me ];then rm -rf /opt/show-me;fi
ping -c10 -w5 github.com
sleep 10
git clone https://github.com/ThinGuy/show-me.git /opt/show-me;
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
cat <<-'SUDOERS'|sed -r 's/[ \t]+$//g;/^$/d'|tee 1>/dev/null /etc/sudoers.d/100-keep-params
Defaults env_keep+="CANDID_* CLOUD_* DISPLAY EDITOR HOME LANDSCAPE_* LANG* LC_* MAAS_* MACHINE_* PG_* PYTHONWARNINGS RBAC_* SHOW_ME_* SM_* SSP_* XAUTHORITY XAUTHORIZATION *_PROXY *_proxy"
SUDOERS
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf
apt-key adv --recv --keyserver keyserver.ubuntu.com 6E85A86E4652B4E6
echo 'deb [arch=amd64] http://ppa.launchpad.net/19.10/ubuntu bionic main'|tee 1>/dev/null /etc/apt/sources.list.d/landscape-ubuntu-19_10-bionic.list
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf
DEBIAN_FRONTEND=noninteractive apt -o "Acquire::ForceIPv4=true" update
DEBIAN_FRONTEND=noninteractive apt dist-upgrade -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge
DEBIAN_FRONTEND=noninteractive apt install libcurl4-gnutls-dev python-pycurl-doc python3-pycurl-dbg -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge
DEBIAN_FRONTEND=noninteractive apt install postgresql postgresql-common postgresql-client postgresql-client-common -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge
DEBIAN_FRONTEND=noninteractive apt install landscape-client -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge
if [ -f /etc/ssl/certs/landscape_server.pem ];then ln -sf /etc/ssl/certs/landscape_server.pem /etc/landscape/landscape_server.pem;fi
if [ -f /etc/ssl/certs/landscape_server_ca.crt ];then ln -sf /etc/ssl/certs/landscape_server_ca.crt /etc/landscape/landscape_server_ca.crt;fi
if [ -f /etc/ssl/certs/landscape_server.pem ];then echo "ssl_public_key = /etc/ssl/certs/landscape_server.pem"|tee 1>/dev/null -a /etc/landscape/client.conf;fi
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf
DEBIAN_FRONTEND=noninteractive apt install landscape-server-quickstart -o "Acquire::ForceIPv4=true" -yqf --auto-remove --purge
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf
if [ -f /usr/local/lib/show-me/landscape.lynx -a -f /usr/local/bin/show-me_lynx-web-init.sh ];then /usr/local/bin/show-me_lynx-web-init.sh;fi
if [ -f /etc/landscape/client.conf ];then ln -sf /etc/landscape/client.conf /etc/show-me/www/landscape-client.conf;fi
landscape-config -k /etc/landscape/landscape_server.pem -t $(hostname -s) -u "https://${CLOUD_PUBLIC_FQDN}/message-system" --ping-url "http://${CLOUD_PUBLIC_FQDN}/ping" -a standalone --http-proxy= --https-proxy= --script-users=ALL --access-group=global --tags=show-me-demo,ubuntu --silent --log-level=debug
if $(test -n "$(command 2>/dev/null -v lxd.lxc)");then su - $(id -un 1000) -c 'sudo snap refresh lxd --channel latest/stable';else su - $(id -un 1000) -c 'sudo snap install lxd';fi
if [ -f /usr/local/bin/show-me_landscape_lxd-init.sh ];then /usr/local/bin/show-me_landscape_lxd-init.sh;fi
if [ -f /usr/local/bin/show-me_file-service_init.sh ];then /usr/local/bin/show-me_file-service_init.sh;fi
if [ -f /usr/local/bin/show-me/show-me_finishing-script_all.sh ];then /usr/local/bin/show-me/show-me_finishing-script_all.sh;fi
