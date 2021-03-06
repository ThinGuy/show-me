#!/bin/bash
set -x
echo network: {config: disabled} > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sysctl -w net.ipv4.ip_forward=1
printf "%s\x20%s\x20\x20%s\n" precedence '::ffff:0:0/96' 100 | tee -a /etc/gai.conf
export APT_ARGS="--option=Acquire::ForceIPv4=true --assume-yes --quiet --auto-remove --purge"
hostname landscape
export CLOUD_BRIDGE=ens5
export CLOUD_ARCH='amd64'
export CLOUD_APP='landscape'
export CLOUD_PARTITION='aws'
export CLOUD_APP_GIT="https://github.com/ThinGuy/show-me.git"
export DEBIAN_FRONTEND=noninteractive
"export PYTHONWARNINGS='ignore::DeprecationWarning'"
echo "export PYTHONWARNINGS='ignore::DeprecationWarning'"|sudo tee -a 1>/dev/null /etc/environment
if [ -f /usr/bin/vim.basic ];then echo "export EDITOR='/usr/bin/vim.basic'"|sudo tee -a 1>/dev/null /etc/environment;fi
export DEFAULT_IP="$(ip -o -4 a show $(ip -o r l default|grep ${CLOUD_BRIDGE}|grep -m1 -oP '(?<=dev )[^ ]+')|grep -m1 -oP '(?<=inet )[^/]+')"
export PUBLIC_IP_LIST="$(printf '%s\n' $(dig +short myip.opendns.com @resolver1.opendns.com) $(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com|sed -r 's/\x22//g') $(dig +short txt ch whoami.cloudflare @1.0.0.1|sed -r 's/\x22//g'))"
if [ $(echo "${PUBLIC_IP_LIST}"|uniq -D|wc -l) -eq 3 ];then export PUBLIC_IP=$(echo "${PUBLIC_IP_LIST}"|uniq -d);fi
if [ -n $DEFAULT_IP -o -n $PUBLIC_IP ];then sudo sed -i -r "/127.0|$(hostname -s)/d" /etc/hosts;fi
if [ -n $DEFAULT_IP ];then sudo sed -i -r "1s/^/127.0.0.1\tlocalhost\n${DEFAULT_IP}\t$(hostname -s).ubuntu-show.me $(hostname -s)\n/" /etc/hosts;fi
if [ -n $PUBLIC_IP ];then sudo sed -r -i "/$(hostname -s)$/a $PUBLIC_IP\t$(hostname -s).ubuntu-show.me $(hostname -s)\n/";fi
printf '%s\n' LANG=en_US.UTF-8 LANGUAGE=en_US|sudo tee 1>/dev/null /etc/default/locale
export LANG=en_US.UTF-8 LANGUAGE=en_US
for i in DEFAULT_IP EDITOR LANG LANGUAGE PUBLIC_IP PYTHONWARNINGS CLOUD_APP CLOUD_ARCH CLOUD_APP_GIT CLOUD_BRIDGE CLOUD_PARTITION;do if [ -n "$(eval echo -n \"\$${i}\")" ];then printf "export ${i}=\x22$(eval echo -n \$$i)\x22\n";fi;done|sudo tee -a 1>/dev/null /etc/environment
cat <<SUDOERS|sed -r 's/[ \t]+$//g;/^$/d'|sudo tee 1>/dev/null /etc/sudoers.d/99-default-user
Defaults	env_reset
Defaults	env_keep+="CANDID_* DISPLAY EDITOR HOME LANDSCAPE_* LANG* MAAS_* PG_* PYTHONWARNINGS RBAC_* SSP_* XAUTHORITY XAUTHORIZATION *_IP *_PROXY *_proxy"
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:$HOME/.local/bin"
$(id -un 1000)		ALL=(ALL) NOPASSWD:ALL
SUDOERS
sudo bash -c 'source /etc/environment'
sudo sh -c '. /etc/environment'
. /etc/environment
sudo systemctl restart systemd-networkd systemd-resolved procps.service
sudo update-locale LANG=${LANG} LANGUAGE=${LAUNGUAGE}
echo -en 'locales\tlocales/locales_to_be_generated\tmultiselect\ten_US ISO-8859-1, en_US.UTF-8 UTF-8'|sudo debconf-set-selections
echo -en 'locales\tlocales/default_environment_locale\tselect\ten_US.UTF-8'|sudo debconf-set-selections
sudo apt-key adv --recv --keyserver=hkp://keyserver.ubuntu.com 6E85A86E4652B4E6
sudo apt-add-repository -y 'deb [arch=amd64] http://ppa.launchpad.net/landscape/19.10/ubuntu bionic main'
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
sudo DEBIAN_FRONTEND=noninteractive apt update --option=Acquire::ForceIPv4=true
sudo DEBIAN_FRONTEND=noninteractive apt dist-upgrade ${APT_ARGS}
sudo DEBIAN_FRONTEND=noninteractive apt install ${APT_ARGS} dnsutils, build-essential, debconf-utils, dialog, git, gnupg, jq, lynx, landscape-client, landscape-common, postgresql, postgresql-client, postgresql-common, software
sudo apt-add-repository -y 'deb [arch=amd64] http://ppa.launchpad.net/landscape/19.10/ubuntu bionic main'
sudo apt-key adv --recv --keyserver=hkp://keyserver.ubuntu.com 6E85A86E4652B4E6
sudo DEBIAN_FRONTEND=noninteractive apt-get --option=Acquire::ForceIPv4=true update
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade --option=Acquire::ForceIPv4=true --assume-yes --quiet --auto-remove --purge
sudo DEBIAN_FRONTEND=noninteractive apt-get install dnsutils debconf-utils dialog gnupg --option=Acquire::ForceIPv4=true --assume-yes --quiet --auto-remove --purge
sudo DEBIAN_FRONTEND=noninteractive apt-get remove lxd lxd-client --auto-remove --purge --assume-yes --quiet --fix-broken --option=Acquire::ForceIPv4=true
sudo mkdir -p /etc/show-me/www /etc/show-me/log
if [ -d /opt/show-me ];then sudo rm -rf /opt/show-me;fi
ping -c10 -w1 github.com
sleep 10
sudo git clone https://github.com/ThinGuy/show-me.git /opt/show-me
sleep 10
sudo install -o 0 -g 0 -m 0755 /opt/show-me/scripts/petname-helper.sh /usr/local/bin/petname-helper.sh
sudo install -o 0 -g 0 -m 0755 /opt/show-me/scripts/show-me_lynx-web-init.sh /usr/local/bin/show-me_lynx-web-init.sh
sudo install -o 0 -g 0 -m 0755 /opt/show-me/scripts/add-landscape-clients.sh /usr/local/bin/add-landscape-clients.sh
dd-landscape-clients-petnames.sh/g
sudo install -o 0 -g 0 -m 0400 /opt/show-me/pki/show-me-id_rsa /home/$(id -un 1000)/.ssh/showme_rsa
sudo install -o 0 -g 0 -m 0640 /opt/show-me/pki/show-me-id_rsa.pub /home/$(id -un 1000)/.ssh/showme_rsa.pub
sudo install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me-id_rsa.pub /home/$(id -un 1000)/.ssh/authorized_keys
sudo install -o 0 -g 0 -m 0644 -D /opt/show-me/scripts/landscape.lynx /usr/local/lib/show-me/landscape.lynx
sudo install -o 0 -g 0 -m 0755 -d /usr/local/lib/show-me/petname2/
sudo install -o 0 -g 0 -m 0755 /opt/show-me/scripts/show-me_landscape_lxd-init.sh /usr/local/bin/show-me_landscape_lxd-init.sh
sudo install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_host.pem /etc/ssl/certs/show-me_host.pem
sudo install -o 0 -g 0 -m 0600 /opt/show-me/pki/show-me_host.key /etc/ssl/private/show-me_host.key
sudo install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_ca.crt /etc/ssl/certs/show-me_ca.crt
sudo install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_host.pem /etc/ssl/certs/landscape_server.pem
sudo install -o 0 -g 0 -m 0600 /opt/show-me/pki/show-me_host.key /etc/ssl/private/landscape_server.key
sudo install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_ca.crt /etc/ssl/certs/landscape_server_ca.crt
sudo install -o 0 -g 0 -m 0755 /opt/show-me/scripts/show-me_file-service_init.sh /usr/local/bin/show-me_file-service_init.sh
sudo install -o 0 -g 0 -m 0755 /opt/show-me/scripts/show-me_finishing-script_all.sh /usr/local/bin/show-me_finishing-script_all.sh
sudo install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_ca.crt /etc/show-me/www/show-me_ca.crt
sudo install -o 0 -g 0 -m 0644 /opt/show-me/pki/show-me_host.pem /etc/show-me/www/landscape_server.pem
update-ca-certificates --fresh --verbose
export PG_DBSSL_CRT=/etc/ssl/certs/landscape_server_ca.crt
export PG_DBSSL_PEM=/etc/ssl/certs/landscape_server.pem
export PG_DBSSL_KEY=/etc/ssl/private/landscape_server.key
sudo su - postgres -c "psql postgres -c \"ALTER SYSTEM SET ssl to 'on';\""
sudo su - postgres -c "psql postgres -c \"ALTER SYSTEM SET ssl_ca_file to '${PG_DBSSL_CRT}';\""
sudo su - postgres -c "psql postgres -c \"ALTER SYSTEM SET ssl_cert_file to '${PG_DBSSL_PEM}';\""
sudo su - postgres -c "psql postgres -c \"ALTER SYSTEM SET ssl_key_file to '${PG_DBSSL_KEY}';\""
sudo su - postgres -c "psql postgres -c \"ALTER SYSTEM SET listen_addresses to '*';\""
sudo su - postgres -c "psql postgres -c \"ALTER SYSTEM SET max_connections to '500';\""
sudo su - postgres -c "psql postgres -c \"ALTER SYSTEM SET max_prepared_transactions to '500';\""
sudo - postgres -c 'psql postgres -c "SELECT pg_reload_conf();"'
sudo apt install landscape-server-quickstart landscape-client -yqf --reinstall
if [ -f /etc/ssl/certs/show-me_host.pem ];then sudo ln -sf /etc/ssl/certs/show-me_host.pem /etc/landscape/landscape_server.pem;fi
if [ -f /etc/ssl/certs/show-me_ca.crt ];then sudo ln -sf /etc/ssl/certs/show-me_ca.crt /etc/landscape/landscape_server_ca.crt;fi
if [ -L /etc/ssl/certs/landscape_server.pem ];then echo "ssl_public_key = /etc/ssl/certs/landscape_server.pem"|sudo tee 1>/dev/null -a /etc/landscape/client.conf;fi
if [ -f /usr/local/lib/show-me/landscape.lynx -a  -f /usr/local/bin/show-me_lynx-web-init.sh ];then sudo /usr/local/bin/show-me_lynx-web-init.sh;fi
if [ -f /etc/landscape/client.conf ];then sudo ln -sf /etc/landscape/client.conf /etc/show-me/www/landscape-client.conf;fi
sudo landscape-config -k /etc/landscape/landscape_server.pem -t $(hostname -s) -u "https://$(hostname -s).ubuntu-show.me/message-system" --ping-url "http://$(hostname -s).ubuntu-show.me/ping" -a standalone --http-proxy= --https-proxy= --script-users=ALL --access-group=global --tags=show-me-demo,ubuntu --silent --log-level=debug
if $(test -n "$(command 2>/dev/null -v lxd.lxc)");then su - $(id -un 1000) -c 'sudo snap refresh lxd --channel latest/stable';else su - $(id -un 1000) -c 'sudo snap install lxd';fi
if [ -f /usr/local/bin/show-me_landscape_lxd-init.sh ];then sudo /usr/local/bin/show-me_landscape_lxd-init.sh;fi
if [ -f /usr/local/bin/show-me_file-service_init.sh ];then sudo /usr/local/bin/show-me_file-service_init.sh;fi
if [ -f /usr/local/bin/show-me/show-me_finishing-script_all.sh ];then sudo /usr/local/bin/show-me/show-me_finishing-script_all.sh;fi
