#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $SM_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }


export SM_DNS="9.9.9.9,1.1.1.1,'2620:fe::fe','2606:4700:4700::1111'"
export SM_ETH=$(ip -o r l default|grep -m1 -oP "(?<=dev )[^ ]+")
export SM_DOMAIN="ubuntu-show.me"
export SM_APP="landscape"
export SM_BR="br0"
export SM_ARCH="amd64"
export SM_GIT="https://github.com/ThinGuy/show-me.git"
(echo ${SM_DNS}|sed 's/,/\n/g'|sed '/::/d;s/^/nameserver /g')|sudo tee 1>/dev/null /etc/resolv.conf
export CLOUD="$(dmidecode -s bios-vendor|awk '{print tolower($1)}')"
[ "${CLOUD}" = "amazon" ] && { export MDURL="http://169.254.169.254/latest/meta-data"; }
[ "${CLOUD}" = "amazon" ] && { export SM_SUBSTRT="aws"; }
export MDURL="http://169.254.169.254/latest/meta-data"
export DEBIAN_FRONTEND=noninteractive
eval $((set|grep -E '^CANDID_|^CLOUD_|^LANDSCAPE_|^MAAS_|^MACHINE_|^PG_|^RBAC_|^SHOW_ME|^SHOW_ME_|^SM_|^SSP_')|sed -r 's/^/export /g;s/\\x22//g;s/\\\x27//g')
export CLOUD_API_TOKEN="$(http://169.254.169.254/latest/api/token)"
export CLOUD_AMI_ID="$(curl -sSlL ${MDURL}/ami-id)
export CLOUD_LOCAL_IPV4="$(curl -sSlL $MDURL/local-ipv4)"
export CLOUD_PUBLIC_IPV4="$(curl -sSlL $MDURL/public-ipv4)"
export CLOUD_PUBLIC_IPV4="$(curl -sSlL $MDURL/public-ipv4)"
export CLOUD_PUBLIC_IPV4_CHECK="$(dig +short myip.opendns.com @resolver1.opendns.com)"
[ -z "${CLOUD_PUBLIC_IPV4}" -a -n "${CLOUD_PUBLIC_IPV4_CHECK}" ] && { export CLOUD_PUBLIC_IPV4="${CLOUD_PUBLIC_IPV4_CHECK}"; } 
export CLOUD_REGION="$(curl -sSlL $MDURL/placement/region)"
export CLOUD_AZ="$(curl -sSlL $MDURL/placement/availability-zone)"
export CLOUD_AZ_ID="$(curl -sSlL $MDURL/placement/availability-zone-id)"
export CLOUD_LOCAL_HOSTNAME="$(curl -sSlL $MDURL/local-hostname)"
export CLOUD_PUBLIC_HOSTNAME="$(curl -sSlL $MDURL/public-hostname)"
export CLOUD_PUBLIC_FQDN_CHECK="$(dig +short -x $(dig +short myip.opendns.com @resolver1.opendns.com) @resolver1.opendns.com|sed 's,\.$,,g')
[ -z "${CLOUD_PUBLIC_HOSTNAME}" -a -n "${CLOUD_PUBLIC_FQDN_CHECK}" ] && { export CLOUD_PUBLIC_HOSTNAME="${CLOUD_PUBLIC_FQDN_CHECK%%.*}"; } 
export CLOUD_PRIMARY_MAC_ADDR="$(curl -sSlL ${MDURL}/mac)"
export CLOUD_PUBLIC_TLD="$(curl -sSlL ${MDURL}/services/domain)"
export CLOUD_LOCAL_TLD="internal"
export CLOUD_PUBLIC_FQDN="${CLOUD_PUBLIC_HOSTNAME}.${CLOUD_REGION}.compute.${CLOUD_PUBLIC_TLD}"
export CLOUD_PUBLIC_DOMAIN="${CLOUD_REGION}.compute.${CLOUD_PUBLIC_TLD}"
export CLOUD_LOCAL_DOMAIN="${CLOUD_REGION}.compute.${CLOUD_LOCAL_TLD}"
export CLOUD_PARTITION="$(curl -sSlL ${MDURL}/services/partition)"
export CLOUD_LOCAL_FQDN="${CLOUD_LOCAL_HOSTNAME}.${CLOUD_REGION}.compute.${CLOUD_LOCAL_TLD}"
hostname ${CLOUD_PUBLIC_FQDN}
echo ${CLOUD_PUBLIC_FQDN}|tee 1>/devnull /etc/hostname
sed -r -i "/127.0|${CLOUD_LOCAL_HOSTNAME}|${CLOUD_LOCAL_IPV4}/d" /etc/hosts
sed -r -i "1s/^/127.0.0.1\tlocalhost\n${CLOUD_PUBLIC_IPV4}\t${CLOUD_PUBLIC_FQDN} ${CLOUD_PUBLIC_HOSTNAME}\n${CLOUD_LOCAL_IPV4}\t${CLOUD_LOCAL_FQDN} ${CLOUD_LOCAL_HOSTNAME}\n/" /etc/hosts
sysctl -w net.ipv4.ip_forward=1
cat <<-RESOLVED|sed '/^$/d'|tee 1>/dev/null /etc/systemd/resolved.conf.d/sm-resolved.conf
[Resolve]
DNS=$(echo -n $SM_DNS|sed 's/,/ /g;s/\x27//g)
FallbackDNS=149.112.112.112 149.112.112.112 2620:fe::9 2606:4700:4700::1001
Domains=${CLOUD_PUBLIC_DOMAIN} ${CLOUD_LOCAL_DOMAIN} ~${SM_DOMAIN}
LLMNR=yes
MulticastDNS=yes
DNSSEC=allow-downgrade
$([ "$(lsb_release -sr|sed 's/\.//g')" -ge "2004" ] && echo -n DNSOverTLS=opportunistic)
Cache=no-negative
DNSStubListener=no
$([ "$(lsb_release -sr|sed 's/\.//g')" -ge "2004" ] && echo -n ReadEtcHosts=yes)
RESOLVED
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
printf '%s\x20%s\x20\x20%s\n' precedence '::ffff:0:0/96' 100|tee -a /etc/gai.conf
systemctl restart systemd-resolved
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
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
netplan --debug generate 
netplan --debug apply 
ip addr flush ${SM_ETH} 
echo 'network: {config: disabled}' >/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
systemctl restart systemd-resolved
apt-get --option="Acquire::ForceIPv4=true" update
apt-get dist-upgrade --option="Acquire::ForceIPv4=true" --assume-yes --quiet --auto-remove --purge
apt-get install dnsutils debconf-utils dialog gnupg --option="Acquire::ForceIPv4=true" --assume-yes --quiet --auto-remove --purge
apt-get remove lxd lxd-client --auto-remove --purge --assume-yes --quiet --fix-broken --option="Acquire::ForceIPv4=true"
((set|grep -E '^CANDID_|^CLOUD_|^LANDSCAPE_|^MAAS_|^MACHINE_|^PG_|^RBAC_|^SHOW_ME|^SHOW_ME_|^SM_|^SSP_')|sed -r 's/^/export /g;s/\\x22//g;s/\\\x27//g')|tee 1>/dev/null /root/.show-me.rc
if [ -f /root/.show-me.rc ];then . /root/.show-me.rc;fi
for i in SM_BR SM_ARCH SM_APP SM_SUBSTRT SM_GIT EDITOR PYTHONWARNINGS CLOUD_PUBLIC_IPV4 LOCAL_IP;do if [ -n "$(eval echo -n \"\$${i}\")" ];then printf "export ${i}=\x22$(eval echo -n \$$i)\x22\n";fi;done|tee -a 1>/dev/null /etc/environment
. /etc/environment
mkdir -p /etc/show-me/www /etc/show-me/log
if [ -d /opt/show-me ];then rm -rf /opt/show-me;fi
ping -c10 -w5 github.com
sleep 10
git clone https://github.com/ThinGuy/show-me.git /opt/show-me
install -o 0 -g 0 -m 0755 /opt/show-me/scripts/petname-helper.sh /usr/local/bin/petname-helper.sh
install -o 0 -g 0 -m 0755 /opt/show-me/scripts/show-me_lynx-web-init.sh /usr/local/bin/show-me_lynx-web-init.sh
install -o 0 -g 0 -m 0755 /opt/show-me/scripts/add-landscape-clients.sh /usr/local/bin/add-landscape-clients.sh
install -o 1000 -g 1000 -m 0400 /opt/show-me/pki/show-me-id_rsa /home/$(id -un 1000)/.ssh/showme_rsa
install -o 1000 -g 1000 -m 0640 /opt/show-me/pki/show-me-id_rsa.pub /home/$(id -un 1000)/.ssh/showme_rsa.pub
install -o 0 -g 0 -m 0644 -D /opt/show-me/scripts/landscape.lynx /usr/local/lib/show-me/landscape.lynx
install -o 0 -g 0 -m 0755 -d /usr/local/lib/show-me/petname2/
install -o 0 -g 0 -m 0755 /opt/show-me/scripts/show-me_landscape_lxd-init.sh /usr/local/bin/show-me_landscape_lxd-init.sh
install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_host.pem /etc/ssl/certs/show-me_host.pem
install -o 0 -g 0 -m 0600 /opt/show-me/pki/show-me_host.key /etc/ssl/private/show-me_host.key
install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_ca.crt /etc/ssl/certs/show-me_ca.crt
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
if [ -f /home/$(id -un 1000)/.ssh/showme_rsa.pub ];then su $(id -un 1000) -c 'cat /home/$(id -un 1000)/.ssh/showme_rsa.pub|tee -a 1>/de, 'v/null /home/$(id -un 1000)/.ssh/authorized_keys';fi
if [ -f /home/$(id -un 1000)/.showme.rc ];then . /home/$(id -un 1000)/.showme.rc;fi
cat <<-SUDOERS|sed -r -i 's/[ \t]+$//g;/^$/d'|sudo tee 1>/dev/null /etc/sudoers.d/99-keep-vars
Defaults    env_keep+="CANDID_* CLOUD_* DISPLAY EDITOR HOME LANDSCAPE_* LANG MAAS_* MACHINE_* PG_* PYTHONWARNINGS RBAC_* SHOW_ME SHOW_ME_* SM_* SSP_* XAUTHORITY XAUTHORIZATION *_PROXY *_proxy"
SUDOERS
apt install landscape-server-quickstart landscape-client -yqf
if [ -f /etc/ssl/certs/show-me_host.pem ];then ln -sf /etc/ssl/certs/show-me_host.pem /etc/landscape/landscape_server.pem;fi
if [ -f /etc/ssl/certs/show-me_ca.crt ];then ln -sf /etc/ssl/certs/show-me_ca.crt /etc/landscape/landscape_server_ca.crt;fi
if [ -L /etc/ssl/certs/landscape_server.pem ];then echo "ssl_public_key = /etc/ssl/certs/landscape_server.pem"|tee 1>/dev/null -a /etc/landscape/client.conf;fi
if [ -f /usr/local/lib/show-me/landscape.lynx -a  -f /usr/local/bin/show-me_lynx-web-init.sh ];then  /usr/local/bin/show-me_lynx-web-init.sh;fi
if [ -f /etc/landscape/client.conf ];then ln -sf /etc/landscape/client.conf /etc/show-me/www/landscape-client.conf;fi
landscape-config -k /etc/landscape/landscape_server.pem -t $(hostname -s) -u "https://${CLOUD_PUBLIC_FQDN}/message-system" --ping-url "http://${CLOUD_PUBLIC_FQDN}/ping" -a standalone --http-proxy= --https-proxy= --script-users=ALL --access-group=global --tags=show-me-demo,ubuntu --silent --log-level=debug
if $(test -n "$(command 2>/dev/null -v lxd.lxc)");then su - $(id -un 1000) -c 'sudo snap refresh lxd --channel latest/stable';else su - $(id -un 1000) -c 'sudo snap install lxd';fi
if [ -f /usr/local/bin/show-me_landscape_lxd-init.sh ];then /usr/local/bin/show-me_landscape_lxd-init.sh;fi
if [ -f /usr/local/bin/show-me_file-service_init.sh ];then /usr/local/bin/show-me_file-service_init.sh;fi
if [ -f /usr/local/bin/show-me/show-me_finishing-script_all.sh ];then /usr/local/bin/show-me/show-me_finishing-script_all.sh;fi
