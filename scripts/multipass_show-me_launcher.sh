#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }


export PROG_DIR="$( cd $(dirname ${0})/../.. && pwd )"

export LOG="/tmp/$(basename  ${x//\.sh/.log})"
[[ -f $LOG ]] || { install -o $(id -un $USER) -g $(id -gn $USER) -m 0644 -d ${LOG}; }
{
P=$(uname);export PLAT=${P,,}

export CLOUD_APP=${1:-landscape} CLOUD_PARTITION=multipass CLOUD_APP_GIT="https://github.com/ThinGuy/show-me.git"
[[ ${CLOUD_APP,,} =~ landscape ]] && { declare -agOS=(bionic);exportREC_OS=${SM_OS[0]};exportRAM='4096M'CPU='4'VHD='20G'; }
[[ ${CLOUD_APP,,} =~ maas ]] && { declare -agOS=(focal jammy);exportREC_OS=${SM_OS[0]};exportRAM='4096M'CPU='4'VHD='30G'; }
[[ ${PLAT,,} = darwin ]] && { [[ $(uname -m) = x86_64 ]] && { CLOUD_ARCH=$(uname -m|sed 's/x86_/amd/'); }; }
[[ ${PLAT,,} = linux ]]  && { exportDIST=$(/bin/grep -oP '(?<=^ID=)[^$]+' /etc/os-release); }
[[ ${SM_DIST,,} = ubuntu ]] && { export CLOUD_ARCH=$(dpkg --print-architecture); }

#macOS
#
#Recommend installing homebrew
#/bin/bash -c "$(curl -fsSlL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#
#Install latest VirtualBox from https://download.virtualbox.org/virtualbox
#Install latest Multipass from https://multipass.run/download/macos
#
#Set multipass to use VirtualBox as its hypervisor
#
#sudo multipass set local.driver=virtualbox
#
#Display networks available
#
#$ multipass networks
#
#Name Type      Description
#en0  Ethernet  Ethernet
#en1  wifi      Wi-Fi (AirPort)
#en2  Ethernet  PCI Ethernet Slot Internal@0,28,4, Port 1
#en3  Ethernet  PCI Ethernet Slot Internal@0,28,4, Port 2
#
#
#Note the name of the network that has internet access
#
#sudo multipass set local.bridged-network=en1
#
#export VBOXURL="https://download.virtualbox.org/virtualbox/$(curl -sSlL  https://download.virtualbox.org/virtualbox/LATEST.TXT)"
#curl -sSlL ${VBOXURL}|awk -F'>|<' -v U=${VBOXURL} '/OSX/{print U"/"$'

export CLOUD_APP=${1:-landscape}

[[ ${CLOUD_APP,,} =~ landscape ]] && { declare -agOS=(bionic);exportREC_OS=${SM_OS[0]};exportRAM='4096M'CPU='4'VHD='20G'; }
[[ ${CLOUD_APP,,} =~ maas ]] && { declare -agOS=(focal jammy);exportREC_OS=${SM_OS[0]};exportRAM='4096M'CPU='4'VHD='30G'; }

[[ ${PLAT,,} = darwin ]] && { export TPUT_ARGS=''; } || { export TPUT_ARGS='-x'; }

mpsh (){
	multipass shell ${CLOUD_APP,,};
	};export -f mpsh

mpip(){
  local MPIP=$(multipass list|awk '/'${CLOUD_APP,,}'.*Running/NR>1{print $3}')
  local V4ADDR_REGX='(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]?)'
  local V4CIDR_REGX='(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$'
  [[ $MPIP =~ $V4CIDR_REGX ]] || [[ $MPIP =~ $V4ADDR_REGX ]] && { echo "${MPIP}";return 0; } || { echo "N/A";return 1; }
  };export -f mpip

mpst(){
  local mpstat=$(multipass list|awk '/'${CLOUD_APP,,}'.*Running/NR>1{print $2}')
  multipass list 2>&1|awk 'IGNORECASE=1;/'${CLOUD_APP,,}'/&&/run|start/{print $2}';
  };export -f mpst

mpst-check() {
  local mpstate=$(multipass list|awk '/'${CLOUD_APP,,}'/NR>1{print $2}')
	[[ ${mpstate,,} = running ]] && { echo running; }
	[[ ${mpstate,,} = starting ]] && { echo starting; }
	[[ -z ${mpstate,,} ]] && { echo unknown; }
};export -f mpst-check

mpip-check() {
  local MPIP=$(multipass list|awk '/'${CLOUD_APP,,}'.*Running/NR>1{print $3}')
  local V4ADDR_REGX='(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]?)'
  local V4CIDR_REGX='(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$'
  [[ $MPIP =~ $V4CIDR_REGX ]] || [[ $MPIP =~ $V4ADDR_REGX ]] && { echo valid;return 0; } || { echo invalid;return 1; }
};export -f mpip-check

[[ ${PLAT,,} = darwin && -z $(sudo multipass 2>/dev/null get local.bridged-network) ]] && { printf "\e[4G\e[0;1;38;2;255;0;0mERROR\e[0m Multipass not configured for bridged networking.  exiting";exit 1; }



printf '%s\n' smcup rmam civis clear|tput ${TPUT_ARGS} -S -
stty -echo
trap 'reset ; stty echo;printf '"'"'%s\n'"'"' rmcup smam cnorm|tput -S - ; trap - INT TERM EXIT ; [[ -n ${FUNCNAME} ]] && return || exit ; trap - INT TERM EXIT;' INT TERM EXIT

export CLOUD_INIT="${PROG_DIR}/${CLOUD_APP,,}/${CLOUD_PARTITION,,}/${CLOUD_PARTITION,,}_show-me_${CLOUD_APP}_user-data_${CLOUD_ARCH,,}.yaml"
[[ ! -f ${CLOUD_INIT} ]] && { printf "\n\e[4G\e[0;1;38;2;255;0;0mERROR\e[0m: Could not find the cloud-init file \"\e[0;1;38;2;255;200;0m${CLOUD_INIT##*/}\e[0m\".\n\e[11GExpected to find it in in: ${CLOUD_INIT%/*}.\n\n\e[11G\e[0;1;38;2;255;200;0mExiting\e[0m\n\n";exit 1; }


printf "\e[2G\e[0;1;38;2;255;255;255mStarting your \"Show Me ${CLOUD_APP^} Demo\"\e[0,\n\n";


[[ -n $(multipass 2>/dev/null list|grep -o ${CLOUD_APP,,}) ]] && { printf "\e[4G- Deleting existing \"Show Me ${CLOUD_APP^} Demo\"  Please wait...\n";multipass delete ${CLOUD_APP,,}; export MP_PURGE=true; } || { export MP_PURGE=false; }
[[ ${MP_PURGE} = true ]] && { printf "\e[4G- Purging just deleted \"Show Me ${CLOUD_APP^} Demo...\n";multipass purge; } || { true; }
printf "\e[4G- Launching your \"Show Me ${CLOUD_APP^} Demo\"  Please wait...\n"
((multipass &>/tmp/multipass-launch.log launch --verbose --name ${CLOUD_APP,,} -c 4 -d 20G -m 4096M --cloud-init ~/Dropbox/${CLOUD_APP,,}-user-data.yaml --network bridged --timeout 900 bionic) &)
sleep 2
export MPSTATUS=$(multipass list|awk '/'${CLOUD_APP,,}'/NR>1{print tolower($2)}')
tput sc;printf "\e[3G - Waiting for your \"Show Me ${CLOUD_APP^} Demo\" to enter a running state.\n\n\e[4GPlease be patient as Ubuntu images may have to download\n\n"
while [[ ! ${MPSTATUS,,} = running ]];do tail -n 1 /tmp/multipass-launch.log;export MPSTATUS=$(multipass list|awk '/'${CLOUD_APP,,}'/NR>1{print tolower($2)}');done;tput el1;tput rc;echo
multipass exec ${CLOUD_APP,,} -- bash -c 'tail -n +0 --pid=$$ -f /var/log/cloud-init-output.log | { sed "/'${CLOUD_APP^}' Show Me Demo Installed/ q" && kill $$ ;}'
export MP_IP=$(multipass list|awk '/'${CLOUD_APP,,}'.*Running/{print $3}')
[[ ${MP_IP} = "N/A" ]] || { sudo sed -i.pre-${CLOUD_APP,,} "/${CLOUD_APP,,}.ubuntu-show.me/d" /etc/hosts; }
[[ ${MP_IP} = "N/A" ]] || { echo "${MP_IP}  ${CLOUD_APP,,}.ubuntu-show.me ${CLOUD_APP,,}"|sudo tee 1>/dev/null -a /etc/hosts; }
export MP_IP=$(multipass list|awk '/'${CLOUD_APP,,}'.*Running/{print $3}')

[[ ${MP_IP} = "N/A" ]] || { echo "Ubuntu-Show-Me-related files available on http://${MP_IP}:9999"; }
[[ ${MP_IP} = "N/A" ]] || { echo "Landscape Server available on https://${CLOUD_APP,,}.ubuntu-show.me"; }
[[ ${MP_IP} = "N/A" ]] || { curl -sslL http://${MP_IP}:9999/show-me_ca.crt --output $HOME/show-me_ca.crt; }
[[ ! ${MP_IP} = "N/A" && -f $HOME/show-me_ca.crt ]] && { sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $HOME/show-me_ca.crt; }
[[ ${MP_IP} = "N/A" ]] && { printf "Multipass Could not get an ip address.  Exiting";exit 1; }
} 2>&1|tee -a ${LOG}
trap - INT TERM EXIT
printf '%s\n' sgr0 rmcup smam cnorm|tput -S -
stty echo
{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }
