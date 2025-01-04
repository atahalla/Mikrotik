ip addr add address=192.168.1.1/24 interface=bridge1
in bridge set [find where name="bridge1"] arp=proxy-arp 
/interface pptp-server server
set enabled=yes
/ppp secret add name=bendung password=manganti local-address=192.168.1.100 remote-address=192.168.1.101 service=pptp 
