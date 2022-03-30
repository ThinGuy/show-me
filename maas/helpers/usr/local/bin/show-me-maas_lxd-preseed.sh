#!/bin/bash

cat <<-PRESEED|sed -r 's/[ \t]+$//g;/^$/d'|lxd init --preseed -
config:
  core.https_address: '[::]:8443'
  core.trust_password: ubuntu
networks:
- config:
    dns.domain: ubuntu-show.me
    dns.mode: dynamic
    ipv4.address: 10.10.10.1/24
    ipv4.nat: true
    ipv4.dhcp: true
    ipv6.address: none
  description: "LXD Internal Network for Show-Me Demos"
  name: lxdbr0
  type: ""
  project: default
storage_pools:
- config: {}
  description: ""
  name: default
  driver: dir
profiles:
- config: {}
  description: Default LXD profile
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
- config:
    boot.autostart: "false"
    user.user-data: |
      #cloud-config
      final_message: 'Landscape Client completed Installing in \$UPTIME'
      manage_etc_hosts: false
      timezone: America/Los_Angeles
      locale: en_US.UTF-8
      packages: [build-essential, jq, landscape-client, vim]
      package_update: true
      package_upgrade: true
      packages: [jq, landscape-client, vim]
      ssh_pwauth: true
      ssh_authorized_keys:
       - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDu4nob6Cm35j0CrdudDXGSjGzu8u1hJiZieoEi7Yk6G6tGCU+mVPp4Ny7K7VEzAj/HLHMgsHFIKDqJRYao7WPiXaGeRfuGKg2FtGwNlBlHkgulqCSwzke271sQWZkyYbdpBwXlkCiamv0ukyC7pJXYENc5Mri/OMYFhfJ93jYUMi0JFAFE+x3V9EMUsj8FBJgmYlBRRE7dQkVuihRnj4E2bKBJQxF17QAUaGmQQe/zT1UzeQff2C4oHrCfQpieCaZ25hkxDADPsZoJiRFTmPuy6xq4qE7J4AM+ERmFnoSVfE2+yHXXbpGaCtJE/iLj4cl77hbS13iVND7cy6SBdTbv demo@ubuntu-show.me
      write_files:
      - encoding: b64
        path: /home/ubuntu/.ssh/id_rsa
        content: LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUJGd0FBQUFkemMyZ3RjbgpOaEFBQUFBd0VBQVFBQUFRRUE3dUo2RytncHQrWTlBcTNiblExeGtveHM3dkx0WVNZbVlucUJJdTJKT2h1clJnbFBwbFQ2CmVEY3V5dTFSTXdJL3h5eHpJTEJ4U0NnNmlVV0dxTzFqNGwyaG5rWDdoaW9OaGJSc0RaUVpSNUlMcGFna3NNNUh0dTliRUYKbVpNbUczYVFjRjVaQW9tcHI5THBNZ3U2U1YyQkRYT1RLNHZ6akdCWVh5ZmQ0MkZESXRDUlFCUlBzZDFmUkRGTEkvQlFTWQpKbUpRVVVSTzNVSkZib29VWjQrQk5teWdTVU1SZGUwQUZHaHBrRUh2ODA5Vk0za0gzOWd1S0I2d24wS1luZ21tZHVZWk1RCndBejdHYUNZa1JVNWo3c3VzYXVLaE95ZUFEUGhFWmhaNkVsWHhOdnNoMTEyNlJtZ3JTUlA0aTQrSEplKzRXMHRkNGxUUSsKM011a2dYVTI3d0FBQThneFpWZ0lNV1ZZQ0FBQUFBZHpjMmd0Y25OaEFBQUJBUUR1NG5vYjZDbTM1ajBDcmR1ZERYR1NqRwp6dTh1MWhKaVppZW9FaTdZazZHNnRHQ1UrbVZQcDROeTdLN1ZFekFqL0hMSE1nc0hGSUtEcUpSWWFvN1dQaVhhR2VSZnVHCktnMkZ0R3dObEJsSGtndWxxQ1N3emtlMjcxc1FXWmt5WWJkcEJ3WGxrQ2lhbXYwdWt5QzdwSlhZRU5jNU1yaS9PTVlGaGYKSjkzallVTWkwSkZBRkUreDNWOUVNVXNqOEZCSmdtWWxCUlJFN2RRa1Z1aWhSbmo0RTJiS0JKUXhGMTdRQVVhR21RUWUvegpUMVV6ZVFmZjJDNG9IckNmUXBpZUNhWjI1aGt4REFEUHNab0ppUkZUbVB1eTZ4cTRxRTdKNEFNK0VSbUZub1NWZkUyK3lIClhYYnBHYUN0SkUvaUxqNGNsNzdoYlMxM2lWTkQ3Y3k2U0JkVGJ2QUFBQUF3RUFBUUFBQVFBRHNWcGZTS3JJYmhXZXdudDQKSHZRdVpua2ZiQmxYNldxUVNjSHA0OCtLV3JlK1lsSGRNQlRvVlFrLzE1NVNhOWRoSjd3TkV3T1ZTa1hwWVNGRHJRMWdpQwpYT2l6OW9DZ25JRXo2aGtSclNpWU1nWVZqdkRZK3ZQbDNKdGpkRVdUYjA2c2Y1MnMxWGZCamZRQ1RMNVB4V3oyeWl0SjhmCkdaK3RPeTVhd3NJZmRGOFJDVml2NFVzaThtNndXL2VMdmhLODFqS3JaZEtCUzNycXRGcWRaZ1M3MlBwWU9OeDdOakxCSTIKazZ3K2ZDUVJ4Y3d6V0ExdTdaR1d6UTMyeWRlZlNtWGE4U3BjZ25RUHhTVGtGQmpQY28rbTdNTW5BZlVMTjRBT2J3b3NNNgpLNHNKUVN4bG95TjU4VHlHQmEvSGJsQ3NxcXN1S2tEMCt4Yjlwd0lCMHNDRkFBQUFnQjMrTHR6dG1sdFQzQmF2eWsrS2VxCld2RmFLZkpBQzdkZG9LQzkrQ05JaXpYYmxITXozT1hhK215czl2Qkw2aEF6d0Ixd011RGIxVWhEWU4xeEZKRG50UW9pNHgKeTdLL3NGOTVzYVlsejQ2YzIxVnVvWktSK0V1ZEtCeFFDTmhMREJUQWhhSkJmWjU0ZVZWTjJGUnFIc3pMS1pJMW00bitTOQpJOVR0MHVDSDJnQUFBQWdRRDZEaEZsd1pSc3Z6aFQvNU1zRXJ3MzkrV3hKNVlGVXlvc082TDlIV0RGRzVEdkNqMEdxN0FxCmtkRHVYZ0FndkN4T08rK3RKZjlpK1c4c3FLcXJ0c2JPUnFFb2xtb1NvbjREd0VaQ2l1ZmdGS2tQa1J4d0I5ZGFNNndXSS8Kd1JucUVqSGVSdHlFOWFDNVpuczVqdmY1WEw1S3BpZ0tPTmpKa0thdG81NkJTbFN3QUFBSUVBOUpCc0gvRDQ2MHhjM09xTgo1d2JMMnUrTzNVWnA2S0RxYnpmaldLVzVRRXVtVFE0QUUrcytmQ3pQOExQNnE5TGdrTXBwMDgxNHY5cUw5VXVRR0ZjdlRoCkFYNXBidDhIRVc0MEgyMVdjc1pIdWRzMEx0enN5OThhbVlzOW12MDJIbkt1NnFqb214V0JVY0lwWkxnSHVsbDgvaG42UisKeU5ZQmhxOVkwOGs0d20wQUFBQVRaR1Z0YjBCMVluVnVkSFV0YzJodmR5NXRaUT09Ci0tLS0tRU5EIE9QRU5TU0ggUFJJVkFURSBLRVktLS0tLQo=
        permissions: 400
        owner: 'ubuntu:ubuntu'
      - encoding: b64
        path: /home/ubuntu/.ssh/id_rsa.pub
        content: c3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFCQVFEdTRub2I2Q20zNWowQ3JkdWREWEdTakd6dTh1MWhKaVppZW9FaTdZazZHNnRHQ1UrbVZQcDROeTdLN1ZFekFqL0hMSE1nc0hGSUtEcUpSWWFvN1dQaVhhR2VSZnVHS2cyRnRHd05sQmxIa2d1bHFDU3d6a2UyNzFzUVdaa3lZYmRwQndYbGtDaWFtdjB1a3lDN3BKWFlFTmM1TXJpL09NWUZoZko5M2pZVU1pMEpGQUZFK3gzVjlFTVVzajhGQkpnbVlsQlJSRTdkUWtWdWloUm5qNEUyYktCSlF4RjE3UUFVYUdtUVFlL3pUMVV6ZVFmZjJDNG9IckNmUXBpZUNhWjI1aGt4REFEUHNab0ppUkZUbVB1eTZ4cTRxRTdKNEFNK0VSbUZub1NWZkUyK3lIWFhicEdhQ3RKRS9pTGo0Y2w3N2hiUzEzaVZORDdjeTZTQmRUYnYgZGVtb0B1YnVudHUtc2hvdy5tZQo=
        permissions: 644
        owner: 'ubuntu:ubuntu'
      runcmd:
        - set -x
        - export DEBIAN_FRONTEND=noninteractive
        - echo $DEFAULT_IP $(hostname -f) $(hostname -s)|tee -a /etc/hosts
        - if [ "\$(readlink -f /etc/resolv.conf)" != "/run/resolvconf/resolv.conf" ];then ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf;fi
        - export DEFAULT_IP=\$(ip -o -4 a show dev \$(ip -o route show default|grep -m1 -oP '(?<=dev )[^ ]+')|grep -m1 -oP '(?<=inet )[^/]+')
        - if \$(test -f /etc/hosts);then sudo sed -i.orig "/127.0.1.1/d;/127.0.0.1/a \$DEFAULT_IP\ \ \$(hostname -f) \$(hostname -s)" /etc/hosts;fi
        - systemctl restart procps.service
        - "wget -P /etc/landscape/ http://192.168.0.17:9999/landscape_server.pem"
        - "wget -P /usr/local/share/ca-certificates http://192.168.0.17:9999/landscape_server_ca.crt"
        - update-ca-certificates --fresh --verbose
        - if \$(test -f /etc/landscape/landscape_server.pem);then chmod 0644 /etc/landscape/landscape_server.pem;fi
        - "if \$(test -f /etc/landscape/landscape_server.pem);then landscape-config -k /etc/landscape/landscape_server.pem -t \$(hostname -s) -u https://$(hostname -f)/message-system --ping-url http://$(hostname -f)/ping -a standalone --http-proxy= --https-proxy= --script-users=ALL --access-group=global --tags=landscape-server,demo,ubuntu --silent --log-level=debug;fi"
  description: Landscape Client Profile
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
      size: 4GB
  name: landscape-client
projects: []
cluster: null
PRESEED

exit 0