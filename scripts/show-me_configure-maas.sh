#!/bin/bash

# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }


[[ -f ~/.show-me.rc ]] && source ~/.show-me.rc

maas ${MAAS_PROFILE} maas set-config name=boot_images_auto_import value=true
maas ${MAAS_PROFILE} maas set-config name=boot_images_no_proxy value=false
maas ${MAAS_PROFILE} maas set-config name=commissioning_distro_series value="focal"
maas ${MAAS_PROFILE} maas set-config name=completed_intro value=true
maas ${MAAS_PROFILE} maas set-config name=curtin_verbose value=true
maas ${MAAS_PROFILE} maas set-config name=default_distro_series value="focal"
maas ${MAAS_PROFILE} maas set-config name=default_dns_ttl value=30
maas ${MAAS_PROFILE} maas set-config name=default_min_hwe_kernel value=""
maas ${MAAS_PROFILE} maas set-config name=default_osystem value="ubuntu"
maas ${MAAS_PROFILE} maas set-config name=default_storage_layout value="flat"
maas ${MAAS_PROFILE} maas set-config name=disk_erase_with_quick_erase value=false
maas ${MAAS_PROFILE} maas set-config name=disk_erase_with_secure_erase value=true
maas ${MAAS_PROFILE} maas set-config name=dnssec_validation value="no"
maas ${MAAS_PROFILE} maas set-config name=dns_trusted_acl value=""
maas ${MAAS_PROFILE} maas set-config name=enable_analytics value=true
maas ${MAAS_PROFILE} maas set-config name=enable_disk_erasing_on_release value=false
maas ${MAAS_PROFILE} maas set-config name=enable_http_proxy value=true
maas ${MAAS_PROFILE} maas set-config name=enable_third_party_drivers value=true
maas ${MAAS_PROFILE} maas set-config name=enlist_commissioning value=true
maas ${MAAS_PROFILE} maas set-config name=force_v1_network_yaml value=false
maas ${MAAS_PROFILE} maas set-config name=http_proxy value=""
maas ${MAAS_PROFILE} maas set-config name=kernel_opts value="nvme_core.multipath=0 pci=realloc=off console=tty0 console=ttyS0,115200n8 intel_iommu=on kvm-intel.nested=1 kvm-intel.enable_apicv=n kvm.ignore_msrs=1"
maas ${MAAS_PROFILE} maas set-config name=maas_auto_ipmi_k_g_bmc_key value=""
maas ${MAAS_PROFILE} maas set-config name=maas_auto_ipmi_user value="maas"
maas ${MAAS_PROFILE} maas set-config name=maas_auto_ipmi_user_privilege_level value="ADMIN"
maas ${MAAS_PROFILE} maas set-config name=maas_internal_domain value="maas-internal"
maas ${MAAS_PROFILE} maas set-config name=maas_name value="Show-Me"
maas ${MAAS_PROFILE} maas set-config name=maas_proxy_port value=8000
maas ${MAAS_PROFILE} maas set-config name=maas_syslog_port value=5247
maas ${MAAS_PROFILE} maas set-config name=max_node_commissioning_results value=10
maas ${MAAS_PROFILE} maas set-config name=max_node_installation_results value=3
maas ${MAAS_PROFILE} maas set-config name=max_node_testing_results value=10
maas ${MAAS_PROFILE} maas set-config name=network_discovery value="enabled"
maas ${MAAS_PROFILE} maas set-config name=node_timeout value=30
maas ${MAAS_PROFILE} maas set-config name=ntp_external_only value=false
maas ${MAAS_PROFILE} maas set-config name=ntp_servers value="ntp.ubuntu.com"
maas ${MAAS_PROFILE} maas set-config name=prefer_v4_proxy value=false
maas ${MAAS_PROFILE} maas set-config name=prometheus_enabled value=false
maas ${MAAS_PROFILE} maas set-config name=prometheus_push_gateway value=null
maas ${MAAS_PROFILE} maas set-config name=prometheus_push_interval value=60
maas ${MAAS_PROFILE} maas set-config name=release_notifications value=true
maas ${MAAS_PROFILE} maas set-config name=remote_syslog value=null
maas ${MAAS_PROFILE} maas set-config name=subnet_ip_exhaustion_threshold_count value=16
maas ${MAAS_PROFILE} maas set-config name=upstream_dns value="1.1.1.1 1.0.0.1 9.9.9.9"
maas ${MAAS_PROFILE} maas set-config name=use_peer_proxy value=false
maas ${MAAS_PROFILE} maas set-config name=use_rack_proxy value=true
maas ${MAAS_PROFILE} maas set-config name=vcenter_datacenter value=""
maas ${MAAS_PROFILE} maas set-config name=vcenter_password value=""
maas ${MAAS_PROFILE} maas set-config name=vcenter_server value=""
maas ${MAAS_PROFILE} maas set-config name=vcenter_username value=""
maas ${MAAS_PROFILE} maas set-config name=windows_kms_host value=null

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }
exit 0
