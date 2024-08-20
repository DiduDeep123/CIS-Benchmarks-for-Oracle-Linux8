#!/usr/bin/bash

chmod +x fixing_script_1.sh fix_cramfs.sh fix_freevxfs.sh fix_hfs.sh fix_hfsplus.sh fix_jfss2.sh fix_squashfs.sh \
fix_udf.sh fix_usb_storage.sh fix_dccp.sh fix_rds.sh fix_sctp.sh fix_tipc.sh disable_packet_redirect_sending.sh 

chmod +x enable_reverse_path_filtering.sh enable_tcp_syn_cookies.sh ensure_ip_forwarding_disabled.sh ignore_bogus_icmp_responses.sh \
ignore_broadcast_icmp_req.sh log_suspicious_packets.sh reject_icmp_redirects.sh reject_ipv6_router_advertisements.sh \
reject_source_routed_packets.sh fix_journald.sh

chmod +x disable_core_dump_backtraces.sh disable_core_dump_storage.sh enable_ASLR.sh restrict_ptrace_scope.sh \
etc_ssh_sshd_config_permissions.sh fix_config_audit.sh fix_config_integrity_ckeck.sh etc_ssh_sshd_config_permissions.sh \





./fixing_script_1.sh
./fix_cramfs.sh
./fix_freevxfs.sh
./fix_hfs.sh
./fix_hfsplus.sh
./fix_jfss2.sh
./fix_squashfs.sh
./fix_udf.sh
./fix_usb_storage.sh
./fix_dccp.sh
./fix_rds.sh
./fix_sctp.sh
./fix_tipc.sh
./disable_packet_redirect_sending.sh
./enable_reverse_path_filtering.sh 
./enable_tcp_syn_cookies.sh 
./ensure_ip_forwarding_disabled.sh 
./ignore_bogus_icmp_responses.sh
./ignore_broadcast_icmp_req.sh
./log_suspicious_packets.sh
./reject_icmp_redirects.sh 
./reject_ipv6_router_advertisements.sh
./reject_source_routed_packets.sh
./fix_journald.sh
./disable_core_dump_backtraces.sh 
./disable_core_dump_storage.sh 
./enable_ASLR.sh restrict_ptrace_scope.sh
./etc_ssh_sshd_config_permissions.sh
./fix_config_audit.sh 
./fix_config_integrity_ckeck.sh 
./etc_ssh_sshd_config_permissions.sh



