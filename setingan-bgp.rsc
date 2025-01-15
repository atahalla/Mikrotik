
/interface bridge
add name=bridge1
/interface ethernet
set [ find default-name=ether1 ] comment="TO TELKOM"
set [ find default-name=sfp-sfpplus1 ] comment="TO SW Tarmoc"
/interface l2tp-client
add connect-to=103.95.43.194 name=hub user=Manganti2
/interface wireguard
add listen-port=13231 mtu=1420 name=bpn
/ip pool
add name=dhcp_pool0 ranges=192.168.200.2-192.168.200.254
add name=pool1 ranges=192.168.22.100-192.168.22.254
add name=dhcp_pool2 ranges=192.168.200.2-192.168.200.30
/port
set 0 name=serial0
/routing bgp template
set default disabled=no routing-table=main
add as=151568 disabled=no input.filter=rtbh-in multihop=yes name=RTBH output.filter-chain=rtbh-out .network=""
add as=151568 disabled=no name=bgp output.no-client-to-client-reflection=yes router-id=36.94.254.22 routing-table=main
add as=65001 disabled=no name=bpn router-id=192.168.22.1 routing-table=main
/interface bridge port
add bridge=bridge1 interface=ether2
add bridge=bridge1 interface=ether3
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ip settings
set tcp-syncookies=yes
/interface l2tp-server server
set enabled=yes use-ipsec=yes
/interface ovpn-server server
set certificate=CA enabled=yes
/interface pptp-server server
# PPTP connections are considered unsafe, it is suggested to use a more modern VPN protocol instead
set enabled=yes
/interface sstp-server server
set enabled=yes
/interface wireguard peers
add allowed-address=0.0.0.0/0 endpoint-port=13231 interface=bpn is-responder=yes name=bpn public-key="c+kUPktaKhC7r7Uv52ByBFxQ4XPq5Ni2so034aaYPFo="
/ip address
add address=36.94.254.22/24 interface=ether1 network=36.94.254.0
add address=192.168.22.1/24 interface=ether1 network=192.168.22.0
add address=103.253.231.1/24 disabled=yes interface=ether1 network=103.253.231.0
add address=103.253.231.2/24 disabled=yes interface=ether1 network=103.253.231.0
add address=192.168.200.1/24 interface=ether2 network=192.168.200.0
add address=192.168.103.1/24 comment="ip ini dipakai di ccr bendung, disini di disable" disabled=yes interface=sfp-sfpplus1 network=192.168.103.0
add address=103.253.231.9/29 disabled=yes interface=sfp-sfpplus1 network=103.253.231.8
add address=103.253.231.1/30 interface=sfp-sfpplus1 network=103.253.231.0
add address=103.253.231.100/24 interface=ether1 network=103.253.231.0
add address=192.168.1.1/24 interface=sfp-sfpplus1 network=192.168.1.0
add address=103.253.231.5/30 disabled=yes interface=bpn network=103.253.231.4
/ip dhcp-server
add address-pool=pool1 disabled=yes interface=sfp-sfpplus1 name=dhcp1 relay=192.168.22.1
# DHCP server can not run on slave interface!
add address-pool=dhcp_pool2 interface=ether2 name=dhcp2
/ip dhcp-server network
add address=192.168.200.0/24 gateway=192.168.200.1
/ip dns
set servers=8.8.8.8,1.1.1.1,8.8.4.4
/ip firewall address-list
add address=103.253.231.0/24 list=bgp-net
add address=192.168.200.0/24 list=bgp-net
add address=192.168.22.0/24 list=bgp-net
add address=172.25.101.0/24 list=bgp-net
add list=ddos-attackers
add list=ddos-targets
add address=192.168.200.0/24 list=20.20.1.0/24
add address=172.100.1.0/24 list=bgp-net
add address=103.253.231.32/29 list=bgp-net
/ip firewall filter
add action=add-src-to-address-list address-list=SSH_BlackList_1 address-list-timeout=1m chain=input comment="Drop SSH&TELNET Brute Forcers" \
    connection-state=new dst-port=22-23 protocol=tcp
add action=add-src-to-address-list address-list=SSH_BlackList_2 address-list-timeout=1m chain=input connection-state=new dst-port=22-23 protocol=tcp \
    src-address-list=SSH_BlackList_1
add action=add-src-to-address-list address-list=SSH_BlackList_3 address-list-timeout=1m chain=input connection-state=new dst-port=22-23 protocol=tcp \
    src-address-list=SSH_BlackList_2
add action=add-src-to-address-list address-list=IP_BlackList address-list-timeout=1d chain=input connection-state=new dst-port=22-23 protocol=tcp \
    src-address-list=SSH_BlackList_3
add action=drop chain=input dst-port=22-23 protocol=tcp src-address-list=IP_BlackList
add action=drop chain=input comment="drop ftp brute forcers" disabled=yes dst-port=21 protocol=tcp src-address-list=black_list
add action=add-src-to-address-list address-list=black_list address-list-timeout=1d chain=input connection-state=new disabled=yes dst-port=21 protocol=\
    tcp src-address-list=ftp_stage3
add action=add-src-to-address-list address-list=ftp_stage3 address-list-timeout=1m chain=input connection-state=new disabled=yes dst-port=21 protocol=\
    tcp src-address-list=ftp_stage2
add action=add-src-to-address-list address-list=ftp_stage2 address-list-timeout=1m chain=input connection-state=new disabled=yes dst-port=21 protocol=\
    tcp src-address-list=ftp_stage1
add action=add-src-to-address-list address-list=ftp_stage1 address-list-timeout=1m chain=input connection-state=new disabled=yes dst-port=21 protocol=\
    tcp
add action=return chain=detect-ddos disabled=yes dst-limit=32,32,src-and-dst-addresses/10s
add action=add-dst-to-address-list address-list=ddos-targets address-list-timeout=10m chain=detect-ddos disabled=yes
add action=add-src-to-address-list address-list=ddos-attackers address-list-timeout=10m chain=detect-ddos disabled=yes
add action=return chain=detect-ddos disabled=yes dst-limit=32,32,src-and-dst-addresses/10s protocol=tcp tcp-flags=syn,ack
/ip firewall mangle
add action=mark-routing chain=prerouting disabled=yes dst-address=103.253.231.32/29 new-routing-mark=main passthrough=yes
/ip firewall nat
add action=masquerade chain=srcnat src-address=192.168.22.0/24
add action=masquerade chain=srcnat src-address=192.168.200.0/24
add action=masquerade chain=srcnat out-interface=ether1 src-address=172.10.1.0/30
add action=masquerade chain=srcnat disabled=yes src-address=103.253.231.0/24
add action=dst-nat chain=dstnat disabled=yes src-address=103.253.231.32/29 to-addresses=103.253.231.26
add action=dst-nat chain=dstnat disabled=yes dst-address=103.253.231.25 to-addresses=103.253.231.33
add action=masquerade chain=srcnat disabled=yes out-interface=ether1 src-address=103.253.231.24/29
add action=masquerade chain=srcnat disabled=yes out-interface=ether1 src-address=20.20.1.0/24
add action=netmap chain=srcnat comment="----nat di disable (tidak diperlukan). ip public sudah bisa di distribusikan" disabled=yes to-addresses=\
    103.253.231.1
add action=dst-nat chain=dstnat comment="----nat di disable (tidak diperlukan). ip public sudah bisa di distribusikan" disabled=yes dst-address=\
    103.253.231.2 to-addresses=192.168.22.2
add action=dst-nat chain=dstnat comment="----nat di disable (tidak diperlukan). ip public sudah bisa di distribusikan" disabled=yes dst-address=\
    103.253.231.1 dst-port=8811 protocol=tcp to-addresses=192.168.22.2 to-ports=8291
add action=dst-nat chain=dstnat dst-address=103.253.231.1 dst-port=8811 protocol=tcp to-addresses=20.20.1.2 to-ports=8291
add action=dst-nat chain=dstnat disabled=yes dst-address=103.253.231.2 dst-port=9696 protocol=tcp to-addresses=192.168.103.5 to-ports=80
add action=dst-nat chain=dstnat comment="----nat di disable (tidak diperlukan). ip public sudah bisa di distribusikan" disabled=yes dst-address=\
    103.253.231.8/29 to-addresses=192.168.22.2
add action=dst-nat chain=dstnat disabled=yes dst-address=103.253.231.102 to-addresses=20.20.1.43
add action=dst-nat chain=dstnat comment="IP Public di gunakana" disabled=yes dst-address=103.253.231.24/29 to-addresses=20.20.1.43
add action=dst-nat chain=dstnat disabled=yes dst-address=103.253.231.2 dst-port=8801 protocol=tcp to-addresses=192.168.22.2 to-ports=8291
add action=netmap chain=srcnat disabled=yes to-addresses=36.94.254.22
/ip firewall raw
add action=drop chain=prerouting dst-address-list=ddos-targets src-address-list=ddos-attackers
/ip route
add disabled=no distance=1 dst-address=0.0.0.0/0 gateway=36.94.254.21 routing-table=main scope=30 suppress-hw-offload=no target-scope=10
add comment="Routing IP rumah Pintu" disabled=no distance=1 dst-address=10.10.0.0/22 gateway=192.168.22.2 routing-table=main scope=30 \
    suppress-hw-offload=no target-scope=10
add comment="Routing IP rumah Pintu" disabled=no distance=1 dst-address=192.168.103.0/24 gateway=192.168.22.2 routing-table=main scope=30 \
    suppress-hw-offload=no target-scope=10
add disabled=no dst-address=172.25.101.0/24 gateway=192.168.22.2 routing-table=main suppress-hw-offload=no
add disabled=no dst-address=103.253.231.2/30 gateway=192.168.22.2 routing-table=main suppress-hw-offload=no
add blackhole disabled=no dst-address=103.253.231.0/24 gateway="" routing-table=main suppress-hw-offload=no
add disabled=no dst-address=103.253.231.8/29 gateway=103.253.231.2 routing-table=main suppress-hw-offload=no
add disabled=yes distance=1 dst-address=103.253.231.24/29 gateway=20.20.1.43 routing-table=main scope=30 suppress-hw-offload=no target-scope=10
/ip service
set telnet disabled=yes
set ftp disabled=yes
set ssh port=2233
set api disabled=yes
set api-ssl disabled=yes
/ppp secret
add local-address=20.20.1.1 name=hub profile=default-encryption remote-address=20.20.1.2
add local-address=20.20.1.3 name=smt profile=default-encryption remote-address=20.20.1.4
add local-address=20.20.1.7 name=ajat remote-address=20.20.1.8 service=l2tp
add local-address=20.20.1.5 name=jek profile=default-encryption remote-address=20.20.1.6
add local-address=20.20.1.7 name=opshi profile=default-encryption remote-address=20.20.1.8
add local-address=20.20.1.23 name=rahardian remote-address=20.20.1.24
add local-address=20.20.1.3 name=ajat2 remote-address=20.20.1.4 service=pptp
add local-address=20.20.1.17 name=comandbjr1 remote-address=20.20.1.18
add local-address=20.20.1.19 name=commandbjr2 remote-address=20.20.1.20
add local-address=20.20.1.33 name=ppk-op2 remote-address=20.20.1.34
add local-address=20.20.1.35 name=luwes remote-address=20.20.1.36
add local-address=20.20.1.27 name=opshi_lp remote-address=20.20.1.28
add local-address=20.20.1.31 name=coba remote-address=20.20.1.32 service=l2tp
add local-address=20.20.1.25 name=upi1 remote-address=20.20.1.26
add local-address=20.20.1.9 name=ridwan remote-address=20.20.1.10
add local-address=20.20.1.37 name=ruijie remote-address=20.20.1.38
add local-address=20.20.1.40 name=ppp remote-address=20.20.1.41 service=l2tp
add local-address=20.20.1.46 name=loteng profile=default-encryption remote-address=20.20.1.47 service=l2tp
add local-address=20.20.1.44 name=irf remote-address=20.20.1.45
/routing bgp connection
add as=151568 disabled=yes input.filter=rtbh-in local.address=103.253.231.1 .role=ebgp multihop=yes name=RTBH1-MTEN output.filter-chain=rtbh-out \
    .network="" remote.address=103.158.253.146/32 routing-table=main templates=RTBH
add as=151568 disabled=yes input.filter=rtbh-in local.address=103.253.231.1 .role=ebgp multihop=yes name=RTBH2-IDC output.filter-chain=rtbh-out \
    .network="" remote.address=103.163.102.122/32 routing-table=main templates=RTBH
add as=151568 disabled=yes input.filter=rtbh-in local.address=103.253.231.1 .role=ebgp multihop=yes name=RTBH3-NCIX output.filter-chain=rtbh-out \
    .network="" remote.address=202.57.26.242/32 routing-table=main templates=RTBH
add address-families=ip as=151568 cisco-vpls-nlri-len-fmt=auto-bits connect=yes disabled=no input.filter=IN listen=yes local.role=ebgp multihop=no \
    name=bgp1 nexthop-choice=force-self output.filter-chain=OUT .network=bgp-net .no-client-to-client-reflection=yes .remove-private-as=yes \
    remote.address=36.94.254.21/32 .as=7713 router-id=36.94.254.22 routing-table=main templates=bgp
add as=65001 connect=yes disabled=no input.filter=bpn-in listen=yes local.role=ibgp name=BPN output.filter-chain=bpn-out .network=bgp-net \
    .redistribute=connected remote.address=20.20.1.47/32 .as=65001 router-id=103.253.231.100 routing-table=main templates=bpn
/routing filter rule
add chain=IN disabled=no rule="if (dst-len in 8-24) { accept; }"
add chain=OUT disabled=no rule="if (dst in 103.253.231.0/24 && dst-len == 24) { accept; }"
add chain=OUT disabled=no rule="if (dst in 172.25.101.0/24 && dst-len == 24) { accept; }"
add chain=OUT disabled=no rule="if (dst in 192.168.200.0/24 && dst-len == 24) { accept; }"
add chain=OUT disabled=no rule="if (dst in 192.168.22.0/24 && dst-len == 24) { accept; }"
add chain=OUT disabled=no rule="if (dst in 20.20.1.0/24 && dst-len == 24) { accept; }"
add chain=OUT disabled=no rule="if (dst in 172.10.1.0/24 && dst-len == 24) { accept; }"
add chain=OUT disabled=no rule="reject;"
add chain=bpn-in disabled=no rule="if (dst in 103.253.231.32/29) {accept;}"
add chain=bpn-in disabled=no rule="if (dst-len in 8-24) { accept; }"
add chain=bpn-in disabled=yes rule="if (dst in 103.253.231.0/24) {accept;}"
add chain=bpn-out disabled=no rule="if (dst in 192.168.22.0/24) { accept; }"
add chain=bpn-out disabled=no rule="if (dst in 103.253.231.32/29) {accept;}"
add chain=bpn-out disabled=no rule="reject;"
/snmp
set contact=CORE-UPI enabled=yes location="UPI MANGANTI" trap-generators=temp-exception,interfaces trap-version=2
/system identity
set name="RO-UPI Manganti"
/system note
set show-at-login=no
/system routerboard settings
set enter-setup-on=delete-key
/system scheduler
add interval=1d name=schedule1 on-event="/ip dns cache flush" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=\
    2024-11-15 start-time=23:59:00

