# Mikrotik Script NATDSS 
# Purpose : make static lease, create nats for dahua nvr
# by dr0m4n 
if ([/ip dhcp-server lease find where mac-address~"38:AF:29"]) do={ 
:local ipdahua [/ip dhcp-server lease get [find where mac-address~"38:AF:29"]  address]
:local iptelkom [/ip address get [find interface="ether1-TELKOM"] address]
:set iptelkom [:pick $iptelkom 0 [:find $iptelkom "/"]]
/ip dhcp-server lease 
make-static [find where mac-address~"38:AF:29"] 
set [find where mac-address~"38:AF:29"] comment="DAHUA"
/ip firewall nat
add chain=dstnat dst-address=$iptelkom protocol=tcp port=80 action=dst-nat to-address=$ipdahua to-port=80 comment="NATDSS";
add chain=dstnat dst-address=$iptelkom protocol=tcp port=37777 action=dst-nat to-address=$ipdahua to-port=37777;
add chain=dstnat dst-address=$iptelkom protocol=tcp port=554 action=dst-nat to-address=$ipdahua to-port=554;
add chain=dstnat dst-address=$iptelkom protocol=tcp port=38800 action=dst-nat to-address=$ipdahua to-port=38800;
:log warning "Sukses" ;
} else={
:log warning "Device dahua tidak ditemukan pada lease";}
#EOF
