
in bridge set [find where name="bridge1"] arp=enabled
ip address remove [find where address="192.168.1.1/24"] 
/interface pptp-server server set enabled=no
/ppp secret remove [find where name="bendung"]
