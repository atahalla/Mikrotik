/interface bridge
add name=bridge1
add name=ospf
/interface ethernet
set [ find default-name=ether2 ] poe-out=off
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/snmp community
add addresses=::/0 name=bbws
/ip neighbor discovery-settings
set discover-interface-list=!dynamic protocol=mndp
/ip address
add address=10.0.3.17/29 interface=bridge1 network=10.0.3.16
add address=10.10.1.100/22 interface=ospf network=10.10.0.0
/ip dns
set servers=8.8.8.8
/routing ospf instance
set [ find default=yes ] router-id=10.10.1.100
/routing ospf network
add area=backbone network=10.0.3.16/29
add area=backbone network=10.10.0.0/22
/ip firewall nat
add action=masquerade chain=srcnat
/ip route
add distance=1 gateway=10.10.1.1
/ip service
set ftp disabled=yes
set ssh disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/snmp
set contact="admin@citanduy" enabled=yes location=Bendung-Manganti trap-community=bbws \
    trap-version=2
/system clock
set time-zone-name=Asia/Jakarta
/system identity
set name=NAMA-PINTU
/system ntp client
set enabled=yes primary-ntp=52.148.114.188 secondary-ntp=17.253.60.125
/interface bridge port
add bridge=ospf interface=sfp1
add bridge=ospf interface=ether1
add bridge=bridge1 interface=ether5
add bridge=bridge1 interface=ether4
add bridge=bridge1 interface=ether3
add bridge=bridge1 interface=ether2
