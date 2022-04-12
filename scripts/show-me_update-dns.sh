#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ ${CLOUD_DEBUG} ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

###########################################
#####  Update Cloudflare DNS Record  ######
###########################################

[[ ~/.show-me.rc ]] && { source ~/.show-me.rc; }
### Update DNS Entry
export CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN}"
export CLOUDFLARE_DNS_IP="${CLOUD_PUBLIC_IPV4}"
export CLOUDFLARE_DNS_NAME="${CLOUD_APP_FQDN_LONG}"
export CLOUDFLARE_DNS_ZONE_NAME="ubuntu-show.me"
export CLOUDFLARE_DNS_ZONE_ID="$(curl -sSlL -X GET "https://api.cloudflare.com/client/v4/zones?name=${CLOUDFLARE_DNS_ZONE_NAME}&page=1&per_page=20&order=status&direction=desc&match=all" -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" -H "Content-Type: application/json"|jq -r '.result[].id')"

eval "$(curl -sSlL -X GET "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_DNS_ZONE_ID}/dns_records?name=${CLOUDFLARE_DNS_NAME}" -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" -H "Content-Type: application/json"|jq -r '.result[]|"export CLOUDFLARE_DDNS_RECORD_ID=\(.id) CLOUDFLARE_DDNS_ZONE_ID=\(.zone_id) CLOUDFLARE_DDNS_NAME=\(.name) CLOUDFLARE_DDNS_IP=\(.content)"')"

if [ -n "${CLOUDFLARE_DDNS_RECORD_ID}" ];then

CLOUDFLARE_DNS_UPDATE=$(curl -sSlL -X PUT "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_DDNS_ZONE_ID}/dns_records/${CLOUDFLARE_DDNS_RECORD_ID}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"type":"A","name":"'${CLOUDFLARE_DDNS_NAME}'","content":"'${CLOUDFLARE_DDNS_IP}'","ttl":120,"proxied":false}')
RC=$?
export CLOUDFLARE_DNS_SUCCESSFUL="$(echo "${CLOUDFLARE_DNS_UPDATE}"|jq -r '.success')"

else

CLOUDFLARE_DNS_CREATE=$(curl -sSlL -X POST "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_DNS_ZONE_ID}/dns_records" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'${CLOUDFLARE_DNS_NAME}'","content":"'${CLOUDFLARE_DNS_IP}'","ttl":120,"proxied":false}')

export CLOUDFLARE_DNS_SUCCESSFUL="$(echo "${CLOUDFLARE_DNS_CREATE}"|jq -r '.success')"

fi

[[ ${CLOUDFLARE_DNS_SUCCESSFUL} = true ]] && { RC=0; } || { RC=1; }

echo "DNS Update Successful? ${CLOUDFLARE_DNS_SUCCESSFUL}"

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }

exit ${RC}