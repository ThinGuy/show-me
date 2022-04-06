#!/bin/bash
# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $SM_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }

if ! $(dpkg -l haproxy|grep -qE '^ii');then sudo apt install haproxy;fi


cat <<HAPROXY|tee 1>/dev/null /etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    log /dev/log local1 notice
    maxconn 4096
    user haproxy
    group haproxy
    spread-checks 0
    tune.ssl.default-dh-param 1024
    ssl-default-bind-ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:!DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:!DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:!CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA
    ssl-default-bind-options no-tlsv10

defaults
    log global
    mode http
    option httplog
    option dontlognull
    retries 3
    timeout queue 60000
    timeout connect 5000
    timeout client 120000
    timeout server 120000

frontend ${CLOUD_PUBLIC_FQDN}-80
    bind 0.0.0.0:80
    default_backend landscape-http
    mode http
    timeout client 300000
    acl ping path_beg -i /ping
    acl repository path_beg -i /repository
    redirect scheme https unless ping OR repository
    use_backend landscape-ping if ping

backend landscape-http
    mode http
    timeout server 300000
    balance leastconn
    option httpchk HEAD / HTTP/1.0
    errorfile 403 /var/lib/haproxy/service_landscape-http/403.http
    errorfile 500 /var/lib/haproxy/service_landscape-http/500.http
    errorfile 502 /var/lib/haproxy/service_landscape-http/502.http
    errorfile 503 /var/lib/haproxy/service_landscape-http/503.http
    errorfile 504 /var/lib/haproxy/service_landscape-http/504.http
    server ${CLOUD_LOCAL_HOSTNAME} ${CLOUD_LOCAL_IPV4}:8080 check maxconn 20

backend landscape-ping
    mode http
    timeout server 300000
    balance leastconn
    option httpchk HEAD / HTTP/1.0
    errorfile 403 /var/lib/haproxy/service_landscape-http/403.http
    errorfile 500 /var/lib/haproxy/service_landscape-http/500.http
    errorfile 502 /var/lib/haproxy/service_landscape-http/502.http
    errorfile 503 /var/lib/haproxy/service_landscape-http/503.http
    errorfile 504 /var/lib/haproxy/service_landscape-http/504.http
    server ${CLOUD_LOCAL_HOSTNAME} ${CLOUD_LOCAL_IPV4}:8070 check maxconn 20 
    
frontend ${CLOUD_PUBLIC_FQDN}-443
    bind 0.0.0.0:443 ssl crt /etc/ssl/certs/landscape_basic-chained.pem no-sslv3
    default_backend landscape-https
    mode http
    timeout client 300000
    http-request set-header X-Forwarded-Proto https
    acl message path_beg -i /message-system
    acl attachment path_beg -i /attachment
    acl api path_beg -i /api
    acl prometheus_metrics path_beg -i /metrics
    acl ping path_beg -i /ping
    http-request deny if prometheus_metrics
    use_backend landscape-message if message
    use_backend landscape-message if attachment
    use_backend landscape-api if api
    use_backend landscape-ping if ping

backend landscape-https
    mode http
    timeout server 300000
    balance leastconn
    option httpchk HEAD / HTTP/1.0
    errorfile 403 /var/lib/haproxy/service_landscape-https/403.http
    errorfile 500 /var/lib/haproxy/service_landscape-https/500.http
    errorfile 502 /var/lib/haproxy/service_landscape-https/502.http
    errorfile 503 /var/lib/haproxy/service_landscape-https/503.http
    errorfile 504 /var/lib/haproxy/service_landscape-https/504.http
    server ${CLOUD_LOCAL_HOSTNAME} ${CLOUD_LOCAL_IPV4}:8080 check maxconn 20 ssl ca-file /etc/ssl/certs/landscape_server_ca.crt

backend landscape-api
    mode http
    timeout server 300000
    balance leastconn
    option httpchk HEAD / HTTP/1.0
    errorfile 403 /var/lib/haproxy/service_landscape-https/403.http
    errorfile 500 /var/lib/haproxy/service_landscape-https/500.http
    errorfile 502 /var/lib/haproxy/service_landscape-https/502.http
    errorfile 503 /var/lib/haproxy/service_landscape-https/503.http
    errorfile 504 /var/lib/haproxy/service_landscape-https/504.http
    server ${CLOUD_LOCAL_HOSTNAME} ${CLOUD_LOCAL_IPV4}:9080 check maxconn 20 ssl ca-file /etc/ssl/certs/landscape_server_ca.crt

backend landscape-message
    mode http
    timeout server 300000
    balance leastconn
    option httpchk HEAD / HTTP/1.0
    errorfile 403 /var/lib/haproxy/service_landscape-https/403.http
    errorfile 500 /var/lib/haproxy/service_landscape-https/500.http
    errorfile 502 /var/lib/haproxy/service_landscape-https/502.http
    errorfile 503 /var/lib/haproxy/service_landscape-https/503.http
    errorfile 504 /var/lib/haproxy/service_landscape-https/504.http
    server ${CLOUD_LOCAL_HOSTNAME} ${CLOUD_LOCAL_IPV4}:8090 check maxconn 20 ssl ca-file /etc/ssl/certs/landscape_server_ca.crt

backend landscape-package-upload
    mode http
    timeout server 300000
    balance leastconn
    option httpchk HEAD / HTTP/1.0
    errorfile 403 /var/lib/haproxy/service_landscape-https/403.http
    errorfile 500 /var/lib/haproxy/service_landscape-https/500.http
    errorfile 502 /var/lib/haproxy/service_landscape-https/502.http
    errorfile 503 /var/lib/haproxy/service_landscape-https/503.http
    errorfile 504 /var/lib/haproxy/service_landscape-https/504.http
    server ${CLOUD_LOCAL_HOSTNAME} ${CLOUD_LOCAL_IPV4}:9100 check maxconn 20 ssl ca-file /etc/ssl/certs/landscape_server_ca.crt
    
HAPROXY

systemctl restart haproxy

RC=${?}

{ [[ $SM_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }

exit ${RC}

